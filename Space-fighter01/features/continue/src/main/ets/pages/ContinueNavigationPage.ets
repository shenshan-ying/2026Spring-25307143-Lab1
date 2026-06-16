import { AbilityConstant, common } from "@kit.AbilityKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

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
@Component
export struct ContinueNavigationPage {
  // Switch bound to whether Navigation stack should be migrated.
  @StorageLink('ifContinueNaviPage') ifContinueNaviPage: boolean = true;
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  private context: common.UIAbilityContext | null = null;

  // [End continue6]

  // [Start continue7]
  aboutToAppear() {
    // Initialize context here, not in field declaration.
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    // Ensure continuation is active when this page is visible.
    if (this.context) {
      this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
      });
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text($r('app.string.if_migrate_navigation_stack'))
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: $$this.ifContinueNaviPage })
            .selectedColor($r('sys.color.icon_emphasize'))
            .switchPointColor(Color.White)
            .onChange(() => {
              if (this.context) {
                this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
                });
              }
            })
        }
        .width('100%')
        .height(56)
        .backgroundColor(Color.White)
        .padding({
          left: 12,
          right: 12
        })
        .borderRadius(16)
        .margin({
          bottom: 12
        })
      }
      .padding({
        top: 12,
        right: 16,
        left: 16
      })
    }
    .onBackPressed(() => {
      this.navPathStack.setPathStack([]);
      if (this.context) {
        this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
        });
      }
      return true;
    })
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
    .title($r('app.string.navigation_stack_migration_settings'))
  }
}