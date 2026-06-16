import dataPreferences from '@ohos.data.preferences';
import { AppConfig } from './DataModels';

const CONFIG_STORE_NAME = 'pet_ball_config';
const CONFIG_KEY = 'app_config';

export class ConfigDataDAO {
  private preferences: dataPreferences.Preferences | null = null;
  private context: Context | null = null;

  async init(context: Context): Promise<void> {
    try {
      this.context = context;
      this.preferences = await dataPreferences.getPreferences(context, CONFIG_STORE_NAME);
    } catch (error) {
      const err = error as Error;
      console.error('ConfigDataDAO init failed:', err.message);
      throw new Error(err.message);
    }
  }

  async saveConfig(config: AppConfig): Promise<boolean> {
    if (!this.preferences) {
      console.error('Preferences not initialized');
      return false;
    }

    try {
      const configStr = JSON.stringify(config);
      await this.preferences.put(CONFIG_KEY, configStr);
      await this.preferences.flush();
      return true;
    } catch (error) {
      console.error('Save config failed:', error);
      return false;
    }
  }

  async loadConfig(): Promise<AppConfig | null> {
    if (!this.preferences) {
      console.error('Preferences not initialized');
      return null;
    }

    try {
      const configStr = await this.preferences.get(CONFIG_KEY, '');
      if (configStr === '') {
        return this.getDefaultConfig();
      }
      return JSON.parse(configStr as string) as AppConfig;
    } catch (error) {
      console.error('Load config failed:', error);
      return this.getDefaultConfig();
    }
  }

  async clearConfig(): Promise<boolean> {
    if (!this.preferences) {
      console.error('Preferences not initialized');
      return false;
    }

    try {
      await this.preferences.delete(CONFIG_KEY);
      await this.preferences.flush();
      return true;
    } catch (error) {
      console.error('Clear config failed:', error);
      return false;
    }
  }

  private getDefaultConfig(): AppConfig {
    return {
      motionMode: 'free_rolling',
      motionSpeed: 500,
      judgmentLinePosition: 'bottom',
      petBallSizeCoefficient: 1.0,
      version: '1.0.0'
    };
  }

  async migrateConfig(oldVersion: string, newVersion: string): Promise<boolean> {
    console.info(`Migrating config from ${oldVersion} to ${newVersion}`);
    return true;
  }
}