import dataPreferences from '@ohos.data.preferences';
import { Backpack, Gift } from './DataModels';

const BACKPACK_STORE_NAME = 'pet_ball_backpack';

export class BackpackDataDAO {
  private preferences: dataPreferences.Preferences | null = null;

  async init(context: Context): Promise<void> {
    try {
      this.preferences = await dataPreferences.getPreferences(context, BACKPACK_STORE_NAME);
    } catch (error) {
      console.error('BackpackDataDAO init failed:', error);
      throw error;
    }
  }

  async saveBackpack(backpack: Backpack): Promise<boolean> {
    if (!this.preferences) {
      console.error('Preferences not initialized');
      return false;
    }

    try {
      const giftsObj: Record<string, number> = {};
      backpack.gifts.forEach((count, giftId) => {
        giftsObj[giftId] = count;
      });
      
      const backpackData = {
        gifts: giftsObj,
        lastUpdateTime: backpack.lastUpdateTime
      };
      
      const dataStr = JSON.stringify(backpackData);
      await this.preferences.put('backpack', dataStr);
      await this.preferences.flush();
      return true;
    } catch (error) {
      console.error('Save backpack failed:', error);
      return false;
    }
  }

  async loadBackpack(): Promise<Backpack | null> {
    if (!this.preferences) {
      console.error('Preferences not initialized');
      return null;
    }

    try {
      const dataStr = await this.preferences.get('backpack', '');
      
      if (dataStr === '') {
        return this.getDefaultBackpack();
      }
      
      const backpackData = JSON.parse(dataStr as string);
      const gifts = new Map<string, number>();
      
      for (const giftId in backpackData.gifts) {
        gifts.set(giftId, backpackData.gifts[giftId]);
      }
      
      return {
        gifts: gifts,
        lastUpdateTime: backpackData.lastUpdateTime
      };
    } catch (error) {
      console.error('Load backpack failed:', error);
      return this.getDefaultBackpack();
    }
  }

  async updateGiftCount(giftId: string, count: number): Promise<boolean> {
    const backpack = await this.loadBackpack();
    if (!backpack) {
      return false;
    }

    backpack.gifts.set(giftId, count);
    backpack.lastUpdateTime = Date.now();
    
    return await this.saveBackpack(backpack);
  }

  async addGift(giftId: string, count: number = 1): Promise<boolean> {
    const backpack = await this.loadBackpack();
    if (!backpack) {
      return false;
    }

    const currentCount = backpack.gifts.get(giftId) || 0;
    backpack.gifts.set(giftId, currentCount + count);
    backpack.lastUpdateTime = Date.now();
    
    return await this.saveBackpack(backpack);
  }

  async removeGift(giftId: string, count: number = 1): Promise<boolean> {
    const backpack = await this.loadBackpack();
    if (!backpack) {
      return false;
    }

    const currentCount = backpack.gifts.get(giftId) || 0;
    const newCount = Math.max(0, currentCount - count);
    
    if (newCount === 0) {
      backpack.gifts.delete(giftId);
    } else {
      backpack.gifts.set(giftId, newCount);
    }
    
    backpack.lastUpdateTime = Date.now();
    return await this.saveBackpack(backpack);
  }

  private getDefaultBackpack(): Backpack {
    return {
      gifts: new Map<string, number>(),
      lastUpdateTime: Date.now()
    };
  }
}