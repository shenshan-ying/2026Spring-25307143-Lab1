import { PetBallInstance, AppConfig, Position, Velocity } from '../dao/DataModels';
import { InstanceManager } from '../manager/InstanceManager';
import { CultivationManager } from '../manager/CultivationManager';
import { ResourceManager } from '../manager/ResourceManager';
import { StateManager } from '../manager/StateManager';
import { PairingManager } from '../manager/PairingManager';
import { TransferController } from '../manager/TransferController';
import { DeviceAdapter } from '../service/DeviceAdapter';
import { ConfigManager } from '../service/ConfigManager';
import { DesktopPetCoordinator } from '../coordinator/DesktopPetCoordinator';
import { MotionEngine } from '../engine/MotionEngine';
import { CollisionEngine } from '../engine/CollisionEngine';
import { PhysicsUtils } from '../utils/PhysicsUtils';
import { Logger, LogLevel } from '../utils/Logger';
import { common } from '@kit.AbilityKit';
import promptAction from '@ohos.promptAction';
import display from '@ohos.display';

/**
 * 宠物球管理面板 — 主窗口页面
 * 管理所有宠物球实例：创建、删除、选择哪些显示在桌面浮窗中
 */
@Entry
@Component
struct Index {
  @State petBallInstances: PetBallInstance[] = [];
  @State config: AppConfig = {
    motionMode: 'free_rolling',
    motionSpeed: 100,
    judgmentLinePosition: 'bottom',
    petBallSizeCoefficient: 1.0,
    version: '1.0.0'
  };
  // —— 选择 / 删除 ——
  @State selectMode: boolean = false;              // 是否在选择模式
  @State selectedIds: Set<string> = new Set();     // 已勾选的球 ID
  @State deleteTargetIds: string[] = [];            // 待删除的 ID 列表（单个或批量）
  @State showDeleteConfirm: boolean = false;
  @StorageLink('floatWindowReady') floatWindowReady: boolean = true;

  private logger: Logger = Logger.getInstance();
  private instanceManager: InstanceManager | null = null;
  private cultivationManager: CultivationManager | null = null;
  private resourceManager: ResourceManager = new ResourceManager();
  private stateManager: StateManager | null = null;
  private deviceAdapter: DeviceAdapter = new DeviceAdapter();
  private configManager: ConfigManager = new ConfigManager();
  private pairingManager: PairingManager = new PairingManager();
  private transferController: TransferController | null = null;
  private coordinator: DesktopPetCoordinator = DesktopPetCoordinator.getInstance();

  aboutToAppear(): void {
    this.logger.setLogLevel(LogLevel.DEBUG);
    this.initialize();
  }

  aboutToDisappear(): void {
    this.saveState();
  }

