/*
 * Copyright (c) 2026
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

import { distributedKVStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const STORE_ID = 'game_data_sync_store';
const TAG = 'GameDataSync';

export interface GameRecord {
  highScore: number;
  highestLevel: number;
  totalKills: number;
  totalKillsLow: number;
  totalKillsMid: number;
  totalKillsHigh: number;
  endlessBestScore: number;
}

export class GameDataSync {
  private kvStore: distributedKVStore.SingleKVStore | null = null;
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async initKVStore(): Promise<void> {
    try {
      const kvManagerConfig: distributedKVStore.KVManagerConfig = {
        context: this.context,
        bundleName: 'com.example.continuesettings'
      };
      const kvManager = distributedKVStore.createKVManager(kvManagerConfig);
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S1
      };
      this.kvStore = await kvManager.getKVStore<distributedKVStore.SingleKVStore>(STORE_ID, options);
      hilog.info(DOMAIN, TAG, 'KVStore initialized successfully');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to init KVStore: %{public}s', JSON.stringify(err));
    }
  }

  async saveGameRecord(record: GameRecord): Promise<void> {
    if (!this.kvStore) {
      hilog.warn(DOMAIN, TAG, 'KVStore not initialized');
      return;
    }
    try {
      // Merge with existing data: take the max for competitive records
      const existing = await this.loadGameRecord();
      const merged: GameRecord = {
        highScore: Math.max(record.highScore, existing.highScore),
        highestLevel: Math.max(record.highestLevel, existing.highestLevel),
        totalKills: record.totalKills + existing.totalKills,
        totalKillsLow: record.totalKillsLow + existing.totalKillsLow,
        totalKillsMid: record.totalKillsMid + existing.totalKillsMid,
        totalKillsHigh: record.totalKillsHigh + existing.totalKillsHigh,
        endlessBestScore: Math.max(record.endlessBestScore, existing.endlessBestScore)
      };
      const dataStr = JSON.stringify(merged);
      await this.kvStore.put('game_record', dataStr);
      hilog.info(DOMAIN, TAG, 'Game record saved: %{public}s', dataStr);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to save game record: %{public}s', JSON.stringify(err));
    }
  }

  async loadGameRecord(): Promise<GameRecord> {
    const defaultRecord: GameRecord = {
      highScore: 0,
      highestLevel: 0,
      totalKills: 0,
      totalKillsLow: 0,
      totalKillsMid: 0,
      totalKillsHigh: 0,
      endlessBestScore: 0
    };
    if (!this.kvStore) {
      return defaultRecord;
    }
    try {
      const dataStr = await this.kvStore.get('game_record');
      if (dataStr) {
        const parsed = JSON.parse(dataStr as string) as GameRecord;
        return parsed;
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to load game record: %{public}s', JSON.stringify(err));
    }
    return defaultRecord;
  }
}
