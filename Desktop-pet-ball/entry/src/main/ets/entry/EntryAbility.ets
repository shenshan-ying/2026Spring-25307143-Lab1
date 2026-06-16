import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import window from '@ohos.window';
import display from '@ohos.display';
import { Logger, LogLevel, LogContext } from '../utils/Logger';
import { PermissionManager } from '../service/PermissionManager';
import { WindowServiceAdapter } from '../adapter/WindowServiceAdapter';
import { DeviceAdapter } from '../service/DeviceAdapter';
import { common } from '@kit.AbilityKit';

export default class EntryAbility extends UIAbility {
  private logger: Logger = Logger.getInstance();
  private permissionManager: PermissionManager = new PermissionManager();
  private windowServiceAdapter: WindowServiceAdapter = new WindowServiceAdapter();
  private deviceAdapter: DeviceAdapter = new DeviceAdapter();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.logger.setLogLevel(LogLevel.DEBUG);
    this.logger.info('EntryAbility', 'Application onCreate');

    this.permissionManager.init(this.context as common.UIAbilityContext);
    this.windowServiceAdapter.init(this.context);
    this.deviceAdapter.init(this.context as common.UIAbilityContext);

    this.permissionManager.checkStartupPermissions().then(results => {
      results.forEach(r => {
        if (!r.granted) {
          this.logger.warn('EntryAbility', `Permission ${r.permission} not granted`);
        } else {
          this.logger.info('EntryAbility', `Permission ${r.permission} granted`);
        }
      });
    });
  }

  onDestroy(): void {
    this.logger.info('EntryAbility', 'Application onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    this.logger.info('EntryAbility', 'Window stage create');

    // 主窗口设为全屏透明，宠物球在主窗口内渲染时不被白底遮挡
    windowStage.getMainWindow((err, mainWin) => {
      if (!err.code && mainWin) {
        mainWin.setWindowLayoutFullScreen(true);
      }
    });

    // 1. 加载主窗口 — 控制面板（包含宠物球回退渲染层）
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        const logCtx = new LogContext();
        logCtx.set('error', err);
        this.logger.error('EntryAbility', 'Failed to load Index', logCtx);
        return;
      }
      this.logger.info('EntryAbility', 'Index loaded successfully');
    });

    // 2. 尝试创建桌面浮窗 — 宠物球显示（手机端会失败，自动回退到主窗口内渲染）
    this.createDesktopFloatWindow(windowStage);
  }

  /**
   * 使用 window.createWindow 创建 TYPE_FLOAT 窗口并加载 FloatWindowPage。
   * 手机端 SYSTEM_FLOAT_WINDOW 权限不开放，创建会失败，
   * 此时设置 fallback 标记，通知 Index 页面在主窗口内渲染宠物球。
   */
  private createDesktopFloatWindow(windowStage: window.WindowStage): void {
    try {
      const disp = display.getDefaultDisplaySync();
      const sw = disp.width;
      const sh = disp.height;

      const config: window.Configuration = {
        name: 'DesktopPetFloat',
        windowType: window.WindowType.TYPE_FLOAT,
        ctx: this.context
      };

      window.createWindow(config, (err: Error, floatWin: window.Window) => {
        if (err) {
          this.logger.warn('EntryAbility', `Create float window failed: ${err.message}`);
          this.logger.info('EntryAbility', 'Fallback to in-window pet rendering');
          AppStorage.setOrCreate('floatWindowReady', false);
          // 调试日志：显示回退状态
          console.info('Float window creation failed, fallback enabled. Error:', err.message);
          return;
        }

        // 浮窗创建成功（PC/2in1 设备）
        AppStorage.setOrCreate('floatWindowReady', true);
        console.info('Float window created successfully');

        // 全屏透明
        floatWin.setWindowLayoutFullScreen(true, (layoutErr: Error) => {
          if (layoutErr) {
            this.logger.warn('EntryAbility', `Set layout fullscreen failed: ${layoutErr.message}`);
          }
        });

        floatWin.resize(sw, sh, (resizeErr: Error) => {
          if (resizeErr) {
            this.logger.warn('EntryAbility', `Resize failed: ${resizeErr.message}`);
          }
        });

        floatWin.moveWindowTo(0, 0, (moveErr: Error) => {
          if (moveErr) {
            this.logger.warn('EntryAbility', `Move failed: ${moveErr.message}`);
          }
        });

        // 加载 FloatWindowPage
        floatWin.loadContent('pages/FloatWindowPage', (loadErr: Error) => {
          if (loadErr) {
            this.logger.warn('EntryAbility', `Load FloatWindowPage failed: ${loadErr.message}`);
            return;
          }
          this.logger.info('EntryAbility', 'FloatWindowPage loaded');

          floatWin.showWindow((showErr: Error) => {
            if (showErr) {
              this.logger.warn('EntryAbility', `Show float window failed: ${showErr.message}`);
            } else {
              this.logger.info('EntryAbility', 'Desktop float window visible');
            }
          });
        });
      });
    } catch (e) {
      this.logger.warn('EntryAbility', `Create float window exception: ${e}`);
      AppStorage.setOrCreate('floatWindowReady', false);
    }
  }

  onWindowStageDestroy(): void {
    this.logger.info('EntryAbility', 'Window stage destroy');
  }

  onForeground(): void {
    this.logger.info('EntryAbility', 'onForeground');
  }

  onBackground(): void {
    this.logger.info('EntryAbility', 'onBackground');
  }

  getPermissionManager(): PermissionManager {
    return this.permissionManager;
  }

  getWindowServiceAdapter(): WindowServiceAdapter {
    return this.windowServiceAdapter;
  }

  getDeviceAdapter(): DeviceAdapter {
    return this.deviceAdapter;
  }
}