  private async initialize(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      if (!context) {
        this.logger.error('Index', '无法获取应用上下文');
        return;
      }

      // 设备适配
      try {
        this.deviceAdapter.init(context);
      } catch (_e) {
        this.logger.warn('Index', '设备适配器初始化失败');
      }

      // 配置
      try {
        await this.configManager.init(context);
        const cfg = await this.configManager.loadConfig();
        if (cfg) this.config = cfg;
      } catch (_e) {
        this.logger.warn('Index', '配置加载失败，使用默认值');
      }

      // 实例管理器
      this.instanceManager = new InstanceManager(this.deviceAdapter);
      await this.instanceManager.init(context);

      // 将 InstanceManager 注册到协调器，供浮窗使用
      this.coordinator.setInstanceManager(this.instanceManager);

      // 培养管理器
      try {
        this.cultivationManager = new CultivationManager();
        await this.cultivationManager.init(context);
      } catch (_e) {
        this.logger.warn('Index', '培养管理器初始化失败');
        this.cultivationManager = new CultivationManager();
      }

      // 状态管理器
      try {
        this.stateManager = new StateManager(this.cultivationManager);
        await this.stateManager.init(context);
      } catch (_e) {
        this.logger.warn('Index', '状态管理器初始化失败');
        this.stateManager = new StateManager(this.cultivationManager);
      }

      // 资源管理器
      try {
        await this.resourceManager.init(context);
      } catch (_e) {
        this.logger.warn('Index', '资源管理器初始化失败');
      }

      // 分布式传递
      try {
        await this.pairingManager.init(context);
        await this.pairingManager.initKvStore('pet_ball_transfer');
        this.transferController = new TransferController(
          this.pairingManager,
          this.instanceManager,
          this.resourceManager,
          this.cultivationManager!
        );
      } catch (_e) {
        this.logger.warn('Index', '分布式传递模块初始化失败');
      }

      // 加载实例列表
      this.petBallInstances = this.instanceManager.getAllInstances();
      this.logger.info('Index', `加载了 ${this.petBallInstances.length} 个宠物球`);

      if (this.petBallInstances.length === 0) {
        this.createNewPetBall();
      }

      // 自动将已有实例标记为桌面可见
      for (const inst of this.petBallInstances) {
        if (!this.coordinator.isDesktopVisible(inst.id)) {
          this.coordinator.setDesktopVisible(inst.id, true);
        }
      }

      // 通知浮窗 InstanceManager 已就绪
      this.coordinator.notifyReady();

      // 调试日志：显示当前状态
      console.info('Index初始化完成', {
        floatWindowReady: this.floatWindowReady,
        petBallInstances: this.petBallInstances.length,
        desktopVisibleCount: this.coordinator.getVisibleCount(),
        showFallbackOverlay: !this.floatWindowReady && this.coordinator.getVisibleCount() > 0
      });
    } catch (error) {
      const err = error as Error;
      this.logger.error('Index', `初始化失败: ${err.message}`);
    }
  }

  // ==================== 操作 ====================

  // 测试方法：强制显示宠物球（用于调试）
  private testShowPetBalls(): void {
    if (this.instanceManager) {
      const instances = this.instanceManager.getAllInstances();
      console.info('测试显示宠物球', {
        totalInstances: instances.length,
        desktopVisible: this.coordinator.getDesktopVisibleIds(),
        floatWindowReady: this.floatWindowReady
      });

      // 确保至少有一个宠物球
      if (instances.length === 0) {
        this.createNewPetBall();
      }

      // 确保所有宠物球都标记为桌面可见
      for (const inst of instances) {
        if (!this.coordinator.isDesktopVisible(inst.id)) {
          this.coordinator.setDesktopVisible(inst.id, true);
        }
      }

      this.showToast('宠物球显示测试完成');
    }
  }

  private createNewPetBall(): void {
    if (!this.instanceManager) return;
    if (!this.instanceManager.canCreateInstance()) {
      this.showToast('已达到最大宠物球数量');
      return;
    }
    const instance = this.instanceManager.createInstance(
      'default_ball',
      { x: 200 + Math.random() * 200, y: 200 + Math.random() * 400 },
      { vx: (Math.random() - 0.5) * 100, vy: (Math.random() - 0.5) * 100, speed: 50 }
    );
    if (instance) {
      this.petBallInstances = [...this.petBallInstances, instance];
      this.coordinator.setDesktopVisible(instance.id, true);
      this.logger.info('Index', `创建新宠物球: ${instance.id}`);
      this.showToast('宠物球已创建');
    }
  }

  // ==================== 选择与删除 ====================

  /** 进入 / 退出选择模式 */
  private toggleSelectMode(): void {
    this.selectMode = !this.selectMode;
    if (!this.selectMode) {
      this.selectedIds.clear();
    }
  }

  /** 切换某个球的勾选状态 */
  private toggleSelect(id: string): void {
    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id);
    } else {
      this.selectedIds.add(id);
    }
    // 触发 @State 刷新（Set 本身不会通知）
    this.selectedIds = new Set(this.selectedIds);
  }

  /** 全选 */
  private selectAll(): void {
    for (const inst of this.petBallInstances) {
      this.selectedIds.add(inst.id);
    }
    this.selectedIds = new Set(this.selectedIds);
  }

  /** 取消全选 */
  private deselectAll(): void {
    this.selectedIds.clear();
    this.selectedIds = new Set(this.selectedIds);
  }

  /** 单个删除 */
  private confirmDeleteOne(id: string): void {
    this.deleteTargetIds = [id];
    this.showDeleteConfirm = true;
  }

  /** 批量删除 */
  private confirmDeleteSelected(): void {
    if (this.selectedIds.size === 0) {
      this.showToast('请先勾选要删除的宠物球');
      return;
    }
    this.deleteTargetIds = Array.from(this.selectedIds);
    this.showDeleteConfirm = true;
  }

  /** 执行删除 */
  private async executeDelete(): Promise<void> {
    if (!this.instanceManager || this.deleteTargetIds.length === 0) {
      this.showDeleteConfirm = false;
      return;
    }

    const count = this.deleteTargetIds.length;
    for (const id of this.deleteTargetIds) {
      this.coordinator.removeFromDesktop(id);
      await this.instanceManager.destroyInstance(id);
    }

    this.petBallInstances = this.instanceManager.getAllInstances();
    this.selectedIds.clear();
    this.selectMode = false;
    this.showDeleteConfirm = false;
    this.deleteTargetIds = [];

    this.showToast(`已删除 ${count} 个宠物球`);
  }

  private cancelDelete(): void {
    this.showDeleteConfirm = false;
    this.deleteTargetIds = [];
  }

  private toggleDesktop(id: string, visible: boolean): void {
    this.coordinator.setDesktopVisible(id, visible);
    const label = visible ? '已显示在桌面' : '已从桌面隐藏';
    this.showToast(label);
  }

  // ==================== 分布式传递 ====================

  private async initiateTransfer(instanceId: string): Promise<void> {
    if (!this.transferController || !this.pairingManager) {
      this.showToast('分布式模块未初始化');
      return;
    }
    const paired = this.pairingManager.getPairedDevices();
    if (paired.length === 0) {
      const devices = await this.pairingManager.discoverDevices();
      if (devices.length === 0) {
        this.showToast('未发现可用设备');
        return;
      }
      const result = await this.pairingManager.startPairing(devices[0].deviceId);
      if (!result.success) {
        this.showToast('设备配对失败');
        return;
      }
    }
    const targets = this.pairingManager.getPairedDevices();
    if (targets.length === 0) return;

    const instance = this.petBallInstances.find(inst => inst.id === instanceId);
    if (!instance) return;

    const prepared = await this.transferController.prepareTransfer(instance, targets[0].deviceId);
    if (prepared) {
      const ok = await this.transferController.executeTransfer();
      if (ok) {
        this.petBallInstances = this.instanceManager!.getAllInstances();
        this.showToast(`已传递到 ${targets[0].deviceName}`);
      }
    }
  }

  private async saveState(): Promise<void> {
    if (this.instanceManager) {
      await this.instanceManager.saveAllInstances();
    }
    if (this.cultivationManager) {
      await this.cultivationManager.saveAllAffection();
    }
  }

  // ==================== 外观 ====================

  private getBallColor(instance: PetBallInstance): string {
    const level = this.cultivationManager?.getLevel(instance.id) || 1;
    const colors = ['#FFD700', '#FFA500', '#FF6B6B', '#4ECDC4', '#45B7D1'];
    return colors[(level - 1) % colors.length];
  }

  private shortId(id: string): string {
    if (id.length <= 10) return id;
    return id.slice(0, 6) + '...' + id.slice(-4);
  }

  private showToast(msg: string): void {
    promptAction.showToast({ message: msg, duration: 2000, bottom: '80vp' });
  }

  private get desktopVisibleCount(): number {
    return this.coordinator.getVisibleCount();
  }

  private get showFallbackOverlay(): boolean {
    // 在手机端，浮窗创建失败时显示回退渲染层
    const show = !this.floatWindowReady && this.coordinator.getVisibleCount() > 0;
    if (show) {
      console.info('Show fallback overlay:', {
        floatWindowReady: this.floatWindowReady,
        visibleCount: this.coordinator.getVisibleCount(),
        petBallsCount: this.petBallInstances.length
      });
    }
    return show;
  }

  // ==================== UI ====================

  build() {
    Stack() {
      Column() {
        // ---- 标题栏 ----
        Row() {
          Text('🐱 宠物球管理')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E')

          Blank()

          if (this.selectMode && this.selectedIds.size > 0) {
            // 选择模式下显示已选数量
            Text(`已选 ${this.selectedIds.size}`)
              .fontSize(13)
              .fontColor('#FFFFFF')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(12)
              .backgroundColor('#FF6B6B')
              .margin({ right: 8 })
          }

          // 桌面显示计数徽章
          Row() {
            Text(`桌面 ${this.desktopVisibleCount}/${this.petBallInstances.length}`)
              .fontSize(13)
              .fontColor(this.desktopVisibleCount > 0 ? '#4ECDC4' : '#999999')
          }
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(12)
          .backgroundColor(this.desktopVisibleCount > 0 ? '#E0F7FA' : '#F5F5F5')
          .margin({ right: 10 })

          // 选择模式开关
          Button(this.selectMode ? '完成' : '选择')
            .fontSize(13)
            .height(32)
            .padding({ left: 12, right: 12 })
            .borderRadius(16)
            .backgroundColor(this.selectMode ? '#4ECDC4' : '#F0F0F0')
            .fontColor(this.selectMode ? '#FFFFFF' : '#666666')
            .onClick(() => this.toggleSelectMode())
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 12 })

        // ---- 分割线 ----
        Divider()
          .color('#E0E0E0')
          .strokeWidth(1)

        // ---- 宠物球列表 ----
        if (this.petBallInstances.length === 0) {
          Column() {
            Text('😺')
              .fontSize(48)
              .margin({ bottom: 12 })
            Text('还没有宠物球')
              .fontSize(16)
              .fontColor('#888888')
              .margin({ bottom: 4 })
            Text('点击下方按钮添加第一个吧')
              .fontSize(13)
              .fontColor('#AAAAAA')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.petBallInstances, (instance: PetBallInstance) => {
              ListItem() {
                Row() {
                  // 选择模式下显示勾选框
                  if (this.selectMode) {
                    Checkbox()
                      .select(this.selectedIds.has(instance.id))
                      .selectedColor('#4ECDC4')
                      .onChange((checked: boolean) => {
                        this.toggleSelect(instance.id);
                      })
                      .margin({ right: 12 })
                  }

                  // 球颜色预览
                  Circle()
                    .width(40)
                    .height(40)
                    .fill(this.getBallColor(instance))
                    .stroke('#E0E0E0')
                    .strokeWidth(2)
                    .shadow({ radius: 6, color: '#10000000' })
                    .margin({ right: 14 })

                  // 信息
                  Column() {
                    Text(this.shortId(instance.id))
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#1A1A2E')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(`等级 ${this.cultivationManager?.getLevel(instance.id) || 1}`)
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ right: 8 })

                  Blank()

                  if (!this.selectMode) {
                    // 桌面显示开关（正常模式）
                    Toggle({ type: ToggleType.Switch, isOn: this.coordinator.isDesktopVisible(instance.id) })
                      .selectedColor('#4ECDC4')
                      .onChange((isOn: boolean) => {
                        this.toggleDesktop(instance.id, isOn);
                      })
                      .margin({ right: 8 })

                    // 删除按钮（正常模式）
                    Button({ type: ButtonType.Circle }) {
                      Text('🗑')
                        .fontSize(16)
                    }
                    .width(36)
                    .height(36)
                    .backgroundColor('#FFF0F0')
                    .onClick(() => {
                      this.confirmDeleteOne(instance.id);
                    })
                  }
                }
                .width('100%')
                .padding({ left: 20, right: 16, top: 14, bottom: 14 })
                .alignItems(VerticalAlign.Center)
                .onClick(() => {
                  // 选择模式下点击整行切换勾选
                  if (this.selectMode) {
                    this.toggleSelect(instance.id);
                  }
                })
              }
            }, (instance: PetBallInstance) => instance.id)
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 1, color: '#F0F0F0' })
        }

        // ---- 底部操作栏 ----
        Column() {
          if (this.selectMode) {
            // ===== 选择模式底栏 =====
            Row() {
              // 全选 / 取消全选
              Row() {
                Checkbox()
                  .select(this.selectedIds.size === this.petBallInstances.length && this.petBallInstances.length > 0)
                  .selectedColor('#4ECDC4')
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.selectAll();
                    } else {
                      this.deselectAll();
                    }
                  })
                Text('全选')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 6 })
              }
              .margin({ left: 20 })

              Blank()

              // 批量删除按钮
              Button('🗑 批量删除')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .height(40)
                .padding({ left: 16, right: 16 })
                .borderRadius(20)
                .backgroundColor(this.selectedIds.size > 0 ? '#FF6B6B' : '#E0E0E0')
                .fontColor(this.selectedIds.size > 0 ? '#FFFFFF' : '#999999')
                .enabled(this.selectedIds.size > 0)
                .onClick(() => {
                  this.confirmDeleteSelected();
                })
                .margin({ right: 16 })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .backgroundColor('#FFFFFF')
            .border({ width: { top: 1 }, color: '#F0F0F0' })
          } else {
            // ===== 正常模式底栏 =====
            // 添加按钮
            Button('＋ 添加新宠物球')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .width('90%')
              .height(48)
              .borderRadius(24)
              .backgroundColor('#4ECDC4')
              .fontColor('#FFFFFF')
              .shadow({ radius: 8, color: '#204ECDC4', offsetY: 3 })
              .margin({ bottom: 16 })
              .onClick(() => {
                this.createNewPetBall();
              })

            // 导航按钮行
            Row() {
              this.NavButton('⚙', '设置', () => {
                this.getUIContext().getRouter().pushUrl({ url: 'pages/SettingsPage' });
              })
              this.NavButton('🎨', '资源', () => {
                this.getUIContext().getRouter().pushUrl({ url: 'pages/ResourceManagerPage' });
              })
               this.NavButton('📤', '传递', () => {
                 const selected = this.petBallInstances.find(
                   b => this.coordinator.isDesktopVisible(b.id)
                 ) || this.petBallInstances[0];
                 if (selected) {
                   this.initiateTransfer(selected.id);
                 } else {
                   this.showToast('没有可传递的宠物球');
                 }
               })
               this.NavButton('🐛', '测试', () => {
                 this.testShowPetBalls();
               })
            }
            .width('90%')
            .justifyContent(FlexAlign.SpaceEvenly)
          }
        }
        .width('100%')
        .padding({ top: 8, bottom: 24 })
        .backgroundColor('#FAFAFA')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')

      // ---- 宠物球回退渲染层（手机端浮窗不可用时，在主窗口内渲染宠物球） ----
      if (this.showFallbackOverlay) {
        PetBallFallbackOverlay()
          .zIndex(9999)  // 确保在最上层
          .backgroundColor('#00000000')  // 完全透明背景
      }

      // ---- 删除确认遮罩 ----
      if (this.showDeleteConfirm) {
        Stack() {
          // 暗色背景层：点击可关闭
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#60000000')
            .onClick(() => this.cancelDelete())

          // 弹窗卡片层：用空 onClick 吞掉事件，防止穿透到背景层
          Column() {
            Text('确认删除')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 10 })

            Text(this.deleteTargetIds.length > 1
              ? `即将删除 ${this.deleteTargetIds.length} 个宠物球，删除后将从桌面消失且无法恢复`
              : '删除后宠物球将从桌面消失且无法恢复')
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 20 })

            Row() {
              Button('取消')
                .fontSize(15)
                .width('40%')
                .height(40)
                .borderRadius(20)
                .backgroundColor('#F0F0F0')
                .fontColor('#666666')
                .onClick(() => this.cancelDelete())

              Button('删除')
                .fontSize(15)
                .width('40%')
                .height(40)
                .borderRadius(20)
                .backgroundColor('#FF6B6B')
                .fontColor('#FFFFFF')
                .onClick(() => this.executeDelete())
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
          }
          .width('75%')
          .padding(24)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 20, color: '#30000000' })
          .onClick(() => {})  // 吞掉点击事件，阻止穿透到背景层
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  NavButton(icon: string, label: string, action: () => void) {
    Column() {
      Text(icon)
        .fontSize(22)
        .margin({ bottom: 2 })
      Text(label)
        .fontSize(11)
        .fontColor('#666666')
    }
    .width(64)
    .padding({ top: 8, bottom: 8 })
    .borderRadius(12)
    .onClick(action)
  }
}
function requestAnimationFrame(cb: () => void): number {
  return setTimeout(cb, 16);
}

