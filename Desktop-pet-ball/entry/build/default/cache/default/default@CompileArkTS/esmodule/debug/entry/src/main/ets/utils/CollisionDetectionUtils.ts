import type { Position, PetBallInstance } from '../dao/DataModels';
interface CollisionPair {
    instance1: PetBallInstance;
    instance2: PetBallInstance;
}
export interface CollisionResult {
    hasCollision: boolean;
    collisionPairs: CollisionPair[];
}
interface SeparateResult {
    pos1: Position;
    pos2: Position;
}
interface VelocityData {
    vx: number;
    vy: number;
}
export interface EdgeSlideResult {
    isEdgeSlide: boolean;
    edge: 'left' | 'right' | 'top' | 'bottom' | null;
}
export class CollisionDetectionUtils {
    static detectCircleCollision(pos1: Position, radius1: number, pos2: Position, radius2: number): boolean {
        const dx = pos2.x - pos1.x;
        const dy = pos2.y - pos1.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        return distance < (radius1 + radius2);
    }
    static detectCollisions(instances: PetBallInstance[], radius: number): CollisionResult {
        const collisionPairs: CollisionPair[] = [];
        for (let i = 0; i < instances.length; i++) {
            for (let j = i + 1; j < instances.length; j++) {
                const instance1 = instances[i];
                const instance2 = instances[j];
                if (CollisionDetectionUtils.detectCircleCollision(instance1.position, radius, instance2.position, radius)) {
                    const pair: CollisionPair = { instance1: instance1, instance2: instance2 };
                    collisionPairs.push(pair);
                }
            }
        }
        const result: CollisionResult = {
            hasCollision: collisionPairs.length > 0,
            collisionPairs: collisionPairs
        };
        return result;
    }
    static calculateCollisionPoint(pos1: Position, radius1: number, pos2: Position, radius2: number): Position {
        const totalRadius = radius1 + radius2;
        const ratio = radius1 / totalRadius;
        const result: Position = {
            x: pos1.x + (pos2.x - pos1.x) * ratio,
            y: pos1.y + (pos2.y - pos1.y) * ratio
        };
        return result;
    }
    static calculateOverlap(pos1: Position, radius1: number, pos2: Position, radius2: number): number {
        const dx = pos2.x - pos1.x;
        const dy = pos2.y - pos1.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        const minDistance = radius1 + radius2;
        return Math.max(0, minDistance - distance);
    }
    static separateOverlappingInstances(instance1: PetBallInstance, instance2: PetBallInstance, radius: number): SeparateResult {
        const dx = instance2.position.x - instance1.position.x;
        const dy = instance2.position.y - instance1.position.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        if (distance === 0) {
            const result: SeparateResult = {
                pos1: { x: instance1.position.x - radius, y: instance1.position.y },
                pos2: { x: instance2.position.x + radius, y: instance2.position.y }
            };
            return result;
        }
        const overlap = CollisionDetectionUtils.calculateOverlap(instance1.position, radius, instance2.position, radius);
        if (overlap === 0) {
            const result: SeparateResult = {
                pos1: instance1.position,
                pos2: instance2.position
            };
            return result;
        }
        const nx = dx / distance;
        const ny = dy / distance;
        const separation = overlap / 2;
        const result: SeparateResult = {
            pos1: {
                x: instance1.position.x - nx * separation,
                y: instance1.position.y - ny * separation
            },
            pos2: {
                x: instance2.position.x + nx * separation,
                y: instance2.position.y + ny * separation
            }
        };
        return result;
    }
    static detectEdgeSlide(position: Position, velocity: VelocityData, screenWidth: number, screenHeight: number, edgeThreshold: number = 50): EdgeSlideResult {
        const isNearLeft = position.x < edgeThreshold && velocity.vx < 0;
        const isNearRight = position.x > screenWidth - edgeThreshold && velocity.vx > 0;
        const isNearTop = position.y < edgeThreshold && velocity.vy < 0;
        const isNearBottom = position.y > screenHeight - edgeThreshold && velocity.vy > 0;
        if (isNearLeft) {
            const result: EdgeSlideResult = { isEdgeSlide: true, edge: 'left' };
            return result;
        }
        if (isNearRight) {
            const result: EdgeSlideResult = { isEdgeSlide: true, edge: 'right' };
            return result;
        }
        if (isNearTop) {
            const result: EdgeSlideResult = { isEdgeSlide: true, edge: 'top' };
            return result;
        }
        if (isNearBottom) {
            const result: EdgeSlideResult = { isEdgeSlide: true, edge: 'bottom' };
            return result;
        }
        const result: EdgeSlideResult = { isEdgeSlide: false, edge: null };
        return result;
    }
}
