import type { PetBallInstance, Position, Velocity } from '../dao/DataModels';
import { StorageServiceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/adapter/StorageServiceAdapter";
import type { CultivationManager } from '../manager/CultivationManager';
function copyInstance(instance: PetBallInstance): PetBallInstance {
    return {
        id: instance.id,
        resourceId: instance.resourceId,
        position: {
            x: instance.position.x,
            y: instance.position.y
        },
        velocity: {
            vx: instance.velocity.vx,
            vy: instance.velocity.vy,
            speed: instance.velocity.speed
        },
        state: instance.state,
        affectionValue: instance.affectionValue,
        createdAt: instance.createdAt,
        lastInteractionTime: instance.lastInteractionTime
    };
}
export class StateManager {
    private storageAdapter: StorageServiceAdapter;
    private cultivationManager: CultivationManager;
    private followingThreshold: number = 100;
    constructor(cultivationManager: CultivationManager) {
        this.storageAdapter = new StorageServiceAdapter();
        this.cultivationManager = cultivationManager;
    }
    async init(context: Context): Promise<void> {
        await this.storageAdapter.init(context);
    }
    async checkStateTransition(instance: PetBallInstance): Promise<PetBallInstance> {
        const affectionValue = this.cultivationManager.getAffection(instance.id);
        if (affectionValue >= this.followingThreshold && instance.state !== 'following') {
            return await this.transitionToFollowing(instance);
        }
        else if (affectionValue < this.followingThreshold && instance.state === 'following') {
            return await this.transitionToNormal(instance);
        }
        return instance;
    }
    private async transitionToFollowing(instance: PetBallInstance): Promise<PetBallInstance> {
        const newInstance = copyInstance(instance);
        newInstance.state = 'following';
        newInstance.lastInteractionTime = Date.now();
        await this.storageAdapter.saveInstanceState(newInstance);
        console.info(`Instance ${instance.id} transitioned to following state`);
        return newInstance;
    }
    private async transitionToNormal(instance: PetBallInstance): Promise<PetBallInstance> {
        const newInstance = copyInstance(instance);
        newInstance.state = 'normal';
        newInstance.lastInteractionTime = Date.now();
        await this.storageAdapter.saveInstanceState(newInstance);
        console.info(`Instance ${instance.id} transitioned to normal state`);
        return newInstance;
    }
    async updateFollowingTarget(instance: PetBallInstance, targetPosition: Position): Promise<PetBallInstance> {
        if (instance.state !== 'following') {
            return instance;
        }
        const dx = targetPosition.x - instance.position.x;
        const dy = targetPosition.y - instance.position.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        const speedCoefficient = 0.1;
        const speed = Math.min(distance * speedCoefficient, 200);
        const newInstance = copyInstance(instance);
        const newVelocity: Velocity = {
            vx: (dx / distance) * speed,
            vy: (dy / distance) * speed,
            speed: speed
        };
        newInstance.velocity = newVelocity;
        return newInstance;
    }
    isFollowing(instance: PetBallInstance): boolean {
        return instance.state === 'following';
    }
    setFollowingThreshold(threshold: number): void {
        this.followingThreshold = threshold;
    }
    getFollowingThreshold(): number {
        return this.followingThreshold;
    }
    async saveInstanceState(instance: PetBallInstance): Promise<void> {
        await this.storageAdapter.saveInstanceState(instance);
    }
    async loadInstanceState(instanceId: string): Promise<PetBallInstance | null> {
        return await this.storageAdapter.loadInstanceState(instanceId);
    }
}
