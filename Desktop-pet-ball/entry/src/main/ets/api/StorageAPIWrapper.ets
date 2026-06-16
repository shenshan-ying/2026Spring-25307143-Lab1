import dataPreferences from '@ohos.data.preferences';

export class StorageAPIWrapper {
  private context: Context | null = null;
  private preferencesMap: Map<string, dataPreferences.Preferences> = new Map();

  init(context: Context): void {
    this.context = context;
  }

  async getPreferences(storeName: string): Promise<dataPreferences.Preferences | null> {
    if (!this.context) {
      console.error('Context not initialized');
      return null;
    }

    try {
      let preferences = this.preferencesMap.get(storeName);
      if (!preferences) {
        preferences = await dataPreferences.getPreferences(this.context, storeName);
        this.preferencesMap.set(storeName, preferences);
      }
      return preferences;
    } catch (error) {
      console.error('Get preferences failed:', error);
      return null;
    }
  }

  async putData(
    storeName: string,
    key: string,
    value: dataPreferences.ValueType
  ): Promise<boolean> {
    const preferences = await this.getPreferences(storeName);
    if (!preferences) {
      return false;
    }

    try {
      await preferences.put(key, value);
      await preferences.flush();
      return true;
    } catch (error) {
      console.error('Put data failed:', error);
      return false;
    }
  }

  async getData(
    storeName: string,
    key: string,
    defaultValue: dataPreferences.ValueType
  ): Promise<dataPreferences.ValueType> {
    const preferences = await this.getPreferences(storeName);
    if (!preferences) {
      return defaultValue;
    }

    try {
      return await preferences.get(key, defaultValue);
    } catch (error) {
      console.error('Get data failed:', error);
      return defaultValue;
    }
  }

  async deleteData(storeName: string, key: string): Promise<boolean> {
    const preferences = await this.getPreferences(storeName);
    if (!preferences) {
      return false;
    }

    try {
      await preferences.delete(key);
      await preferences.flush();
      return true;
    } catch (error) {
      console.error('Delete data failed:', error);
      return false;
    }
  }

  async clearStore(storeName: string): Promise<boolean> {
    const preferences = await this.getPreferences(storeName);
    if (!preferences) {
      return false;
    }

    try {
      await preferences.clear();
      await preferences.flush();
      return true;
    } catch (error) {
      console.error('Clear store failed:', error);
      return false;
    }
  }

  async migrateData(
    storeName: string,
    oldVersion: string,
    newVersion: string,
    migrateCallback: (preferences: dataPreferences.Preferences) => Promise<boolean>
  ): Promise<boolean> {
    const preferences = await this.getPreferences(storeName);
    if (!preferences) {
      return false;
    }

    try {
      const success = await migrateCallback(preferences);
      if (success) {
        await preferences.flush();
      }
      return success;
    } catch (error) {
      console.error('Migrate data failed:', error);
      return false;
    }
  }
}