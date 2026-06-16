import type { AffectionData } from '../dao/DataModels';
import { TimerServiceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/adapter/TimerServiceAdapter";
import { StorageServiceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/adapter/StorageServiceAdapter";
export class CultivationManager {
    private timerAdapter: TimerServiceAdapter;
    private storageAdapter: StorageServiceAdapter;
    private affectionData: Map<string, AffectionData> = new Map();
    private accumulateInterval: number = 300000; // 5分钟
    private accumulateValue: number = 1;
    constructor() {
        this.timerAdapter = new TimerServiceAdapter();
        this.storageAdapter = new StorageServiceAdapter();
    }
    async init(context: Context): Promise<void> {
        await this.storageAdapter.init(context);
        this.startAccumulationTimer();
    }
    private startAccumulationTimer(): void {
        this.timerAdapter.createAffectionTimer(() => {
            this.accumulateAffectionForAll();
        }, this.accumulateInterval);
        this.timerAdapter.startAffectionTimer();
    }
    private async accumulateAffectionForAll(): Promise<void> {
        this.affectionData.forEach(async (data: AffectionData, instanceId: string) => {
            data.value += this.accumulateValue;
            data.lastAccumulateTime = Date.now();
            data.level = Math.floor(data.value / 1000) + 1;
            await this.storageAdapter.saveAffection(data);
            console.info(`Accumulated affection for ${instanceId}: ${data.value}`);
        });
    }
    async loadAffection(instanceId: string): Promise<AffectionData> {
        let data = this.affectionData.get(instanceId);
        if (!data) {
            const storedData = await this.storageAdapter.loadAffection(instanceId);
            if (storedData) {
                data = storedData;
            }
            else {
                data = {
                    instanceId: instanceId,
                    value: 0,
                    level: 1,
                    lastAccumulateTime: Date.now(),
                    followingThreshold: 100
                };
            }
            this.affectionData.set(instanceId, data);
        }
        return data;
    }
    async addAffection(instanceId: string, value: number): Promise<void> {
        const data = await this.loadAffection(instanceId);
        data.value += value;
        data.level = Math.floor(data.value / 1000) + 1;
        this.affectionData.set(instanceId, data);
        await this.storageAdapter.saveAffection(data);
    }
    async setAffection(instanceId: string, value: number): Promise<void> {
        const data = await this.loadAffection(instanceId);
        data.value = Math.max(0, value);
        data.level = Math.floor(data.value / 1000) + 1;
        this.affectionData.set(instanceId, data);
        await this.storageAdapter.saveAffection(data);
    }
    getAffection(instanceId: string): number {
        const data = this.affectionData.get(instanceId);
        return data?.value || 0;
    }
    getLevel(instanceId: string): number {
        const data = this.affectionData.get(instanceId);
        return data?.level || 1;
    }
    isFollowingState(instanceId: string): boolean {
        const data = this.affectionData.get(instanceId);
        return (data?.value || 0) >= (data?.followingThreshold || 100);
    }
    async clearAffection(instanceId: string): Promise<void> {
        this.affectionData.delete(instanceId);
        await this.storageAdapter.clearAffection(instanceId);
    }
    setAccumulateInterval(interval: number): void {
        this.accumulateInterval = interval;
        this.timerAdapter.stopAffectionTimer();
        this.startAccumulationTimer();
    }
    setAccumulateValue(value: number): void {
        this.accumulateValue = value;
    }
    stopAccumulation(): void {
        this.timerAdapter.stopAffectionTimer();
    }
    resumeAccumulation(): void {
        this.timerAdapter.startAffectionTimer();
    }
    async saveAllAffection(): Promise<void> {
        this.affectionData.forEach(async (data: AffectionData) => {
            await this.storageAdapter.saveAffection(data);
        });
    }
}
