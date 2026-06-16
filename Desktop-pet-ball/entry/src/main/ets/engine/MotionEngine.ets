import { Position, Velocity } from '../dao/DataModels';
import { PhysicsUtils } from '../utils/PhysicsUtils';

interface MotionResult {
  position: Position;
  velocity: Velocity;
}

export interface MotionStrategy {
  calculate(position: Position, velocity: Velocity, deltaTime: number): MotionResult;
}

export class FreeRollingStrategy implements MotionStrategy {
  private screenWidth: number;
  private screenHeight: number;
  private ballRadius: number;

  constructor(screenWidth: number, screenHeight: number, ballRadius: number) {
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.ballRadius = ballRadius;
  }

  calculate(position: Position, velocity: Velocity, deltaTime: number): MotionResult {
    const dt = deltaTime / 1000;
    
    let newX = position.x + velocity.vx * dt;
    let newY = position.y + velocity.vy * dt;
    
    let newVelocity = PhysicsUtils.calculateVelocityDecay(velocity, deltaTime);
    
    const rebound = PhysicsUtils.calculateBoundaryRebound(
      { x: newX, y: newY },
      newVelocity,
      this.screenWidth,
      this.screenHeight,
      this.ballRadius
    );

    const result: MotionResult = {
      position: rebound.position,
      velocity: rebound.velocity
    };
    return result;
  }
}

export class StaticStrategy implements MotionStrategy {
  calculate(position: Position, velocity: Velocity, deltaTime: number): MotionResult {
    const result: MotionResult = {
      position: position,
      velocity: { vx: 0, vy: 0, speed: 0 }
    };
    return result;
  }
}

export class SlingshotStrategy implements MotionStrategy {
  private screenWidth: number;
  private screenHeight: number;
  private ballRadius: number;

  constructor(screenWidth: number, screenHeight: number, ballRadius: number) {
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.ballRadius = ballRadius;
  }

  calculate(position: Position, velocity: Velocity, deltaTime: number): MotionResult {
    const dt = deltaTime / 1000;
    
    let newX = position.x + velocity.vx * dt;
    let newY = position.y + velocity.vy * dt;
    
    let newVelocity = PhysicsUtils.calculateVelocityDecay(velocity, deltaTime);
    
    const rebound = PhysicsUtils.calculateBoundaryRebound(
      { x: newX, y: newY },
      newVelocity,
      this.screenWidth,
      this.screenHeight,
      this.ballRadius
    );

    const result: MotionResult = {
      position: rebound.position,
      velocity: rebound.velocity
    };
    return result;
  }
}

export class FollowingStrategy implements MotionStrategy {
  private targetPosition: Position | null = null;
  private speedCoefficient: number = 0.1;

  setTarget(target: Position): void {
    this.targetPosition = target;
  }

  setSpeedCoefficient(coefficient: number): void {
    this.speedCoefficient = coefficient;
  }

  calculate(position: Position, velocity: Velocity, deltaTime: number): MotionResult {
    if (!this.targetPosition) {
      const result: MotionResult = { position: position, velocity: velocity };
      return result;
    }

    const newVelocity = PhysicsUtils.calculateFollowingMovement(
      position,
      this.targetPosition,
      this.speedCoefficient
    );

    const dt = deltaTime / 1000;
    const newX = position.x + newVelocity.vx * dt;
    const newY = position.y + newVelocity.vy * dt;

    const result: MotionResult = {
      position: { x: newX, y: newY },
      velocity: newVelocity
    };
    return result;
  }
}

export class MotionEngine {
  private strategy: MotionStrategy | null = null;
  private screenWidth: number;
  private screenHeight: number;
  private ballRadius: number;

  constructor(screenWidth: number, screenHeight: number, ballRadius: number) {
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.ballRadius = ballRadius;
  }

  setStrategy(strategyType: 'free_rolling' | 'static' | 'slingshot' | 'following'): void {
    switch (strategyType) {
      case 'free_rolling':
        this.strategy = new FreeRollingStrategy(this.screenWidth, this.screenHeight, this.ballRadius);
        break;
      case 'static':
        this.strategy = new StaticStrategy();
        break;
      case 'slingshot':
        this.strategy = new SlingshotStrategy(this.screenWidth, this.screenHeight, this.ballRadius);
        break;
      case 'following':
        this.strategy = new FollowingStrategy();
        break;
    }
  }

  getStrategy(): MotionStrategy | null {
    return this.strategy;
  }

  update(position: Position, velocity: Velocity, deltaTime: number): MotionResult {
    if (!this.strategy) {
      const result: MotionResult = { position: position, velocity: velocity };
      return result;
    }

    return this.strategy.calculate(position, velocity, deltaTime);
  }

  updateScreenSize(width: number, height: number): void {
    this.screenWidth = width;
    this.screenHeight = height;
  }

  updateBallRadius(radius: number): void {
    this.ballRadius = radius;
  }
}
