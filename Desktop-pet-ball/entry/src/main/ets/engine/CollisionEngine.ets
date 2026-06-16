import { PetBallInstance, Position, Velocity } from '../dao/DataModels';
import { CollisionDetectionUtils, CollisionResult, EdgeSlideResult } from '../utils/CollisionDetectionUtils';
import { PhysicsUtils } from '../utils/PhysicsUtils';

interface CollisionHistoryRecord {
  instance1Id: string;
  instance2Id: string;
  time: number;
}

interface ResolveResult {
  instance1: PetBallInstance;
  instance2: PetBallInstance;
}

export class CollisionEngine {
  private ballRadius: number = 60;
  private collisionHistory: CollisionHistoryRecord[] = [];
  private maxHistorySize: number = 100;

  constructor(ballRadius?: number) {
    if (ballRadius !== undefined) {
      this.ballRadius = ballRadius;
    }
  }

  setBallRadius(radius: number): void {
    this.ballRadius = radius;
  }

  detectCollisions(instances: PetBallInstance[]): CollisionResult {
    return CollisionDetectionUtils.detectCollisions(instances, this.ballRadius);
  }

  resolveCollision(instance1: PetBallInstance, instance2: PetBallInstance): ResolveResult {
    const collisionResult = PhysicsUtils.calculateElasticCollision(
      instance1.position,
      instance1.velocity,
      instance2.position,
      instance2.velocity
    );
    const velocity1 = collisionResult.velocity1;
    const velocity2 = collisionResult.velocity2;

    const separateResult = CollisionDetectionUtils.separateOverlappingInstances(
      instance1,
      instance2,
      this.ballRadius
    );
    const pos1 = separateResult.pos1;
    const pos2 = separateResult.pos2;

    const newInstance1: PetBallInstance = {
      id: instance1.id,
      resourceId: instance1.resourceId,
      position: pos1,
      velocity: velocity1,
      state: instance1.state,
      affectionValue: instance1.affectionValue,
      createdAt: instance1.createdAt,
      lastInteractionTime: instance1.lastInteractionTime
    };

    const newInstance2: PetBallInstance = {
      id: instance2.id,
      resourceId: instance2.resourceId,
      position: pos2,
      velocity: velocity2,
      state: instance2.state,
      affectionValue: instance2.affectionValue,
      createdAt: instance2.createdAt,
      lastInteractionTime: instance2.lastInteractionTime
    };

    this.recordCollision(instance1.id, instance2.id);

    const result: ResolveResult = {
      instance1: newInstance1,
      instance2: newInstance2
    };
    return result;
  }

  resolveAllCollisions(instances: PetBallInstance[]): PetBallInstance[] {
    const collisionResult = this.detectCollisions(instances);
    
    if (!collisionResult.hasCollision) {
      return instances;
    }

    const instanceMap = new Map<string, PetBallInstance>();
    instances.forEach(instance => {
      instanceMap.set(instance.id, instance);
    });

    for (let i = 0; i < collisionResult.collisionPairs.length; i++) {
      const pair = collisionResult.collisionPairs[i];
      const instance1 = pair.instance1;
      const instance2 = pair.instance2;
      
      const resolved = this.resolveCollision(
        instanceMap.get(instance1.id)!,
        instanceMap.get(instance2.id)!
      );
      
      instanceMap.set(instance1.id, resolved.instance1);
      instanceMap.set(instance2.id, resolved.instance2);
    }

    return Array.from(instanceMap.values());
  }

  private recordCollision(instance1Id: string, instance2Id: string): void {
    const record: CollisionHistoryRecord = {
      instance1Id: instance1Id,
      instance2Id: instance2Id,
      time: Date.now()
    };
    this.collisionHistory.push(record);

    if (this.collisionHistory.length > this.maxHistorySize) {
      this.collisionHistory.shift();
    }
  }

  getCollisionHistory(): CollisionHistoryRecord[] {
    const result: CollisionHistoryRecord[] = [];
    for (let i = 0; i < this.collisionHistory.length; i++) {
      result.push(this.collisionHistory[i]);
    }
    return result;
  }

  clearHistory(): void {
    this.collisionHistory = [];
  }

  getCollisionCount(instanceId: string): number {
    return this.collisionHistory.filter(
      record => record.instance1Id === instanceId || record.instance2Id === instanceId
    ).length;
  }

  checkEdgeSlide(
    instance: PetBallInstance,
    screenWidth: number,
    screenHeight: number
  ): EdgeSlideResult {
    const result = CollisionDetectionUtils.detectEdgeSlide(
      instance.position,
      { vx: instance.velocity.vx, vy: instance.velocity.vy },
      screenWidth,
      screenHeight
    );
    return result;
  }

  calculateCollisionPoint(instance1: PetBallInstance, instance2: PetBallInstance): Position {
    return CollisionDetectionUtils.calculateCollisionPoint(
      instance1.position,
      this.ballRadius,
      instance2.position,
      this.ballRadius
    );
  }
}