function cancelAnimationFrame(id: number): void {
  clearTimeout(id);
}

/**
 * 宠物球回退渲染组件 — 手机端浮窗不可用时在主窗口内渲染桌面可见的宠物球
 */
@Component
struct PetBallFallbackOverlay {
  @State petBalls: PetBallInstance[] = [];
  @State screenWidth: number = 360;
  @State screenHeight: number = 800;
  @State ballSize: number = 100;
  @State isDragging: boolean = false;
  @State selectedId: string = '';

  private coordinator: DesktopPetCoordinator = DesktopPetCoordinator.getInstance();
  private motionEngine: MotionEngine | null = null;
  private collisionEngine: CollisionEngine | null = null;
  private animFrameId: number = -1;
  private lastTime: number = 0;
  private frameInterval: number = 16.67;
  private tickCounter: number = 0;

  // 用闭包保存监听器引用
  private changeListener: () => void = () => {
    this.onCoordinatorChanged();
  };

  aboutToAppear(): void {
    this.initScreen();
    this.coordinator.onChange(this.changeListener);
    this.onCoordinatorChanged();
  }

  aboutToDisappear(): void {
    if (this.animFrameId !== -1) {
      cancelAnimationFrame(this.animFrameId);
      this.animFrameId = -1;
    }
    this.coordinator.offChange(this.changeListener);
  }

