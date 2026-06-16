import { StorageServiceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/adapter/StorageServiceAdapter";
import type { AppConfig } from '../dao/DataModels';
import type common from "@ohos:app.ability.common";
export class ConfigManager {
    private storageAdapter: StorageServiceAdapter;
    private config: AppConfig | null = null;
    private isInitialized: boolean = false;
    constructor() {
        this.storageAdapter = new StorageServiceAdapter();
    }
    async init(context: common.Context): Promise<void> {
        await this.storageAdapter.init(context);
        await this.loadConfig();
        this.isInitialized = true;
    }
    async loadConfig(): Promise<AppConfig | null> {
        this.config = await this.storageAdapter.loadConfig();
        return this.config;
    }
    async saveConfig(): Promise<boolean> {
        if (!this.config) {
            return false;
        }
        return await this.storageAdapter.saveConfig(this.config);
    }
    getConfig(): AppConfig | null {
        return this.config;
    }
    async updateConfig(updates: Partial<AppConfig>): Promise<boolean> {
        if (!this.config) {
            return false;
        }
        const newConfig: AppConfig = {
            motionMode: updates.motionMode !== undefined ? updates.motionMode : this.config.motionMode,
            motionSpeed: updates.motionSpeed !== undefined ? updates.motionSpeed : this.config.motionSpeed,
            judgmentLinePosition: updates.judgmentLinePosition !== undefined ? updates.judgmentLinePosition : this.config.judgmentLinePosition,
            petBallSizeCoefficient: updates.petBallSizeCoefficient !== undefined ? updates.petBallSizeCoefficient : this.config.petBallSizeCoefficient,
            version: updates.version !== undefined ? updates.version : this.config.version
        };
        this.config = newConfig;
        return await this.saveConfig();
    }
    getMotionMode(): 'free_rolling' | 'static' | 'slingshot' | 'following' {
        return this.config?.motionMode || 'free_rolling';
    }
    async setMotionMode(mode: 'free_rolling' | 'static' | 'slingshot' | 'following'): Promise<boolean> {
        return await this.updateConfig({ motionMode: mode });
    }
    getMotionSpeed(): number {
        return this.config?.motionSpeed || 500;
    }
    async setMotionSpeed(speed: number): Promise<boolean> {
        const validatedSpeed = Math.max(100, Math.min(2000, speed));
        return await this.updateConfig({ motionSpeed: validatedSpeed });
    }
    getJudgmentLinePosition(): 'bottom' | 'top' | 'left' | 'right' {
        return this.config?.judgmentLinePosition || 'bottom';
    }
    async setJudgmentLinePosition(position: 'bottom' | 'top' | 'left' | 'right'): Promise<boolean> {
        return await this.updateConfig({ judgmentLinePosition: position });
    }
    getPetBallSizeCoefficient(): number {
        return this.config?.petBallSizeCoefficient || 1.0;
    }
    async setPetBallSizeCoefficient(coefficient: number): Promise<boolean> {
        const validatedCoefficient = Math.max(0.5, Math.min(2.0, coefficient));
        return await this.updateConfig({ petBallSizeCoefficient: validatedCoefficient });
    }
    getVersion(): string {
        return this.config?.version || '1.0.0';
    }
    async migrateConfig(newVersion: string): Promise<boolean> {
        const oldVersion = this.getVersion();
        if (oldVersion === newVersion) {
            return true;
        }
        const success = await this.storageAdapter.migrateAllData(oldVersion, newVersion);
        if (success) {
            await this.updateConfig({ version: newVersion });
        }
        return success;
    }
    async resetToDefault(): Promise<boolean> {
        this.config = {
            motionMode: 'free_rolling',
            motionSpeed: 500,
            judgmentLinePosition: 'bottom',
            petBallSizeCoefficient: 1.0,
            version: '1.0.0'
        };
        return await this.saveConfig();
    }
    isReady(): boolean {
        return this.isInitialized && this.config !== null;
    }
}
