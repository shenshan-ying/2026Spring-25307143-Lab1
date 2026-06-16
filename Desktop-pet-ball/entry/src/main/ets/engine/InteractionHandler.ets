import { Position, Velocity } from '../dao/DataModels';
import { PhysicsUtils } from '../utils/PhysicsUtils';

export interface InteractionResultData {
  startX?: number;
  startY?: number;
  currentX?: number;
  currentY?: number;
  dragDistance?: number;
  dragDuration?: number;
  edgePosition?: string;
  clickCount?: number;
  timestamp?: number;
}

export interface InteractionResult {
  type: 'drag' | 'click' | 'slingshot' | 'edge_slide';
  position: Position;
  velocity?: Velocity;
  data: InteractionResultData;
}

export class InteractionHandler {
  private isDragging: boolean = false;
  private dragStartPosition: Position | null = null;
  private lastDragPosition: Position | null = null;
  private dragStartTime: number = 0;
  private clickCount: number = 0;
  private lastClickTime: number = 0;

  private readonly SLINGSHOT_THRESHOLD: number = 100;
  private readonly CLICK_INTERVAL: number = 300;
  private readonly EDGE_SLIDE_THRESHOLD: number = 50;

  handleDragStart(position: Position): void {
    this.isDragging = true;
    this.dragStartPosition = position;
    this.lastDragPosition = position;
    this.dragStartTime = Date.now();
  }

  handleDragMove(position: Position): InteractionResult | null {
    if (!this.isDragging || !this.dragStartPosition) {
      return null;
    }

    this.lastDragPosition = position;

    const data: InteractionResultData = {
      startX: this.dragStartPosition.x,
      startY: this.dragStartPosition.y,
      currentX: position.x,
      currentY: position.y
    };

    const result: InteractionResult = {
      type: 'drag',
      position: position,
      data: data
    };
    return result;
  }

  handleDragEnd(
    position: Position,
    screenWidth: number,
    screenHeight: number,
    judgmentLinePosition: 'bottom' | 'top' | 'left' | 'right'
  ): InteractionResult {
    this.isDragging = false;

    if (!this.dragStartPosition) {
      const result: InteractionResult = {
        type: 'drag',
        position: position,
        data: {}
      };
      return result;
    }

    const dragDistance = PhysicsUtils.calculateDistance(this.dragStartPosition, position);
    const dragDuration = Date.now() - this.dragStartTime;

    const isEdgeSlide = this.checkEdgeSlide(
      position,
      screenWidth,
      screenHeight,
      judgmentLinePosition
    );

    if (isEdgeSlide && dragDistance > this.SLINGSHOT_THRESHOLD) {
      const velocity = this.calculateSlingshotVelocity(
        this.dragStartPosition,
        position,
        screenWidth,
        screenHeight,
        judgmentLinePosition
      );

      const data: InteractionResultData = {
        dragDistance: dragDistance,
        dragDuration: dragDuration,
        edgePosition: judgmentLinePosition
      };

      const result: InteractionResult = {
        type: 'slingshot',
        position: position,
        velocity: velocity,
        data: data
      };
      return result;
    }

    this.dragStartPosition = null;
    this.lastDragPosition = null;

    const data: InteractionResultData = {
      dragDistance: dragDistance,
      dragDuration: dragDuration
    };

    const result: InteractionResult = {
      type: 'drag',
      position: position,
      data: data
    };
    return result;
  }

  handleClick(position: Position): InteractionResult {
    const currentTime = Date.now();
    
    if (currentTime - this.lastClickTime < this.CLICK_INTERVAL) {
      this.clickCount++;
    } else {
      this.clickCount = 1;
    }
    
    this.lastClickTime = currentTime;

    const data: InteractionResultData = {
      clickCount: this.clickCount,
      timestamp: currentTime
    };

    const result: InteractionResult = {
      type: 'click',
      position: position,
      data: data
    };
    return result;
  }

  private checkEdgeSlide(
    position: Position,
    screenWidth: number,
    screenHeight: number,
    judgmentLinePosition: 'bottom' | 'top' | 'left' | 'right'
  ): boolean {
    switch (judgmentLinePosition) {
      case 'bottom':
        return position.y >= screenHeight - this.EDGE_SLIDE_THRESHOLD;
      case 'top':
        return position.y <= this.EDGE_SLIDE_THRESHOLD;
      case 'left':
        return position.x <= this.EDGE_SLIDE_THRESHOLD;
      case 'right':
        return position.x >= screenWidth - this.EDGE_SLIDE_THRESHOLD;
      default:
        return false;
    }
  }

  private calculateSlingshotVelocity(
    startPos: Position,
    endPos: Position,
    screenWidth: number,
    screenHeight: number,
    judgmentLinePosition: 'bottom' | 'top' | 'left' | 'right'
  ): Velocity {
    const dx = endPos.x - startPos.x;
    const dy = endPos.y - startPos.y;
    const dragDistance = Math.sqrt(dx * dx + dy * dy);
    const dragAngle = Math.atan2(dy, dx);

    let launchAngle: number;
    switch (judgmentLinePosition) {
      case 'bottom':
        launchAngle = -dragAngle;
        break;
      case 'top':
        launchAngle = -dragAngle;
        break;
      case 'left':
        launchAngle = Math.PI - dragAngle;
        break;
      case 'right':
        launchAngle = Math.PI - dragAngle;
        break;
      default:
        launchAngle = dragAngle;
    }

    const maxDistance = Math.min(screenWidth, screenHeight) / 3;
    const maxSpeed = 1000;

    return PhysicsUtils.calculateSlingshotLaunch(dragDistance, launchAngle, maxDistance, maxSpeed);
  }

  getClickCount(): number {
    return this.clickCount;
  }

  resetClickCount(): void {
    this.clickCount = 0;
  }

  isDraggingActive(): boolean {
    return this.isDragging;
  }

  getLastDragPosition(): Position | null {
    return this.lastDragPosition;
  }
}
