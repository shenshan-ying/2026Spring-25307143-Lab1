/*
 * Copyright (c) 2026
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

import { GameDataSync, GameRecord } from '../utils/GameDataSync';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'GameModePage';

@Component
export struct GameModePage {
  @Consume navPathStack: NavPathStack;
  private context: common.UIAbilityContext | null = null;
  private dataSync: GameDataSync | null = null;
  @State private record: GameRecord = {
    highScore: 0,
    highestLevel: 0,
    totalKills: 0,
    totalKillsLow: 0,
    totalKillsMid: 0,
    totalKillsHigh: 0,
    endlessBestScore: 0
  };
  @State private recordLoaded: boolean = false;

  aboutToAppear() {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (this.context) {
      this.dataSync = new GameDataSync(this.context);
      this.dataSync.initKVStore().then(() => {
        if (this.dataSync) {
          this.dataSync.loadGameRecord().then((rec) => {
            this.record = rec;
            this.recordLoaded = true;
          });
        }
      });
    }
  }

  private startGame(mode: string): void {
    // Reset game state for fresh start
    AppStorage.setOrCreate('gameMode', mode);
    AppStorage.setOrCreate('gameScore', 0);
    AppStorage.setOrCreate('gamePlayerHP', 5);
    AppStorage.setOrCreate('gamePlayerX', 0);
    AppStorage.setOrCreate('gamePlayerY', 0);
    AppStorage.setOrCreate('gameEnemies', '[]');
    AppStorage.setOrCreate('gameBullets', '[]');
    AppStorage.setOrCreate('gameStatus', 'playing');
    AppStorage.setOrCreate('gameCurrentLevel', 1);
    AppStorage.setOrCreate('gameLevelKills', 0);
    AppStorage.setOrCreate('gameLevelTarget', 8);
    AppStorage.setOrCreate('gameInvincible', false);

    this.navPathStack.pushPath({ name: 'gamePage' });
  }

  build() {
    NavDestination() {
      Column() {
        // Title
        Text('🎮 飞行战机')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ top: 40, bottom: 8 })

        Text('跨设备空中对决')
          .fontSize(16)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ bottom: 32 })

        // Mode cards
        Column() {
          // Level Mode Card
          Column() {
            Row() {
              Text('🎯')
                .fontSize(40)
                .margin({ right: 16 })
              Column() {
                Text('关卡模式')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                Text('逐关挑战，难度递增')
                  .fontSize(14)
                  .fontColor('rgba(255,255,255,0.6)')
                  .margin({ top: 4 })
              }
              Blank()
              Text('▶')
                .fontSize(24)
                .fontColor('rgba(255,255,255,0.4)')
            }
            .width('100%')
            .padding(20)

            if (this.recordLoaded && this.record.highestLevel > 0) {
              Row() {
                Text('🏆 最高关卡: 第' + this.record.highestLevel + '关')
                  .fontSize(13)
                  .fontColor('#FFD740')
              }
              .width('100%')
              .padding({ left: 20, right: 20, bottom: 16 })
            }
          }
          .width('100%')
          .backgroundColor('rgba(33,150,243,0.15)')
          .borderRadius(16)
          .border({ width: 1, color: 'rgba(33,150,243,0.3)' })
          .margin({ bottom: 16 })
          .onClick(() => {
            this.startGame('level');
          })

          // Endless Mode Card
          Column() {
            Row() {
              Text('♾️')
                .fontSize(40)
                .margin({ right: 16 })
              Column() {
                Text('无尽模式')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                Text('挑战生存极限')
                  .fontSize(14)
                  .fontColor('rgba(255,255,255,0.6)')
                  .margin({ top: 4 })
              }
              Blank()
              Text('▶')
                .fontSize(24)
                .fontColor('rgba(255,255,255,0.4)')
            }
            .width('100%')
            .padding(20)

            if (this.recordLoaded && this.record.endlessBestScore > 0) {
              Row() {
                Text('🏆 最高分: ' + this.record.endlessBestScore)
                  .fontSize(13)
                  .fontColor('#FFD740')
              }
              .width('100%')
              .padding({ left: 20, right: 20, bottom: 16 })
            }
          }
          .width('100%')
          .backgroundColor('rgba(255,87,34,0.15)')
          .borderRadius(16)
          .border({ width: 1, color: 'rgba(255,87,34,0.3)' })
          .margin({ bottom: 16 })
          .onClick(() => {
            this.startGame('endless');
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })

        // Global records
        if (this.recordLoaded && (this.record.highScore > 0 || this.record.totalKills > 0)) {
          Column() {
            Text('📊 全局记录')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('rgba(255,255,255,0.7)')
              .margin({ bottom: 12 })

            if (this.record.highScore > 0) {
              RecordRow({ label: '最高得分', value: String(this.record.highScore) })
            }
            if (this.record.totalKills > 0) {
              RecordRow({ label: '累计击毁', value: String(this.record.totalKills) })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor('rgba(255,255,255,0.05)')
          .borderRadius(16)
          .margin({ left: 24, right: 24, top: 8 })
        }

        Blank()

        // Hint
        Text('登录同一华为账号，游戏数据自动同步')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.3)')
          .margin({ bottom: 24 })
      }
      .width('100%')
      .height('100%')
      .background('linear-gradient(180deg, #0a0a2e 0%, #1a1a4e 100%)')
    }
    .title('')
    .backgroundColor('#0a0a2e')
    .onBackPressed(() => {
      this.navPathStack.setPathStack([]);
      return true;
    })
  }
}

@Component
struct RecordRow {
  @Prop label: string = '';
  @Prop value: string = '';

  build() {
    Row() {
      Text(this.label)
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.6)')
      Blank()
      Text(this.value)
        .fontSize(14)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .margin({ bottom: 8 })
  }
}