  private initScreen(): void {
    try {
      const disp = display.getDefaultDisplaySync();
      this.screenWidth = disp.width;
      this.screenHeight = disp.height;
    } catch (_e) {
      this.screenWidth = 360;
      this.screenHeight = 800;
    }
    this.ballSize = 100;

    this.motionEngine = new MotionEngine(
      this.screenWidth,
      this.screenHeight,
      this.ballSize / 2
    );
    this.motionEngine.setStrategy('free_rolling');
    this.collisionEngine = new CollisionEngine(this.ballSize / 2);
  }

  private onCoordinatorChanged(): void {
    const mgr = this.coordinator.getInstanceManager();
    if (!mgr) {
      this.petBalls = [];
      return;
    }

    const visibleIds = this.coordinator.getDesktopVisibleIds();
    const visible: PetBallInstance[] = [];
    for (const id of visibleIds) {
      const inst = mgr.getInstance(id);
      if (inst) {
        visible.push(inst);
      } else {
        this.coordinator.removeFromDesktop(id);
      }
    }
    this.petBalls = visible;

    if (visible.length > 0 && this.animFrameId === -1) {
      this.lastTime = Date.now();
      this.animLoop();
    } else if (visible.length === 0 && this.animFrameId !== -1) {
      cancelAnimationFrame(this.animFrameId);
      this.animFrameId = -1;
    }
  }

