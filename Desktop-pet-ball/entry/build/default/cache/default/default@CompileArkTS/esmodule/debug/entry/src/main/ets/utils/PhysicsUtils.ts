import type { Position, Velocity } from '../dao/DataModels';
interface BoundaryReboundResult {
    position: Position;
    velocity: Velocity;
}
interface ElasticCollisionResult {
    velocity1: Velocity;
    velocity2: Velocity;
}
export class PhysicsUtils {
    static readonly FRICTION_COEFFICIENT: number = 0.99;
    static readonly RESTITUTION_COEFFICIENT: number = 0.95;
    static readonly GRAVITY: number = 0;
    static calculateVelocityDecay(velocity: Velocity, deltaTime: number): Velocity {
        const decayFactor = Math.pow(PhysicsUtils.FRICTION_COEFFICIENT, deltaTime / 16.67);
        const result: Velocity = {
            vx: velocity.vx * decayFactor,
            vy: velocity.vy * decayFactor,
            speed: velocity.speed * decayFactor
        };
        return result;
    }
    static calculateBoundaryRebound(position: Position, velocity: Velocity, screenWidth: number, screenHeight: number, ballRadius: number): BoundaryReboundResult {
        let newX = position.x;
        let newY = position.y;
        let newVx = velocity.vx;
        let newVy = velocity.vy;
        if (position.x - ballRadius < 0) {
            newX = ballRadius;
            newVx = Math.abs(velocity.vx) * PhysicsUtils.RESTITUTION_COEFFICIENT;
        }
        else if (position.x + ballRadius > screenWidth) {
            newX = screenWidth - ballRadius;
            newVx = -Math.abs(velocity.vx) * PhysicsUtils.RESTITUTION_COEFFICIENT;
        }
        if (position.y - ballRadius < 0) {
            newY = ballRadius;
            newVy = Math.abs(velocity.vy) * PhysicsUtils.RESTITUTION_COEFFICIENT;
        }
        else if (position.y + ballRadius > screenHeight) {
            newY = screenHeight - ballRadius;
            newVy = -Math.abs(velocity.vy) * PhysicsUtils.RESTITUTION_COEFFICIENT;
        }
        const newSpeed = Math.sqrt(newVx * newVx + newVy * newVy);
        const result: BoundaryReboundResult = {
            position: { x: newX, y: newY },
            velocity: { vx: newVx, vy: newVy, speed: newSpeed }
        };
        return result;
    }
    static calculateReflectionAngle(incidentAngle: number, normalAngle: number): number {
        return 2 * normalAngle - incidentAngle + Math.PI;
    }
    static calculateElasticCollision(pos1: Position, vel1: Velocity, pos2: Position, vel2: Velocity, mass1: number = 1, mass2: number = 1): ElasticCollisionResult {
        const dx = pos2.x - pos1.x;
        const dy = pos2.y - pos1.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        if (distance === 0) {
            const result: ElasticCollisionResult = { velocity1: vel1, velocity2: vel2 };
            return result;
        }
        const nx = dx / distance;
        const ny = dy / distance;
        const dvx = vel1.vx - vel2.vx;
        const dvy = vel1.vy - vel2.vy;
        const dvn = dvx * nx + dvy * ny;
        if (dvn > 0) {
            const result: ElasticCollisionResult = { velocity1: vel1, velocity2: vel2 };
            return result;
        }
        const restitution = PhysicsUtils.RESTITUTION_COEFFICIENT;
        const impulse = (-(1 + restitution) * dvn) / (1 / mass1 + 1 / mass2);
        const newVx1 = vel1.vx + (impulse / mass1) * nx;
        const newVy1 = vel1.vy + (impulse / mass1) * ny;
        const newSpeed1 = Math.sqrt(newVx1 * newVx1 + newVy1 * newVy1);
        const newVx2 = vel2.vx - (impulse / mass2) * nx;
        const newVy2 = vel2.vy - (impulse / mass2) * ny;
        const newSpeed2 = Math.sqrt(newVx2 * newVx2 + newVy2 * newVy2);
        const result: ElasticCollisionResult = {
            velocity1: { vx: newVx1, vy: newVy1, speed: newSpeed1 },
            velocity2: { vx: newVx2, vy: newVy2, speed: newSpeed2 }
        };
        return result;
    }
    static calculateSlingshotLaunch(dragDistance: number, dragAngle: number, maxDistance: number, maxSpeed: number): Velocity {
        const normalizedDistance = Math.min(dragDistance / maxDistance, 1);
        const speed = normalizedDistance * maxSpeed;
        const vx = speed * Math.cos(dragAngle);
        const vy = speed * Math.sin(dragAngle);
        const result: Velocity = { vx: vx, vy: vy, speed: speed };
        return result;
    }
    static calculateFollowingMovement(currentPos: Position, targetPos: Position, speedCoefficient: number): Velocity {
        const dx = targetPos.x - currentPos.x;
        const dy = targetPos.y - currentPos.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        if (distance < 5) {
            const result: Velocity = { vx: 0, vy: 0, speed: 0 };
            return result;
        }
        const speed = Math.min(distance * speedCoefficient, 200);
        const vx = (dx / distance) * speed;
        const vy = (dy / distance) * speed;
        const result: Velocity = { vx: vx, vy: vy, speed: speed };
        return result;
    }
    static calculateDistance(pos1: Position, pos2: Position): number {
        const dx = pos2.x - pos1.x;
        const dy = pos2.y - pos1.y;
        return Math.sqrt(dx * dx + dy * dy);
    }
    static calculateAngle(from: Position, to: Position): number {
        return Math.atan2(to.y - from.y, to.x - from.x);
    }
}
