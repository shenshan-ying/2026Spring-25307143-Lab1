import { window } from '@kit.ArkUI';

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
@Entry
@Component
struct ContinueRouterPage {
  // Switch bound to whether Router stack should be migrated.
  @StorageLink('ifContinueRouterPage') ifContinueRouterPage: boolean = true;

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.arrow_left')).width(40).height(40)
        }
        .onClick(() => {
          // Return to previous page after settings update.
          this.getUIContext().getRouter().back();
        })
        .width(40)
        .height(40)
        .backgroundColor('rgba(0,0,0,0.05)')

        Text($r('app.string.router_stack_migration_settings'))
          .fontSize(20)
          .fontWeight(700)
          .margin({
            left: 9
          })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Start)

      Row() {
        Text($r('app.string.if_migrate_router_stack'))
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: $$this.ifContinueRouterPage })
          .selectedColor($r('sys.color.icon_emphasize'))
          .switchPointColor(Color.White)
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .padding({
        top: 12,
        left: 12,
        right: 12
      })
      .borderRadius(16)
      .margin({
        bottom: 12
      })

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
    .padding({
      left: 12,
      right: 12
    })
  }
}