  private animLoop(): void {
    const now = Date.now();
    const dt = now - this.lastTime;
    if (dt >= this.frameInterval) {
      this.tick(dt);
      this.lastTime = now;
    }
    this.animFrameId = requestAnimationFrame(() => this.animLoop());
  }

  private tick(dt: number): void {
    if (!this.motionEngine) return;

    const validIds = new Set(this.coordinator.getDesktopVisibleIds());
    this.petBalls = this.petBalls.filter(b => validIds.has(b.id));
    if (this.petBalls.length === 0) return;

    for (const ball of this.petBalls) {
      if (this.isDragging && ball.id === this.selectedId) continue;
      const r = this.motionEngine.update(ball.position, ball.velocity, dt);
      ball.position = r.position;
      ball.velocity = r.velocity;
    }

    if (this.collisionEngine && this.petBalls.length > 1) {
      const cols = this.collisionEngine.detectCollisions(this.petBalls);
      for (const pair of cols.collisionPairs) {
        const i1 = this.petBalls.findIndex(b => b.id === pair.instance1.id);
        const i2 = this.petBalls.findIndex(b => b.id === pair.instance2.id);
        if (i1 !== -1 && i2 !== -1) {
          const vels = PhysicsUtils.calculateElasticCollision(
            this.petBalls[i1].position, this.petBalls[i1].velocity,
            this.petBalls[i2].position, this.petBalls[i2].velocity
          );
          this.petBalls[i1].velocity = vels.velocity1;
          this.petBalls[i2].velocity = vels.velocity2;
        }
      }
    }

    this.tickCounter++;
    if (this.tickCounter % 4 === 0) {
      this.petBalls = [...this.petBalls];
    }
  }

