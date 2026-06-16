import dataPreferences from "@ohos:data.preferences";
import type { PetBallInstance } from './DataModels';
const STATE_STORE_NAME = 'pet_ball_state';
export class StateDataDAO {
    private preferences: dataPreferences.Preferences | null = null;
    async init(context: Context): Promise<void> {
        try {
            this.preferences = await dataPreferences.getPreferences(context, STATE_STORE_NAME);
        }
        catch (error) {
            const err = error as Error;
            console.error('StateDataDAO init failed:', err.message);
            throw new Error(err.message);
        }
    }
    async saveInstanceState(instance: PetBallInstance): Promise<boolean> {
        if (!this.preferences) {
            console.error('Preferences not initialized');
            return false;
        }
        try {
            const key = `instance_${instance.id}`;
            const dataStr = JSON.stringify(instance);
            await this.preferences.put(key, dataStr);
            await this.preferences.flush();
            return true;
        }
        catch (error) {
            console.error('Save instance state failed:', error);
            return false;
        }
    }
    async loadInstanceState(instanceId: string): Promise<PetBallInstance | null> {
        if (!this.preferences) {
            console.error('Preferences not initialized');
            return null;
        }
        try {
            const key = `instance_${instanceId}`;
            const dataStr = await this.preferences.get(key, '');
            if (dataStr === '') {
                return null;
            }
            return JSON.parse(dataStr as string) as PetBallInstance;
        }
        catch (error) {
            console.error('Load instance state failed:', error);
            return null;
        }
    }
    async saveAllInstances(instances: PetBallInstance[]): Promise<boolean> {
        if (!this.preferences) {
            console.error('Preferences not initialized');
            return false;
        }
        try {
            const instanceIds: string[] = [];
            for (const instance of instances) {
                const key = `instance_${instance.id}`;
                const dataStr = JSON.stringify(instance);
                await this.preferences.put(key, dataStr);
                instanceIds.push(instance.id);
            }
            await this.preferences.put('instance_ids', JSON.stringify(instanceIds));
            await this.preferences.flush();
            return true;
        }
        catch (error) {
            console.error('Save all instances failed:', error);
            return false;
        }
    }
    async loadAllInstances(): Promise<PetBallInstance[]> {
        if (!this.preferences) {
            console.error('Preferences not initialized');
            return [];
        }
        try {
            const instanceIdsStr = await this.preferences.get('instance_ids', '[]');
            const instanceIds = JSON.parse(instanceIdsStr as string) as string[];
            const instances: PetBallInstance[] = [];
            for (const instanceId of instanceIds) {
                const instance = await this.loadInstanceState(instanceId);
                if (instance) {
                    instances.push(instance);
                }
            }
            return instances;
        }
        catch (error) {
            console.error('Load all instances failed:', error);
            return [];
        }
    }
    async clearInstanceState(instanceId: string): Promise<boolean> {
        if (!this.preferences) {
            console.error('Preferences not initialized');
            return false;
        }
        try {
            const key = `instance_${instanceId}`;
            await this.preferences.delete(key);
            const instanceIdsStr = await this.preferences.get('instance_ids', '[]');
            const instanceIds = JSON.parse(instanceIdsStr as string) as string[];
            const newIds = instanceIds.filter(id => id !== instanceId);
            await this.preferences.put('instance_ids', JSON.stringify(newIds));
            await this.preferences.flush();
            return true;
        }
        catch (error) {
            console.error('Clear instance state failed:', error);
            return false;
        }
    }
    async clearAllInstances(): Promise<boolean> {
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
            console.error('Clear all instances failed:', error);
            return false;
        }
    }
    async migrateStateData(oldVersion: string, newVersion: string): Promise<boolean> {
        console.info(`Migrating state data from ${oldVersion} to ${newVersion}`);
        return true;
    }
}
