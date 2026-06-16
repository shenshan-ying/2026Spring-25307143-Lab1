export interface TouchEvent {
  type: TouchType;
  x: number;
  y: number;
  timestamp: number;
}

export enum TouchType {
  DOWN = 'down',
  MOVE = 'move',
  UP = 'up'
}

export class TouchAPIWrapper {
  private touchListeners: Map<string, (event: TouchEvent) => void> = new Map();

  registerTouchListener(
    listenerId: string,
    callback: (event: TouchEvent) => void
  ): boolean {
    try {
      this.touchListeners.set(listenerId, callback);
      return true;
    } catch (error) {
      console.error('Register touch listener failed:', error);
      return false;
    }
  }

  unregisterTouchListener(listenerId: string): boolean {
    try {
      this.touchListeners.delete(listenerId);
      return true;
    } catch (error) {
      console.error('Unregister touch listener failed:', error);
      return false;
    }
  }

  dispatchTouchEvent(event: TouchEvent): void {
    this.touchListeners.forEach((callback, listenerId) => {
      try {
        callback(event);
      } catch (error) {
        console.error(`Touch listener ${listenerId} error:`, error);
      }
    });
  }

  filterMultiTouch(events: TouchEvent[]): TouchEvent | null {
    if (events.length === 0) {
      return null;
    }

    return events[0];
  }

  isSingleTouch(event: TouchEvent): boolean {
    return true;
  }

  calculateTouchDistance(
    event1: TouchEvent,
    event2: TouchEvent
  ): number {
    const dx = event2.x - event1.x;
    const dy = event2.y - event1.y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  calculateTouchAngle(
    event1: TouchEvent,
    event2: TouchEvent
  ): number {
    const dx = event2.x - event1.x;
    const dy = event2.y - event1.y;
    return Math.atan2(dy, dx);
  }

  clearAllListeners(): void {
    this.touchListeners.clear();
  }
}