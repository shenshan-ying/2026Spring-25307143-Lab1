import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import wantAgent from '@ohos.app.ability.wantAgent';
import { common } from '@kit.AbilityKit';

export class BackgroundServiceManager {
  private context: common.Context | null = null;
  private isRunning: boolean = false;

  init(context: common.Context): void {
    this.context = context;
  }

  async requestBackgroundTask(): Promise<boolean> {
    if (!this.context) {
      console.error('Context not initialized');
      return false;
    }

    if (this.isRunning) {
      return true;
    }

    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: this.context.applicationInfo.name,
            abilityName: 'EntryAbility'
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };

      const agent = await wantAgent.getWantAgent(wantAgentInfo);

      // 使用新的字符串数组形式的 background mode
      const bgModes: string[] = ['dataTransfer'];
      await backgroundTaskManager.startBackgroundRunning(
        this.context,
        bgModes,
        agent
      );

      this.isRunning = true;
      console.info('Background task started');
      return true;
    } catch (error) {
      const err = error as Error;
      console.error('Request background task failed:', err.message);
      return false;
    }
  }

  async cancelBackgroundTask(): Promise<void> {
    if (!this.isRunning) {
      return;
    }

    try {
      if (this.context) {
        backgroundTaskManager.stopBackgroundRunning(this.context);
      }
      this.isRunning = false;
      console.info('Background task cancelled');
    } catch (error) {
      const err = error as Error;
      console.error('Cancel background task failed:', err.message);
    }
  }

  isBackgroundRunning(): boolean {
    return this.isRunning;
  }

  async restartBackgroundTask(): Promise<boolean> {
    await this.cancelBackgroundTask();
    return await this.requestBackgroundTask();
  }

  async monitorCpuUsage(threshold: number = 15): Promise<boolean> {
    return true;
  }

  async monitorMemoryUsage(threshold: number = 90): Promise<boolean> {
    return true;
  }
}
