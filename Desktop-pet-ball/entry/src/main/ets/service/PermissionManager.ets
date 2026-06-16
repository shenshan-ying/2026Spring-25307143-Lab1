import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import { common } from '@kit.AbilityKit';
import promptAction from '@ohos.promptAction';

export interface PermissionResult {
  granted: boolean;
  permission: string;
  reason?: string;
}

export class PermissionManager {
  private context: common.Context | null = null;

  init(context: common.Context): void {
    this.context = context;
  }

  async checkPermission(permission: string): Promise<boolean> {
    if (!this.context) {
      return false;
    }

    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION
      );
      
      const atManager = abilityAccessCtrl.createAtManager();
      const grantStatus = atManager.verifyAccessTokenSync(
        bundleInfo.appInfo.accessTokenId,
        permission as Permissions
      );
      
      return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      const err = error as Error;
      console.error('Check permission failed:', err.message);
      return false;
    }
  }

  async requestPermission(permission: string): Promise<PermissionResult> {
    if (!this.context) {
      return {
        granted: false,
        permission: permission,
        reason: 'Context not initialized'
      };
    }

    try {
      // 首先检查是否已有权限
      const hasPermission = await this.checkPermission(permission);
      
      if (hasPermission) {
        return {
          granted: true,
          permission: permission
        };
      }

      // 如果没有权限，尝试请求权限
      try {
        const atManager = abilityAccessCtrl.createAtManager();
        const requestPermissions: Array<Permissions> = [permission as Permissions];
        
        // 请求权限
        const grantStatus = await atManager.requestPermissionsFromUser(this.context, requestPermissions);
        
        if (grantStatus.authResults[0] === 0) {
          // 权限被授予
          return {
            granted: true,
            permission: permission
          };
        } else {
          // 权限被拒绝
          const reason = this.getPermissionDeniedReason(permission, grantStatus.authResults[0]);
          return {
            granted: false,
            permission: permission,
            reason: reason
          };
        }
      } catch (requestError) {
        const err = requestError as Error;
        console.error(`Request permission ${permission} failed:`, err.message);
        return {
          granted: false,
          permission: permission,
          reason: `权限请求失败: ${err.message}`
        };
      }
    } catch (error) {
      const err = error as Error;
      console.error(`Permission check failed for ${permission}:`, err.message);
      return {
        granted: false,
        permission: permission,
        reason: `权限检查失败: ${err.message}`
      };
    }
  }

  async requestBackgroundPermission(): Promise<PermissionResult> {
    return await this.requestPermission('ohos.permission.KEEP_BACKGROUND_RUNNING');
  }

  async requestCameraPermission(): Promise<PermissionResult> {
    return await this.requestPermission('ohos.permission.CAMERA');
  }

  // 启动时检查必要权限状态，不主动弹窗请求（CAMERA 等用到时再请求）
  async checkStartupPermissions(): Promise<PermissionResult[]> {
    const results: PermissionResult[] = [];

    // KEEP_BACKGROUND_RUNNING 是 system_grant 权限，安装时自动授权
    const bgResult = await this.checkPermission('ohos.permission.KEEP_BACKGROUND_RUNNING');
    results.push({
      granted: bgResult,
      permission: 'ohos.permission.KEEP_BACKGROUND_RUNNING'
    });

    return results;
  }

  async checkAllPermissions(): Promise<boolean> {
    const background = await this.checkPermission('ohos.permission.KEEP_BACKGROUND_RUNNING');
    return background;
  }

  getPermissionDeniedMessage(permission: string): string {
    const messages: Record<string, string> = {
      'ohos.permission.KEEP_BACKGROUND_RUNNING': '需要后台运行权限以保持宠物球持续运行',
      'ohos.permission.CAMERA': '需要相机权限以拍摄自定义宠物球'
    };

    return messages[permission] || `需要${permission}权限`;
  }

  private getPermissionDeniedReason(permission: string, resultCode: number): string {
    let reasonText: string;
    
    switch (resultCode) {
      case 0:
        reasonText = '权限已授予';
        break;
      case -1:
        reasonText = '权限被拒绝';
        break;
      case -2:
        reasonText = '权限请求被取消';
        break;
      case -3:
        reasonText = '权限请求超时';
        break;
      case -4:
        reasonText = '权限请求失败，系统错误';
        break;
      case -5:
        reasonText = '权限请求失败，参数错误';
        break;
      default:
        reasonText = `权限请求失败，错误码: ${resultCode}`;
    }
    
    const permissionMessage = this.getPermissionDeniedMessage(permission);
    return `${permissionMessage}。${reasonText}`;
  }

  // 显示权限请求提示
  async showPermissionPrompt(permission: string): Promise<void> {
    const message = this.getPermissionDeniedMessage(permission);
    
    try {
      await promptAction.showToast({
        message: message,
        duration: 3000,
        bottom: '50vp'
      } as promptAction.ShowToastOptions);
    } catch (error) {
      console.error('Failed to show permission prompt:', error);
    }
  }

  // 批量请求权限，带用户提示
  async requestPermissionsWithPrompt(permissions: string[]): Promise<PermissionResult[]> {
    const results: PermissionResult[] = [];
    
    for (const permission of permissions) {
      // 先显示提示
      await this.showPermissionPrompt(permission);
      
      // 等待一会让用户看到提示
      await new Promise<void>((resolve) => {
        setTimeout(() => resolve(), 1000);
      });
      
      // 请求权限
      const result = await this.requestPermission(permission);
      results.push(result);
      
      // 如果权限被拒绝，记录日志
      if (!result.granted) {
        console.warn(`Permission ${permission} denied: ${result.reason}`);
      }
    }
    
    return results;
  }
}