  private handleTap(id: string): void {
    const found = this.petBalls.find(b => b.id === id);
    if (found) {
      found.affectionValue = (found.affectionValue + 1) % 5;
      this.petBalls = [...this.petBalls];
    }
  }

  private handleDragStart(id: string): void {
    this.selectedId = id;
    this.isDragging = true;
  }

  private handleDragUpdate(id: string, ox: number, oy: number): void {
    if (!this.isDragging) return;
    const ball = this.petBalls.find(b => b.id === id);
    if (ball) {
      ball.position.x += ox;
      ball.position.y += oy;
      ball.velocity = { vx: 0, vy: 0, speed: 0 };
      this.petBalls = [...this.petBalls];
    }
  }

  private handleDragEnd(id: string): void {
    this.isDragging = false;
    this.selectedId = '';
  }

  private ballColor(affection: number): string {
    const colors = ['#FFD700', '#FFA500', '#FF6B6B', '#4ECDC4', '#45B7D1'];
    return colors[affection % colors.length];
  }

  private shortId(id: string): string {
    if (id.length <= 8) return id;
    return '...' + id.slice(-4);
  }

  build() {
    Stack() {
      ForEach(this.petBalls, (ball: PetBallInstance) => {
        Stack() {
          Circle()
            .width(this.ballSize)
            .height(this.ballSize)
            .fill(this.ballColor(ball.affectionValue))
            .stroke('#FFA500')
            .strokeWidth(3)
            .shadow({ radius: 12, color: '#30000000', offsetX: 2, offsetY: 4 })

          Text(this.shortId(ball.id))
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor('#40000000')
            .borderRadius(4)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
        }
        .width(this.ballSize)
        .height(this.ballSize)
        .position({
          x: ball.position.x - this.ballSize / 2,
          y: ball.position.y - this.ballSize / 2
        })
        .hitTestBehavior(HitTestMode.Block)
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            PanGesture({ fingers: 1, direction: PanDirection.All })
              .onActionStart(() => this.handleDragStart(ball.id))
              .onActionUpdate((e: GestureEvent) => this.handleDragUpdate(ball.id, e.offsetX, e.offsetY))
              .onActionEnd(() => this.handleDragEnd(ball.id)),
            TapGesture({ count: 1 })
              .onAction(() => this.handleTap(ball.id))
          )
        )
      }, (ball: PetBallInstance) => ball.id)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('transparent')
    .hitTestBehavior(HitTestMode.Transparent)
  }
}

// 辅助函数：用 setTimeout 模拟 requestAnimationFrame（必须在组件之前定义）
