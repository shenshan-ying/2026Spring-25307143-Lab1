import { Position, Velocity } from '../dao/DataModels';
import { PhysicsUtils } from '../utils/PhysicsUtils';

export class BoundaryChecker {
  private screenWidth: number;
  private screenHeight: number;
  private ballRadius: number;

  constructor(screenWidth: number, screenHeight: number, ballRadius: number) {
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.ballRadius = ballRadius;
  }

  checkBoundary(position: Position): boolean {
    return (
      position.x - this.ballRadius >= 0 &&
      position.x + this.ballRadius <= this.screenWidth &&
      position.y - this.ballRadius >= 0 &&
      position.y + this.ballRadius <= this.screenHeight
    );
  }

  checkEdgeCollision(position: Position, velocity: Velocity): {
    hasCollision: boolean;
    edge: 'left' | 'right' | 'top' | 'bottom' | null;
    normalAngle: number;
  } {
    if (position.x - this.ballRadius <= 0 && velocity.vx < 0) {
      return { hasCollision: true, edge: 'left', normalAngle: 0 };
    }
    
    if (position.x + this.ballRadius >= this.screenWidth && velocity.vx > 0) {
      return { hasCollision: true, edge: 'right', normalAngle: Math.PI };
    }
    
    if (position.y - this.ballRadius <= 0 && velocity.vy < 0) {
      return { hasCollision: true, edge: 'top', normalAngle: Math.PI / 2 };
    }
    
    if (position.y + this.ballRadius >= this.screenHeight && velocity.vy > 0) {
      return { hasCollision: true, edge: 'bottom', normalAngle: -Math.PI / 2 };
    }

    return { hasCollision: false, edge: null, normalAngle: 0 };
  }

  correctPosition(position: Position): Position {
    let x = position.x;
    let y = position.y;

    if (x - this.ballRadius < 0) {
      x = this.ballRadius;
    } else if (x + this.ballRadius > this.screenWidth) {
      x = this.screenWidth - this.ballRadius;
    }

    if (y - this.ballRadius < 0) {
      y = this.ballRadius;
    } else if (y + this.ballRadius > this.screenHeight) {
      y = this.screenHeight - this.ballRadius;
    }

    return { x, y };
  }

  calculateReflection(velocity: Velocity, normalAngle: number): Velocity {
    const incidentAngle = Math.atan2(velocity.vy, velocity.vx);
    const reflectionAngle = PhysicsUtils.calculateReflectionAngle(incidentAngle, normalAngle);
    
    const speed = velocity.speed * PhysicsUtils.RESTITUTION_COEFFICIENT;
    
    return {
      vx: speed * Math.cos(reflectionAngle),
      vy: speed * Math.sin(reflectionAngle),
      speed: speed
    };
  }

  checkJudgmentLine(
    position: Position,
    velocity: Velocity,
    judgmentLinePosition: 'bottom' | 'top' | 'left' | 'right',
    threshold: number = 50
  ): boolean {
    switch (judgmentLinePosition) {
      case 'bottom':
        return position.y + this.ballRadius >= this.screenHeight - threshold && velocity.vy > 0;
      case 'top':
        return position.y - this.ballRadius <= threshold && velocity.vy < 0;
      case 'left':
        return position.x - this.ballRadius <= threshold && velocity.vx < 0;
      case 'right':
        return position.x + this.ballRadius >= this.screenWidth - threshold && velocity.vx > 0;
      default:
        return false;
    }
  }

  getDistanceToEdge(position: Position, edge: 'left' | 'right' | 'top' | 'bottom'): number {
    switch (edge) {
      case 'left':
        return position.x - this.ballRadius;
      case 'right':
        return this.screenWidth - position.x - this.ballRadius;
      case 'top':
        return position.y - this.ballRadius;
      case 'bottom':
        return this.screenHeight - position.y - this.ballRadius;
      default:
        return 0;
    }
  }

  updateScreenSize(width: number, height: number): void {
    this.screenWidth = width;
    this.screenHeight = height;
  }

  updateBallRadius(radius: number): void {
    this.ballRadius = radius;
  }
}