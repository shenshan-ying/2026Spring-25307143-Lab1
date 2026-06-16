import { PetBallResource } from '../dao/DataModels';
import { ResourceManager } from '../manager/ResourceManager';
import { PermissionManager } from '../service/PermissionManager';
import { Logger, LogLevel } from '../utils/Logger';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct ResourceManagerPage {
  @State resources: PetBallResource[] = [];
  @State selectedResourceId: string = '';
  @State showAddDialog: boolean = false;
  
  private resourceManager: ResourceManager = new ResourceManager();
  private permissionManager: PermissionManager = new PermissionManager();
  private logger: Logger = Logger.getInstance();
  
  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    this.permissionManager.init(context);
    await this.resourceManager.init(context);
    await this.loadResources();
  }
  
  private async loadResources(): Promise<void> {
    this.resources = await this.resourceManager.getAllResources();
    
    // 如果没有资源，添加预设资源
    if (this.resources.length === 0) {
      await this.addPresetResources();
    }
  }
  
  private async addPresetResources(): Promise<void> {
    const presets: PetBallResource[] = [
      {
        id: 'preset_cat',
        type: 'preset',
        name: '猫咪球',
        animalType: 'cat',
        imagePath: 'cat_ball.png',
        createdAt: Date.now(),
        status: 'active'
      },
      {
        id: 'preset_dog',
        type: 'preset',
        name: '狗狗球',
        animalType: 'dog',
        imagePath: 'dog_ball.png',
        createdAt: Date.now(),
        status: 'active'
      },
      {
        id: 'preset_bird',
        type: 'preset',
        name: '小鸟球',
        animalType: 'bird',
        imagePath: 'bird_ball.png',
        createdAt: Date.now(),
        status: 'active'
      }
    ];
    
    // 预设资源已在 ResourceManager 构造函数中初始化
    
    this.resources = this.resourceManager.getAllResources();
  }
  
  private async deleteResource(resourceId: string): Promise<void> {
    await this.resourceManager.deleteResource(resourceId);
    this.resources = this.resourceManager.getAllResources();
  }

  private async pickFromGallery(): Promise<void> {
    const result = await this.permissionManager.requestPermission('ohos.permission.READ_MEDIA');
    if (!result.granted) {
      this.logger.warn('ResourceManagerPage', 'READ_MEDIA permission denied');
      return;
    }
    const resource = await this.resourceManager.createCustomResourceFromGallery();
    if (resource) {
      this.resources = this.resourceManager.getAllResources();
      this.logger.info('ResourceManagerPage', `Created resource from gallery: ${resource.id}`);
    }
  }

  private async takePhoto(): Promise<void> {
    const result = await this.permissionManager.requestPermission('ohos.permission.CAMERA');
    if (!result.granted) {
      this.logger.warn('ResourceManagerPage', 'CAMERA permission denied');
      return;
    }
    const resource = await this.resourceManager.createCustomResourceFromCamera();
    if (resource) {
      this.resources = this.resourceManager.getAllResources();
      this.logger.info('ResourceManagerPage', `Created resource from camera: ${resource.id}`);
    }
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
        
        Text('资源管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('+')
          .fontSize(20)
          .width(40)
          .height(40)
          .onClick(() => {
            this.showAddDialog = true;
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#FFFFFF')
      
      // 资源列表
      Scroll() {
        Column() {
          // 预设资源
          Column() {
            Text('预设资源')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: 15 })
            
            ForEach(this.resources.filter(r => r.type === 'preset'), (resource: PetBallResource) => {
              this.ResourceItem(resource)
            }, (resource: PetBallResource) => resource.id)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .margin({ top: 15, left: 15, right: 15 })
          
          // 自定义资源
          Column() {
            Text('自定义资源')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: 15 })
            
            if (this.resources.filter(r => r.type === 'custom').length === 0) {
              Text('暂无自定义资源')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(20)
            } else {
              ForEach(this.resources.filter(r => r.type === 'custom'), (resource: PetBallResource) => {
                this.ResourceItem(resource)
              }, (resource: PetBallResource) => resource.id)
            }
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
      
      // 底部操作栏
      Row() {
        Button('从相册选择')
          .fontSize(16)
          .width('45%')
          .height(50)
          .backgroundColor('#4ECDC4')
          .onClick(async () => {
            await this.pickFromGallery();
          })
        
        Button('拍摄照片')
          .fontSize(16)
          .width('45%')
          .height(50)
          .backgroundColor('#FF6B6B')
          .onClick(async () => {
            await this.takePhoto();
          })
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showAddDialog, this.AddResourceSheet(), {
      height: 300,
      backgroundColor: Color.White,
      dragBar: true
    })
  }
  
  @Builder
  ResourceItem(resource: PetBallResource) {
    Row() {
      // 资源图标
      Column() {
        Circle()
          .width(60)
          .height(60)
          .fill(this.getResourceColor(resource))
      }
      .margin({ right: 15 })
      
      // 资源信息
      Column() {
        Text(resource.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        
        Text(`${resource.type === 'preset' ? '预设' : '自定义'} | ${resource.animalType || '未知'}`)
          .fontSize(12)
          .fontColor('#999999')
          .width('100%')
          .margin({ top: 5 })
        
        Text(new Date(resource.createdAt).toLocaleDateString())
          .fontSize(12)
          .fontColor('#CCCCCC')
          .width('100%')
          .margin({ top: 5 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      // 操作按钮
      if (resource.type === 'custom') {
        Button('删除')
          .fontSize(14)
          .width(60)
          .height(35)
          .backgroundColor('#FF6B6B')
          .onClick(async () => {
            await this.deleteResource(resource.id);
          })
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#F9F9F9')
    .borderRadius(8)
    .margin({ bottom: 10 })
  }
  
  @Builder
  AddResourceSheet() {
    Column() {
      Text('添加自定义资源')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })
      
      Row() {
        Button('从相册选择')
          .fontSize(16)
          .width('45%')
          .height(50)
          .backgroundColor('#4ECDC4')
          .onClick(async () => {
            this.showAddDialog = false;
            await this.pickFromGallery();
          })
        
        Button('拍摄照片')
          .fontSize(16)
          .width('45%')
          .height(50)
          .backgroundColor('#FF6B6B')
          .onClick(async () => {
            this.showAddDialog = false;
            await this.takePhoto();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
  }
  
  private getResourceColor(resource: PetBallResource): string {
    const colors: Record<string, string> = {
      'cat': '#FFD700',
      'dog': '#FFA500',
      'bird': '#4ECDC4'
    };
    return colors[resource.animalType || ''] || '#FF6B6B';
  }
}
