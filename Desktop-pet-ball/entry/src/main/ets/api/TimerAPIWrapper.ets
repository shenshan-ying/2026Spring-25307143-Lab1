export type TimerCallback = () => void;

export interface TimerInfo {
  id: string;
  interval: number;
  callback: TimerCallback;
  isRunning: boolean;
  lastTriggerTime: number;
  accumulatedError: number;
}

export class TimerAPIWrapper {
  private timers: Map<string, TimerInfo> = new Map();
  private intervalIds: Map<string, number> = new Map();

  createTimer(
    timerId: string,
    interval: number,
    callback: TimerCallback
  ): boolean {
    try {
      const timerInfo: TimerInfo = {
        id: timerId,
        interval: interval,
        callback: callback,
        isRunning: false,
        lastTriggerTime: 0,
        accumulatedError: 0
      };

      this.timers.set(timerId, timerInfo);
      return true;
    } catch (error) {
      console.error('Create timer failed:', error);
      return false;
    }
  }

  startTimer(timerId: string): boolean {
    const timerInfo = this.timers.get(timerId);
    if (!timerInfo) {
      console.error(`Timer ${timerId} not found`);
      return false;
    }

    if (timerInfo.isRunning) {
      return true;
    }

    try {
      timerInfo.isRunning = true;
      timerInfo.lastTriggerTime = Date.now();
      timerInfo.accumulatedError = 0;

      const intervalId = setInterval(() => {
        this.executeTimerWithCompensation(timerId);
      }, timerInfo.interval);

      this.intervalIds.set(timerId, intervalId);
      return true;
    } catch (error) {
      console.error('Start timer failed:', error);
      return false;
    }
  }

  private executeTimerWithCompensation(timerId: string): void {
    const timerInfo = this.timers.get(timerId);
    if (!timerInfo || !timerInfo.isRunning) {
      return;
    }

    const currentTime = Date.now();
    const expectedTime = timerInfo.lastTriggerTime + timerInfo.interval;
    const actualError = currentTime - expectedTime;

    timerInfo.accumulatedError += actualError;

    if (Math.abs(timerInfo.accumulatedError) > timerInfo.interval * 0.1) {
      console.warn(`Timer ${timerId} accumulated error: ${timerInfo.accumulatedError}ms`);
    }

    try {
      timerInfo.callback();
    } catch (error) {
      console.error(`Timer ${timerId} callback error:`, error);
    }

    timerInfo.lastTriggerTime = currentTime;
  }

  stopTimer(timerId: string): boolean {
    const timerInfo = this.timers.get(timerId);
    if (!timerInfo) {
      return true;
    }

    try {
      const intervalId = this.intervalIds.get(timerId);
      if (intervalId !== undefined) {
        clearInterval(intervalId);
        this.intervalIds.delete(timerId);
      }

      timerInfo.isRunning = false;
      return true;
    } catch (error) {
      console.error('Stop timer failed:', error);
      return false;
    }
  }

  pauseTimer(timerId: string): boolean {
    return this.stopTimer(timerId);
  }

  resumeTimer(timerId: string): boolean {
    return this.startTimer(timerId);
  }

  destroyTimer(timerId: string): boolean {
    this.stopTimer(timerId);
    this.timers.delete(timerId);
    return true;
  }

  isTimerRunning(timerId: string): boolean {
    const timerInfo = this.timers.get(timerId);
    return timerInfo?.isRunning || false;
  }

  getTimerInfo(timerId: string): TimerInfo | null {
    return this.timers.get(timerId) || null;
  }

  destroyAllTimers(): void {
    this.timers.forEach((timerInfo, timerId) => {
      this.destroyTimer(timerId);
    });
  }
}