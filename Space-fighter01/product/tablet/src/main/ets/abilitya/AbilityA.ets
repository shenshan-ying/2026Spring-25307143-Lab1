/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { AbilityConstant, ConfigurationConstant, UIAbility, Want, wantConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

interface GameState {
  gameMode?: Object;
  gameScore?: Object;
  gamePlayerHP?: Object;
  gamePlayerX?: Object;
  gamePlayerY?: Object;
  gameEnemies?: Object;
  gameBullets?: Object;
  gameStatus?: Object;
  gameCurrentLevel?: Object;
  gameLevelKills?: Object;
  gameLevelTarget?: Object;
  gameInvincible?: Object;
}

export default class AbilityA extends UIAbility {
  // Indicates whether Router page stack restore is enabled on target side.
  SUPPORT_CONTINUE_PAGE_STACK_KEY: boolean = true;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      // Keep default system color mode behavior.
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
        // Restore continuation payload and stack snapshot on cold start continuation.
        this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
          console.info(`setMissionContinueState: ${JSON.stringify(result)}`);
        });
        if (want.parameters !== undefined) {
          if (typeof want.parameters.data === 'string') {
            AppStorage.setOrCreate('entryAbilityContext', want.parameters.data);
          }
          if (Array.isArray(want.parameters.navPathStack)) {
            AppStorage.setOrCreate('NavPathInfo', want.parameters.navPathStack as Array<NavPathInfo>);
          } else {
            AppStorage.setOrCreate('NavPathInfo', []);
          }
          if (typeof want.parameters['ohos.extra.param.key.supportContinuePageStack'] === 'boolean') {
            this.SUPPORT_CONTINUE_PAGE_STACK_KEY =
              want.parameters['ohos.extra.param.key.supportContinuePageStack'] as boolean;
          }
          // Restore game state from continuation
          if (typeof want.parameters.gameState === 'string') {
            try {
              const gameState: GameState = JSON.parse(want.parameters.gameState as string) as GameState;
              if (gameState.gameMode !== undefined) AppStorage.setOrCreate('gameMode', gameState.gameMode as Object);
              if (gameState.gameScore !== undefined) AppStorage.setOrCreate('gameScore', gameState.gameScore as Object);
              if (gameState.gamePlayerHP !== undefined) AppStorage.setOrCreate('gamePlayerHP', gameState.gamePlayerHP as Object);
              if (gameState.gamePlayerX !== undefined) AppStorage.setOrCreate('gamePlayerX', gameState.gamePlayerX as Object);
              if (gameState.gamePlayerY !== undefined) AppStorage.setOrCreate('gamePlayerY', gameState.gamePlayerY as Object);
              if (gameState.gameEnemies !== undefined) AppStorage.setOrCreate('gameEnemies', gameState.gameEnemies as Object);
              if (gameState.gameBullets !== undefined) AppStorage.setOrCreate('gameBullets', gameState.gameBullets as Object);
              if (gameState.gameStatus !== undefined) AppStorage.setOrCreate('gameStatus', gameState.gameStatus as Object);
              if (gameState.gameCurrentLevel !== undefined) AppStorage.setOrCreate('gameCurrentLevel', gameState.gameCurrentLevel as Object);
              if (gameState.gameLevelKills !== undefined) AppStorage.setOrCreate('gameLevelKills', gameState.gameLevelKills as Object);
              if (gameState.gameLevelTarget !== undefined) AppStorage.setOrCreate('gameLevelTarget', gameState.gameLevelTarget as Object);
              if (gameState.gameInvincible !== undefined) AppStorage.setOrCreate('gameInvincible', gameState.gameInvincible as Object);
            } catch (err) {
              hilog.error(DOMAIN, 'testTag', 'Failed to parse game state: %{public}s', JSON.stringify(err));
            }
          }
        }
        // Rebuild window stage from continuation data.
        this.context.restoreWindowStage(new LocalStorage());
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
        console.info(`setMissionContinueState: ${JSON.stringify(result)}`);
      });
      if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
        // Handle warm continuation when ability is already running.
        if (want.parameters !== undefined) {
          if (typeof want.parameters.data === 'string') {
            AppStorage.setOrCreate('entryAbilityContext', want.parameters.data);
          }
          if (Array.isArray(want.parameters.navPathStack)) {
            AppStorage.setOrCreate('NavPathInfo', want.parameters.navPathStack as Array<NavPathInfo>);
          } else {
            AppStorage.setOrCreate('NavPathInfo', []);
          }
          if (typeof want.parameters['ohos.extra.param.key.supportContinuePageStack'] === 'boolean') {
            this.SUPPORT_CONTINUE_PAGE_STACK_KEY =
              want.parameters['ohos.extra.param.key.supportContinuePageStack'] as boolean;
          }
          // Restore game state from continuation
          if (typeof want.parameters.gameState === 'string') {
            try {
              const gameState: GameState = JSON.parse(want.parameters.gameState as string) as GameState;
              if (gameState.gameMode !== undefined) AppStorage.setOrCreate('gameMode', gameState.gameMode as Object);
              if (gameState.gameScore !== undefined) AppStorage.setOrCreate('gameScore', gameState.gameScore as Object);
              if (gameState.gamePlayerHP !== undefined) AppStorage.setOrCreate('gamePlayerHP', gameState.gamePlayerHP as Object);
              if (gameState.gamePlayerX !== undefined) AppStorage.setOrCreate('gamePlayerX', gameState.gamePlayerX as Object);
              if (gameState.gamePlayerY !== undefined) AppStorage.setOrCreate('gamePlayerY', gameState.gamePlayerY as Object);
              if (gameState.gameEnemies !== undefined) AppStorage.setOrCreate('gameEnemies', gameState.gameEnemies as Object);
              if (gameState.gameBullets !== undefined) AppStorage.setOrCreate('gameBullets', gameState.gameBullets as Object);
              if (gameState.gameStatus !== undefined) AppStorage.setOrCreate('gameStatus', gameState.gameStatus as Object);
              if (gameState.gameCurrentLevel !== undefined) AppStorage.setOrCreate('gameCurrentLevel', gameState.gameCurrentLevel as Object);
              if (gameState.gameLevelKills !== undefined) AppStorage.setOrCreate('gameLevelKills', gameState.gameLevelKills as Object);
              if (gameState.gameLevelTarget !== undefined) AppStorage.setOrCreate('gameLevelTarget', gameState.gameLevelTarget as Object);
              if (gameState.gameInvincible !== undefined) AppStorage.setOrCreate('gameInvincible', gameState.gameInvincible as Object);
            } catch (err) {
              hilog.error(DOMAIN, 'testTag', 'Failed to parse game state: %{public}s', JSON.stringify(err));
            }
          }
        }
        this.context.restoreWindowStage(new LocalStorage());
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onNewWant   ');
  }

  onContinue(wantParam: Record<string, Object>) {
    // Validate target version before sending continuation payload.
    const targetVersion = wantParam.version;
    const versionThreshold: number = 1000;
    if (targetVersion < versionThreshold) {
      // Explain mismatch reason to end users.
      this.context.windowStage.getMainWindowSync()
        .getUIContext()
        .getPromptAction()
        .showToast({
          message: '目标端应用版本号过低，不支持接续，请您升级应用版本后再试',
          duration: 2000
        })
      // Return MISMATCH to terminate continuation negotiation.
      return AbilityConstant.OnContinueResult.MISMATCH;
    }
    // Export text payload for target-side restore.
    const continueInput = AppStorage.get('entryAbilityContext') as string;
    if (continueInput) {
      wantParam['data'] = continueInput;
    }
    let pathStack = new NavPathStack();
    if (AppStorage.get('ifContinueNaviPage') as boolean) {
      pathStack = AppStorage.get('navPathStack') as NavPathStack;
    }
    // Export Navigation stack snapshot and continuation behavior flags.
    let NavPathInfo = pathStack.getPathStack();
    wantParam['navPathStack'] = NavPathInfo;
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] =
      AppStorage.get('entryAbilityContinueExit') as boolean;
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_PAGE_STACK_KEY] = AppStorage.get('ifContinueRouterPage') as boolean;
    // Pack game state for continuation
    const gameState: GameState = {
      gameMode: AppStorage.get('gameMode') as Object,
      gameScore: AppStorage.get('gameScore') as Object,
      gamePlayerHP: AppStorage.get('gamePlayerHP') as Object,
      gamePlayerX: AppStorage.get('gamePlayerX') as Object,
      gamePlayerY: AppStorage.get('gamePlayerY') as Object,
      gameEnemies: AppStorage.get('gameEnemies') as Object,
      gameBullets: AppStorage.get('gameBullets') as Object,
      gameStatus: AppStorage.get('gameStatus') as Object,
      gameCurrentLevel: AppStorage.get('gameCurrentLevel') as Object,
      gameLevelKills: AppStorage.get('gameLevelKills') as Object,
      gameLevelTarget: AppStorage.get('gameLevelTarget') as Object,
      gameInvincible: AppStorage.get('gameInvincible') as Object
    };
    wantParam['gameState'] = JSON.stringify(gameState);
    return AbilityConstant.OnContinueResult.AGREE;
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageRestore(windowStage: window.WindowStage) {
    // Fallback to Index page when Router stack restore is not requested.
    if (!this.SUPPORT_CONTINUE_PAGE_STACK_KEY) {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      });
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
