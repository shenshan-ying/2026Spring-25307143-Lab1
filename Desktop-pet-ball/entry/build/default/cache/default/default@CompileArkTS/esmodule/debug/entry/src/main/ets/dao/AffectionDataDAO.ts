import dataPreferences from "@ohos:data.preferences";
import type { AffectionData } from './DataModels';
const AFFECTION_STORE_NAME = 'pet_ball_affection';
export class AffectionDataDAO {
    private preferences: dataPreferences.Preferences | null = null;
    async init(context: Context): Promise<void> {
        try {
            this.preferences = await dataPreferences.getPreferences(context, AFFECTION_STORE_NAME);
        }
        catch (error) {
            const err = error as Error;
            console.error('AffectionDataDAO init failed:', err.message);
            throw new Error(err.message);
        }
    }
    async saveAffection(data: AffectionData): Promise<boolean> {
        if (!this.preferences) {
            console.error('Preferences not initialized');
            return false;
        }
        try {
            const key = `affection_${data.instanceId}`;
            const dataStr = JSON.stringify(data);
            await this.preferences.put(key, dataStr);
            await this.preferences.flush();
            return true;
        }
        catch (error) {
            console.error('Save affection failed:', error);
            return false;
        }
    }
    async loadAffection(instanceId: string): Promise<AffectionData | null> {
        if (!this.preferences) {
            console.error('Preferences not initialized');
            return null;
        }
        try {
            const key = `affection_${instanceId}`;
            const dataStr = await this.preferences.get(key, '');
            if (dataStr === '') {
                return this.getDefaultAffection(instanceId);
            }
            return JSON.parse(dataStr as string) as AffectionData;
        }
        catch (error) {
            console.error('Load affection failed:', error);
            return this.getDefaultAffection(instanceId);
        }
    }
    async clearAffection(instanceId: string): Promise<boolean> {
        if (!this.preferences) {
            console.error('Preferences not initialized');
            return false;
        }
        try {
            const key = `affection_${instanceId}`;
            await this.preferences.delete(key);
            await this.preferences.flush();
            return true;
        }
        catch (error) {
            console.error('Clear affection failed:', error);
            return false;
        }
    }
    async clearAllAffection(): Promise<boolean> {
        if (!this.preferences) {
            console.error('Preferences not initialized');
            return false;
        }
        try {
            await this.preferences.clear();
            await this.preferences.flush();
            return true;
        }
        catch (error) {
            console.error('Clear all affection failed:', error);
            return false;
        }
    }
    private getDefaultAffection(instanceId: string): AffectionData {
        return {
            instanceId: instanceId,
            value: 0,
            level: 1,
            lastAccumulateTime: Date.now(),
            followingThreshold: 100
        };
    }
    async migrateAffectionData(oldVersion: string, newVersion: string): Promise<boolean> {
        console.info(`Migrating affection data from ${oldVersion} to ${newVersion}`);
        return true;
    }
}
