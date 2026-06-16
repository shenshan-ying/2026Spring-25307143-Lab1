import { TouchAPIWrapper, TouchEvent, TouchType } from '../api/TouchAPIWrapper';

export interface GestureEvent {
  type: 'click' | 'drag' | 'long_press';
  startX: number;
  startY: number;
  endX: number;
  endY: number;
  duration: number;
  distance: number;
}

export class TouchServiceAdapter {
  private touchAPI: TouchAPIWrapper;
  private touchHistory: TouchEvent[] = [];
  private maxHistorySize: number = 10;
  private lastDownEvent: TouchEvent | null = null;
  private isDragging: boolean = false;

  private readonly CLICK_THRESHOLD = 10;
  private readonly CLICK_DURATION_THRESHOLD = 300;
  private readonly LONG_PRESS_THRESHOLD = 500;

  constructor() {
    this.touchAPI = new TouchAPIWrapper();
  }

  registerTouchListener(
    callback: (gesture: GestureEvent) => void
  ): void {
    this.touchAPI.registerTouchListener('gesture', (event: TouchEvent) => {
      this.handleTouchEvent(event, callback);
    });
  }

  unregisterTouchListener(): void {
    this.touchAPI.unregisterTouchListener('gesture');
    this.touchHistory = [];
    this.lastDownEvent = null;
    this.isDragging = false;
  }

  private handleTouchEvent(
    event: TouchEvent,
    callback: (gesture: GestureEvent) => void
  ): void {
    this.addToHistory(event);

    switch (event.type) {
      case TouchType.DOWN:
        this.handleDown(event);
        break;
      case TouchType.MOVE:
        this.handleMove(event, callback);
        break;
      case TouchType.UP:
        this.handleUp(event, callback);
        break;
    }
  }

  private handleDown(event: TouchEvent): void {
    this.lastDownEvent = event;
    this.isDragging = false;
  }

  private handleMove(
    event: TouchEvent,
    callback: (gesture: GestureEvent) => void
  ): void {
    if (!this.lastDownEvent) {
      return;
    }

    const distance = this.touchAPI.calculateTouchDistance(this.lastDownEvent, event);
    
    if (distance > this.CLICK_THRESHOLD) {
      this.isDragging = true;
      
      const gesture: GestureEvent = {
        type: 'drag',
        startX: this.lastDownEvent.x,
        startY: this.lastDownEvent.y,
        endX: event.x,
        endY: event.y,
        duration: event.timestamp - this.lastDownEvent.timestamp,
        distance: distance
      };
      
      callback(gesture);
    }
  }

  private handleUp(
    event: TouchEvent,
    callback: (gesture: GestureEvent) => void
  ): void {
    if (!this.lastDownEvent) {
      return;
    }

    const distance = this.touchAPI.calculateTouchDistance(this.lastDownEvent, event);
    const duration = event.timestamp - this.lastDownEvent.timestamp;

    if (!this.isDragging && distance <= this.CLICK_THRESHOLD) {
      if (duration < this.CLICK_DURATION_THRESHOLD) {
        const gesture: GestureEvent = {
          type: 'click',
          startX: this.lastDownEvent.x,
          startY: this.lastDownEvent.y,
          endX: event.x,
          endY: event.y,
          duration: duration,
          distance: distance
        };
        callback(gesture);
      } else if (duration >= this.LONG_PRESS_THRESHOLD) {
        const gesture: GestureEvent = {
          type: 'long_press',
          startX: this.lastDownEvent.x,
          startY: this.lastDownEvent.y,
          endX: event.x,
          endY: event.y,
          duration: duration,
          distance: distance
        };
        callback(gesture);
      }
    }

    this.lastDownEvent = null;
    this.isDragging = false;
  }

  private addToHistory(event: TouchEvent): void {
    this.touchHistory.push(event);
    if (this.touchHistory.length > this.maxHistorySize) {
      this.touchHistory.shift();
    }
  }

  detectContinuousClick(
    threshold: number = 300,
    count: number = 2
  ): boolean {
    if (this.touchHistory.length < count) {
      return false;
    }

    const recentEvents = this.touchHistory.slice(-count);
    for (let i = 1; i < recentEvents.length; i++) {
      const timeDiff = recentEvents[i].timestamp - recentEvents[i - 1].timestamp;
      if (timeDiff > threshold) {
        return false;
      }
    }

    return true;
  }

  getTouchHistory(): TouchEvent[] {
    return [...this.touchHistory];
  }

  clearHistory(): void {
    this.touchHistory = [];
  }
}