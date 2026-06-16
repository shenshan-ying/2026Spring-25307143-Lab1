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

// [Start continue2]
// [Start continue3]
// [Start continue4]
// [Start continue8]
export default class EntryAbility extends UIAbility {
  // Indicates whether target side should restore Router page stack automatically.
  // [StartExclude continue2]
  // [StartExclude continue3]
  // [StartExclude continue4]
  SUPPORT_CONTINUE_PAGE_STACK_KEY: boolean = true;

  // [EndExclude continue3]
  // [Start continue11]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      // [StartExclude continue8]
      // [StartExclude continue11]
      // Keep system color mode unmanaged by the app.
      // [StartExclude continue3]
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      this.context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE, (result) => {
        hilog.info(0x0000, `setMissionContinueState ${AbilityConstant.ContinueState.INACTIVE} result: `,
          JSON.stringify(result));
      });
      // [EndExclude continue3]
      // [EndExclude continue8]
      // [EndExclude continue11]
      if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
        // Restore migration payload and stack snapshot from continuation parameters.
        this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
        });
        // [StartExclude continue11]
        if (want.parameters !== undefined) {
          // [StartExclude continue8]
          if (typeof want.parameters.data === 'string') {
            AppStorage.setOrCreate('entryAbilityContext', want.parameters.data);
          }
          // [StartExclude continue3]
          if (Array.isArray(want.parameters.navPathStack)) {
            AppStorage.setOrCreate('NavPathInfo', want.parameters.navPathStack as Array<NavPathInfo>);
          } else {
            AppStorage.setOrCreate('NavPathInfo', []);
          }
          // [EndExclude continue8]
          if (typeof want.parameters['ohos.extra.param.key.supportContinuePageStack'] === 'boolean') {
            this.SUPPORT_CONTINUE_PAGE_STACK_KEY =
              want.parameters['ohos.extra.param.key.supportContinuePageStack'] as boolean;
          }
          // [EndExclude continue3]
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
        // [EndExclude continue11]
        // Restore window stage so UI can reconstruct previous continuation state.
        this.context.restoreWindowStage(new LocalStorage());
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  // [StartExclude continue8]
  // [StartExclude continue3]
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      // Keep system color mode unmanaged by the app.
      // [StartExclude continue11]
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      // [EndExclude continue11]
      if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
        // Restore migration payload and stack snapshot from continuation parameters.
        this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
          hilog.info(DOMAIN, 'testTag', 'setMissionContinueState');
        });
        // [StartExclude continue11]
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
        // [EndExclude continue11]
        // Restore window stage so UI can reconstruct previous continuation state.
        this.context.restoreWindowStage(new LocalStorage());
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    // ...
  }

  // [End continue11]
  // [EndExclude continue2]
  // [Start continue7]
  // [Start continue10]
  onContinue(wantParam: Record<string, Object>) {
    // [StartExclude continue7]
    // [StartExclude continue10]
    // Read target app version to guard cross-version continuation compatibility.
    const targetVersion = wantParam.version;
    // Define minimum compatible version supported by the source app.
    const versionThreshold: number = 1000;
    // Reject continuation when target side is below required version.
    if (targetVersion < versionThreshold) {
      // Give user-friendly reason when continuation is rejected.q
      try {
        this.context.windowStage.getMainWindowSync()
          .getUIContext()
          .getPromptAction()
          .showToast({
            message: '目标端应用版本号过低，不支持接续，请您升级应用版本后再试',
            duration: 2000
          })
      } catch (error) {
        hilog.error(DOMAIN, 'testTag', 'Failed to getMainWindowSync. Cause: %{public}s', JSON.stringify(error));
      }
      // Return MISMATCH to terminate continuation negotiation.
      return AbilityConstant.OnContinueResult.MISMATCH;
    }
    // Put migration payload into want params for target-side restore.
    const continueInput = AppStorage.get('entryAbilityContext') as string;
    if (continueInput) {
      // Custom field "data" carries text payload.
      wantParam['data'] = continueInput;
    }
    // [StartExclude continue2]
    let pathStack = new NavPathStack();
    if (AppStorage.get('ifContinueNaviPage') as boolean) {
      pathStack = AppStorage.get('navPathStack') as NavPathStack;
    } else {
      pathStack = new NavPathStack();
    }
    // Export Navigation stack snapshot when navigation migration is enabled.
    let navPathInfo = pathStack.getPathStack();
    wantParam['navPathStack'] = navPathInfo;
    // [EndExclude continue10]
    // Export Router/source-exit switches for target-side behavior control.
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_SOURCE_EXIT_KEY] =
      AppStorage.get('entryAbilityContinueExit') as boolean;
    // [EndExclude continue7]
    // [StartExclude continue10]
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_PAGE_STACK_KEY] = AppStorage.get('ifContinueRouterPage') as boolean;
    // [EndExclude continue2]
    // [EndExclude continue10]
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
    // Return AGREE to allow continuation process to proceed.
    return AbilityConstant.OnContinueResult.AGREE;
  }

  // [End continue10]
  // [End continue7]
  // [StartExclude continue2]
  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // [EndExclude continue4]
  // [Start continue9]
  onWindowStageRestore(windowStage: window.WindowStage) {
    // If Router stack migration is disabled, force fallback landing page.
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

  // [End continue9]

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

  // [StartExclude continue4]
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

  // [EndExclude continue2]
  // [EndExclude continue3]
  // [EndExclude continue4]
  // [EndExclude continue8]
}

// [End continue2]
// [End continue3]
// [End continue4]
// [End continue8]
