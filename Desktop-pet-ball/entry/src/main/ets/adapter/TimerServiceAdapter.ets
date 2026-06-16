import { TimerAPIWrapper, TimerCallback } from '../api/TimerAPIWrapper';

export class TimerServiceAdapter {
  private timerAPI: TimerAPIWrapper;

  private readonly AFFECTION_TIMER_ID = 'affection_timer';
  private readonly INTERACTION_TIMER_ID = 'interaction_timer';
  private readonly ANIMATION_TIMER_ID = 'animation_timer';

  constructor() {
    this.timerAPI = new TimerAPIWrapper();
  }

  createAffectionTimer(callback: TimerCallback, interval: number = 300000): boolean {
    return this.timerAPI.createTimer(this.AFFECTION_TIMER_ID, interval, callback);
  }

  startAffectionTimer(): boolean {
    return this.timerAPI.startTimer(this.AFFECTION_TIMER_ID);
  }

  stopAffectionTimer(): boolean {
    return this.timerAPI.stopTimer(this.AFFECTION_TIMER_ID);
  }

  createInteractionTimer(callback: TimerCallback, interval: number = 300000): boolean {
    return this.timerAPI.createTimer(this.INTERACTION_TIMER_ID, interval, callback);
  }

  startInteractionTimer(): boolean {
    return this.timerAPI.startTimer(this.INTERACTION_TIMER_ID);
  }

  stopInteractionTimer(): boolean {
    return this.timerAPI.stopTimer(this.INTERACTION_TIMER_ID);
  }

  createAnimationTimer(callback: TimerCallback, interval: number = 16): boolean {
    return this.timerAPI.createTimer(this.ANIMATION_TIMER_ID, interval, callback);
  }

  startAnimationTimer(): boolean {
    return this.timerAPI.startTimer(this.ANIMATION_TIMER_ID);
  }

  stopAnimationTimer(): boolean {
    return this.timerAPI.stopTimer(this.ANIMATION_TIMER_ID);
  }

  createCustomTimer(timerId: string, callback: TimerCallback, interval: number): boolean {
    return this.timerAPI.createTimer(timerId, interval, callback);
  }

  startCustomTimer(timerId: string): boolean {
    return this.timerAPI.startTimer(timerId);
  }

  stopCustomTimer(timerId: string): boolean {
    return this.timerAPI.stopTimer(timerId);
  }

  pauseTimer(timerId: string): boolean {
    return this.timerAPI.pauseTimer(timerId);
  }

  resumeTimer(timerId: string): boolean {
    return this.timerAPI.resumeTimer(timerId);
  }

  destroyTimer(timerId: string): boolean {
    return this.timerAPI.destroyTimer(timerId);
  }

  isTimerRunning(timerId: string): boolean {
    return this.timerAPI.isTimerRunning(timerId);
  }

  stopAllTimers(): void {
    this.stopAffectionTimer();
    this.stopInteractionTimer();
    this.stopAnimationTimer();
  }

  destroyAllTimers(): void {
    this.timerAPI.destroyAllTimers();
  }
}