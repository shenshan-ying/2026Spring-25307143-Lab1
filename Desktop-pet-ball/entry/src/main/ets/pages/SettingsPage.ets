import { AppConfig } from '../dao/DataModels';
import { ConfigManager } from '../service/ConfigManager';
import { Logger, LogLevel } from '../utils/Logger';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct SettingsPage {
  @State config: AppConfig = {
    motionMode: 'free_rolling',
    motionSpeed: 100,
    judgmentLinePosition: 'bottom',
    petBallSizeCoefficient: 1.0,
    version: '1.0.0'
  };
  
  @State motionModeIndex: number = 0;
  @State judgmentLineIndex: number = 0;
  
  private configManager: ConfigManager = new ConfigManager();
  private logger: Logger = Logger.getInstance();
  
  async aboutToAppear(): Promise<void> {
    // 获取上下文 - 修复API调用
    const context = getContext(this) as common.UIAbilityContext;
    await this.configManager.init(context);
    const loadedConfig = await this.configManager.loadConfig();
    if (loadedConfig) {
      this.config = loadedConfig;
    }
    
    const modes = ['free_rolling', 'static', 'slingshot', 'following'];
    this.motionModeIndex = modes.indexOf(this.config.motionMode);
    if (this.motionModeIndex < 0) this.motionModeIndex = 0;
    this.judgmentLineIndex = ['bottom', 'top', 'left', 'right'].indexOf(this.config.judgmentLinePosition);
  }
  
  private async saveConfig(): Promise<void> {
    await this.configManager.saveConfig();
    this.logger.info('SettingsPage', 'Config saved');
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Button('返回')
          .fontSize(16)
          .width(70)
          .height(40)
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })
        
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('保存')
          .fontSize(16)
          .width(70)
          .height(40)
          .onClick(async () => {
            await this.saveConfig();
            this.getUIContext().getRouter().back();
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#FFFFFF')
      
      Scroll() {
        Column() {
          // 运动模式设置
          Column() {
            Text('运动模式')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: 15 })
            
            Grid() {
              ForEach(
                ['自由滚动', '静止', '弹弓发射', '跟随'],
                (item: string, index: number) => {
                  GridItem() {
                    Text(item)
                      .fontSize(16)
                      .fontColor(this.motionModeIndex === index ? '#FF6B6B' : '#666666')
                      .padding(10)
                      .backgroundColor(this.motionModeIndex === index ? '#FFE5E5' : '#F5F5F5')
                      .borderRadius(8)
                      .onClick(() => {
                        this.motionModeIndex = index;
                        const modes = ['free_rolling', 'static', 'slingshot', 'following'];
                        this.config.motionMode = modes[index] as 'free_rolling' | 'static' | 'slingshot' | 'following';
                      })
                  }
                }
              )
            }
            .columnsTemplate('1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .width('100%')
            .height(120)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .margin({ top: 15, left: 15, right: 15 })
          
          // 运动速度设置
          Column() {
            Text('运动速度')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: 15 })
            
            Row() {
              Text('慢')
                .fontSize(14)
                .fontColor('#999999')
              
              Slider({
                value: this.config.motionSpeed,
                min: 20,
                max: 200,
                step: 10
              })
                .width('60%')
                .blockColor('#FF6B6B')
                .trackColor('#FFE5E5')
                .onChange((value: number) => {
                  this.config.motionSpeed = value;
                })
              
              Text('快')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            
            Text(`当前速度: ${this.config.motionSpeed}`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 10 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .margin({ top: 15, left: 15, right: 15 })
          
          // 宠物球大小设置
          Column() {
            Text('宠物球大小')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: 15 })
            
            Row() {
              Text('小')
                .fontSize(14)
                .fontColor('#999999')
              
              Slider({
                value: this.config.petBallSizeCoefficient,
                min: 0.5,
                max: 2.0,
                step: 0.1
              })
                .width('60%')
                .blockColor('#4ECDC4')
                .trackColor('#E5F9F6')
                .onChange((value: number) => {
                  this.config.petBallSizeCoefficient = value;
                })
              
              Text('大')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            
            Text(`当前大小系数: ${this.config.petBallSizeCoefficient.toFixed(1)}`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 10 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .margin({ top: 15, left: 15, right: 15 })
          
          // 判定线位置设置
          Column() {
            Text('判定线位置')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: 15 })
            
            Grid() {
              ForEach(['底部', '顶部', '左侧', '右侧'], (item: string, index: number) => {
                GridItem() {
                  Text(item)
                    .fontSize(16)
                    .fontColor(this.judgmentLineIndex === index ? '#FF6B6B' : '#666666')
                    .padding(10)
                    .backgroundColor(this.judgmentLineIndex === index ? '#FFE5E5' : '#F5F5F5')
                    .borderRadius(8)
                    .onClick(() => {
                      this.judgmentLineIndex = index;
                      this.config.judgmentLinePosition = ['bottom', 'top', 'left', 'right'][index] as 'bottom' | 'top' | 'left' | 'right';
                    })
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .width('100%')
            .height(120)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .margin({ top: 15, left: 15, right: 15 })
          
          // 版本信息
          Column() {
            Text('版本信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: 15 })
            
            Text(`版本: ${this.config.version}`)
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .margin({ top: 15, left: 15, right: 15, bottom: 30 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F0F0F5')
    }
    .width('100%')
    .height('100%')
  }
}
