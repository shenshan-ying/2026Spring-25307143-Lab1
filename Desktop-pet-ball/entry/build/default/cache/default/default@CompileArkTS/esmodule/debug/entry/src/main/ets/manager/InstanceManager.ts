import type { PetBallInstance, Position, Velocity } from '../dao/DataModels';
import { StorageServiceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/adapter/StorageServiceAdapter";
import type { DeviceAdapter } from '../service/DeviceAdapter';
export class InstanceManager {
    private instances: Map<string, PetBallInstance> = new Map();
    private storageAdapter: StorageServiceAdapter;
    private deviceAdapter: DeviceAdapter;
    private maxInstances: number = 5;
    constructor(deviceAdapter: DeviceAdapter) {
        this.storageAdapter = new StorageServiceAdapter();
        this.deviceAdapter = deviceAdapter;
        this.maxInstances = deviceAdapter.getMaxInstanceCount();
    }
    async init(context: Context): Promise<void> {
        await this.storageAdapter.init(context);
        await this.loadInstances();
    }
    private async loadInstances(): Promise<void> {
        const instances = await this.storageAdapter.loadAllInstances();
        instances.forEach(instance => {
            this.instances.set(instance.id, instance);
        });
    }
    createInstance(resourceId: string, position: Position, velocity: Velocity = { vx: 0, vy: 0, speed: 0 }): PetBallInstance | null {
        if (this.instances.size >= this.maxInstances) {
            console.error('Maximum instance count reached');
            return null;
        }
        const id = this.generateInstanceId();
        const instance: PetBallInstance = {
            id: id,
            resourceId: resourceId,
            position: position,
            velocity: velocity,
            state: 'normal',
            affectionValue: 0,
            createdAt: Date.now(),
            lastInteractionTime: Date.now()
        };
        this.instances.set(id, instance);
        console.info(`Created instance ${id}`);
        return instance;
    }
    async destroyInstance(instanceId: string): Promise<boolean> {
        const instance = this.instances.get(instanceId);
        if (!instance) {
            return false;
        }
        this.instances.delete(instanceId);
        await this.storageAdapter.clearInstanceState(instanceId);
        console.info(`Destroyed instance ${instanceId}`);
        return true;
    }
    getInstance(instanceId: string): PetBallInstance | null {
        return this.instances.get(instanceId) || null;
    }
    getAllInstances(): PetBallInstance[] {
        return Array.from(this.instances.values());
    }
    async updateInstance(instance: PetBallInstance): Promise<void> {
        this.instances.set(instance.id, instance);
        await this.storageAdapter.saveInstanceState(instance);
    }
    async updateInstancePosition(instanceId: string, position: Position): Promise<void> {
        const instance = this.instances.get(instanceId);
        if (instance) {
            instance.position = position;
            await this.storageAdapter.saveInstanceState(instance);
        }
    }
    async updateInstanceVelocity(instanceId: string, velocity: Velocity): Promise<void> {
        const instance = this.instances.get(instanceId);
        if (instance) {
            instance.velocity = velocity;
            await this.storageAdapter.saveInstanceState(instance);
        }
    }
    getInstanceCount(): number {
        return this.instances.size;
    }
    canCreateInstance(): boolean {
        return this.instances.size < this.maxInstances;
    }
    private generateInstanceId(): string {
        return `instance_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
    async saveAllInstances(): Promise<void> {
        const instances = this.getAllInstances();
        await this.storageAdapter.saveAllInstances(instances);
    }
    async clearAllInstances(): Promise<void> {
        this.instances.clear();
        await this.storageAdapter.clearAllInstances();
    }
    getInstancesByState(state: 'normal' | 'following'): PetBallInstance[] {
        return this.getAllInstances().filter(instance => instance.state === state);
    }
    setMaxInstances(max: number): void {
        this.maxInstances = Math.max(1, Math.min(5, max));
    }
    getMaxInstances(): number {
        return this.maxInstances;
    }
}
