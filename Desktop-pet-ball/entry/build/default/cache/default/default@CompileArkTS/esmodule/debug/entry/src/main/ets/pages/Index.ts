if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface PetBallFallbackOverlay_Params {
    petBalls?: PetBallInstance[];
    screenWidth?: number;
    screenHeight?: number;
    ballSize?: number;
    isDragging?: boolean;
    selectedId?: string;
    coordinator?: DesktopPetCoordinator;
    motionEngine?: MotionEngine | null;
    collisionEngine?: CollisionEngine | null;
    animFrameId?: number;
    lastTime?: number;
    frameInterval?: number;
    tickCounter?: number;
    changeListener?: () => void;
}
interface Index_Params {
    petBallInstances?: PetBallInstance[];
    config?: AppConfig;
    selectMode?: boolean;
    selectedIds?: Set<string>;
    deleteTargetIds?: string[];
    showDeleteConfirm?: boolean;
    floatWindowReady?: boolean;
    logger?: Logger;
    instanceManager?: InstanceManager | null;
    cultivationManager?: CultivationManager | null;
    resourceManager?: ResourceManager;
    stateManager?: StateManager | null;
    deviceAdapter?: DeviceAdapter;
    configManager?: ConfigManager;
    pairingManager?: PairingManager;
    transferController?: TransferController | null;
    coordinator?: DesktopPetCoordinator;
}
import type { PetBallInstance, AppConfig } from '../dao/DataModels';
import { InstanceManager } from "@bundle:com.example.desktoppetball/entry/ets/manager/InstanceManager";
import { CultivationManager } from "@bundle:com.example.desktoppetball/entry/ets/manager/CultivationManager";
import { ResourceManager } from "@bundle:com.example.desktoppetball/entry/ets/manager/ResourceManager";
import { StateManager } from "@bundle:com.example.desktoppetball/entry/ets/manager/StateManager";
import { PairingManager } from "@bundle:com.example.desktoppetball/entry/ets/manager/PairingManager";
import { TransferController } from "@bundle:com.example.desktoppetball/entry/ets/manager/TransferController";
import { DeviceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/service/DeviceAdapter";
import { ConfigManager } from "@bundle:com.example.desktoppetball/entry/ets/service/ConfigManager";
import { DesktopPetCoordinator } from "@bundle:com.example.desktoppetball/entry/ets/coordinator/DesktopPetCoordinator";
import { MotionEngine } from "@bundle:com.example.desktoppetball/entry/ets/engine/MotionEngine";
import { CollisionEngine } from "@bundle:com.example.desktoppetball/entry/ets/engine/CollisionEngine";
import { PhysicsUtils } from "@bundle:com.example.desktoppetball/entry/ets/utils/PhysicsUtils";
import { Logger, LogLevel } from "@bundle:com.example.desktoppetball/entry/ets/utils/Logger";
import type common from "@ohos:app.ability.common";
import promptAction from "@ohos:promptAction";
import display from "@ohos:display";
class Index extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__petBallInstances = new ObservedPropertyObjectPU([], this, "petBallInstances");
        this.__config = new ObservedPropertyObjectPU({
            motionMode: 'free_rolling',
            motionSpeed: 100,
            judgmentLinePosition: 'bottom',
            petBallSizeCoefficient: 1.0,
            version: '1.0.0'
        }, this, "config");
        this.__selectMode = new ObservedPropertySimplePU(false, this, "selectMode");
        this.__selectedIds = new ObservedPropertyObjectPU(new Set(), this, "selectedIds");
        this.__deleteTargetIds = new ObservedPropertyObjectPU([], this, "deleteTargetIds");
        this.__showDeleteConfirm = new ObservedPropertySimplePU(false, this, "showDeleteConfirm");
        this.__floatWindowReady = this.createStorageLink('floatWindowReady', true, "floatWindowReady");
        this.logger = Logger.getInstance();
        this.instanceManager = null;
        this.cultivationManager = null;
        this.resourceManager = new ResourceManager();
        this.stateManager = null;
        this.deviceAdapter = new DeviceAdapter();
        this.configManager = new ConfigManager();
        this.pairingManager = new PairingManager();
        this.transferController = null;
        this.coordinator = DesktopPetCoordinator.getInstance();
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: Index_Params) {
        if (params.petBallInstances !== undefined) {
            this.petBallInstances = params.petBallInstances;
        }
        if (params.config !== undefined) {
            this.config = params.config;
        }
        if (params.selectMode !== undefined) {
            this.selectMode = params.selectMode;
        }
        if (params.selectedIds !== undefined) {
            this.selectedIds = params.selectedIds;
        }
        if (params.deleteTargetIds !== undefined) {
            this.deleteTargetIds = params.deleteTargetIds;
        }
        if (params.showDeleteConfirm !== undefined) {
            this.showDeleteConfirm = params.showDeleteConfirm;
        }
        if (params.logger !== undefined) {
            this.logger = params.logger;
        }
        if (params.instanceManager !== undefined) {
            this.instanceManager = params.instanceManager;
        }
        if (params.cultivationManager !== undefined) {
            this.cultivationManager = params.cultivationManager;
        }
        if (params.resourceManager !== undefined) {
            this.resourceManager = params.resourceManager;
        }
        if (params.stateManager !== undefined) {
            this.stateManager = params.stateManager;
        }
        if (params.deviceAdapter !== undefined) {
            this.deviceAdapter = params.deviceAdapter;
        }
        if (params.configManager !== undefined) {
            this.configManager = params.configManager;
        }
        if (params.pairingManager !== undefined) {
            this.pairingManager = params.pairingManager;
        }
        if (params.transferController !== undefined) {
            this.transferController = params.transferController;
        }
        if (params.coordinator !== undefined) {
            this.coordinator = params.coordinator;
        }
    }
    updateStateVars(params: Index_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__petBallInstances.purgeDependencyOnElmtId(rmElmtId);
        this.__config.purgeDependencyOnElmtId(rmElmtId);
        this.__selectMode.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedIds.purgeDependencyOnElmtId(rmElmtId);
        this.__deleteTargetIds.purgeDependencyOnElmtId(rmElmtId);
        this.__showDeleteConfirm.purgeDependencyOnElmtId(rmElmtId);
        this.__floatWindowReady.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__petBallInstances.aboutToBeDeleted();
        this.__config.aboutToBeDeleted();
        this.__selectMode.aboutToBeDeleted();
        this.__selectedIds.aboutToBeDeleted();
        this.__deleteTargetIds.aboutToBeDeleted();
        this.__showDeleteConfirm.aboutToBeDeleted();
        this.__floatWindowReady.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __petBallInstances: ObservedPropertyObjectPU<PetBallInstance[]>;
    get petBallInstances() {
        return this.__petBallInstances.get();
    }
    set petBallInstances(newValue: PetBallInstance[]) {
        this.__petBallInstances.set(newValue);
    }
    private __config: ObservedPropertyObjectPU<AppConfig>;
    get config() {
        return this.__config.get();
    }
    set config(newValue: AppConfig) {
        this.__config.set(newValue);
    }
    // —— 选择 / 删除 ——
    private __selectMode: ObservedPropertySimplePU<boolean>; // 是否在选择模式
    get selectMode() {
        return this.__selectMode.get();
    }
    set selectMode(newValue: boolean) {
        this.__selectMode.set(newValue);
    }
    private __selectedIds: ObservedPropertyObjectPU<Set<string>>; // 已勾选的球 ID
    get selectedIds() {
        return this.__selectedIds.get();
    }
    set selectedIds(newValue: Set<string>) {
        this.__selectedIds.set(newValue);
    }
    private __deleteTargetIds: ObservedPropertyObjectPU<string[]>; // 待删除的 ID 列表（单个或批量）
    get deleteTargetIds() {
        return this.__deleteTargetIds.get();
    }
    set deleteTargetIds(newValue: string[]) {
        this.__deleteTargetIds.set(newValue);
    }
    private __showDeleteConfirm: ObservedPropertySimplePU<boolean>;
    get showDeleteConfirm() {
        return this.__showDeleteConfirm.get();
    }
    set showDeleteConfirm(newValue: boolean) {
        this.__showDeleteConfirm.set(newValue);
    }
    private __floatWindowReady: ObservedPropertyAbstractPU<boolean>;
    get floatWindowReady() {
        return this.__floatWindowReady.get();
    }
    set floatWindowReady(newValue: boolean) {
        this.__floatWindowReady.set(newValue);
    }
    private logger: Logger;
    private instanceManager: InstanceManager | null;
    private cultivationManager: CultivationManager | null;
    private resourceManager: ResourceManager;
    private stateManager: StateManager | null;
    private deviceAdapter: DeviceAdapter;
    private configManager: ConfigManager;
    private pairingManager: PairingManager;
    private transferController: TransferController | null;
    private coordinator: DesktopPetCoordinator;
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
            }
            catch (_e) {
                this.logger.warn('Index', '设备适配器初始化失败');
            }
            // 配置
            try {
                await this.configManager.init(context);
                const cfg = await this.configManager.loadConfig();
                if (cfg)
                    this.config = cfg;
            }
            catch (_e) {
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
            }
            catch (_e) {
                this.logger.warn('Index', '培养管理器初始化失败');
                this.cultivationManager = new CultivationManager();
            }
            // 状态管理器
            try {
                this.stateManager = new StateManager(this.cultivationManager);
                await this.stateManager.init(context);
            }
            catch (_e) {
                this.logger.warn('Index', '状态管理器初始化失败');
                this.stateManager = new StateManager(this.cultivationManager);
            }
            // 资源管理器
            try {
                await this.resourceManager.init(context);
            }
            catch (_e) {
                this.logger.warn('Index', '资源管理器初始化失败');
            }
            // 分布式传递
            try {
                await this.pairingManager.init(context);
                await this.pairingManager.initKvStore('pet_ball_transfer');
                this.transferController = new TransferController(this.pairingManager, this.instanceManager, this.resourceManager, this.cultivationManager!);
            }
            catch (_e) {
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
        }
        catch (error) {
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
        if (!this.instanceManager)
            return;
        if (!this.instanceManager.canCreateInstance()) {
            this.showToast('已达到最大宠物球数量');
            return;
        }
        const instance = this.instanceManager.createInstance('default_ball', { x: 200 + Math.random() * 200, y: 200 + Math.random() * 400 }, { vx: (Math.random() - 0.5) * 100, vy: (Math.random() - 0.5) * 100, speed: 50 });
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
        }
        else {
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
        if (targets.length === 0)
            return;
        const instance = this.petBallInstances.find(inst => inst.id === instanceId);
        if (!instance)
            return;
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
        if (id.length <= 10)
            return id;
        return id.slice(0, 6) + '...' + id.slice(-4);
    }
    private showToast(msg: string): void {
        promptAction.showToast({ message: msg, duration: 2000, bottom: '80vp' });
    }
    // ==================== UI ====================
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.width('100%');
            Stack.height('100%');
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#FFFFFF');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ---- 标题栏 ----
            Row.create();
            // ---- 标题栏 ----
            Row.width('100%');
            // ---- 标题栏 ----
            Row.padding({ left: 20, right: 20, top: 16, bottom: 12 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('🐱 宠物球管理');
            Text.fontSize(22);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#1A1A2E');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.selectMode && this.selectedIds.size > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 选择模式下显示已选数量
                        Text.create(`已选 ${this.selectedIds.size}`);
                        // 选择模式下显示已选数量
                        Text.fontSize(13);
                        // 选择模式下显示已选数量
                        Text.fontColor('#FFFFFF');
                        // 选择模式下显示已选数量
                        Text.padding({ left: 10, right: 10, top: 4, bottom: 4 });
                        // 选择模式下显示已选数量
                        Text.borderRadius(12);
                        // 选择模式下显示已选数量
                        Text.backgroundColor('#FF6B6B');
                        // 选择模式下显示已选数量
                        Text.margin({ right: 8 });
                    }, Text);
                    // 选择模式下显示已选数量
                    Text.pop();
                });
            }
            // 桌面显示计数徽章
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 桌面显示计数徽章
            Row.create();
            // 桌面显示计数徽章
            Row.padding({ left: 10, right: 10, top: 4, bottom: 4 });
            // 桌面显示计数徽章
            Row.borderRadius(12);
            // 桌面显示计数徽章
            Row.backgroundColor(this.desktopVisibleCount > 0 ? '#E0F7FA' : '#F5F5F5');
            // 桌面显示计数徽章
            Row.margin({ right: 10 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`桌面 ${this.desktopVisibleCount}/${this.petBallInstances.length}`);
            Text.fontSize(13);
            Text.fontColor(this.desktopVisibleCount > 0 ? '#4ECDC4' : '#999999');
        }, Text);
        Text.pop();
        // 桌面显示计数徽章
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 选择模式开关
            Button.createWithLabel(this.selectMode ? '完成' : '选择');
            // 选择模式开关
            Button.fontSize(13);
            // 选择模式开关
            Button.height(32);
            // 选择模式开关
            Button.padding({ left: 12, right: 12 });
            // 选择模式开关
            Button.borderRadius(16);
            // 选择模式开关
            Button.backgroundColor(this.selectMode ? '#4ECDC4' : '#F0F0F0');
            // 选择模式开关
            Button.fontColor(this.selectMode ? '#FFFFFF' : '#666666');
            // 选择模式开关
            Button.onClick(() => this.toggleSelectMode());
        }, Button);
        // 选择模式开关
        Button.pop();
        // ---- 标题栏 ----
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ---- 分割线 ----
            Divider.create();
            // ---- 分割线 ----
            Divider.color('#E0E0E0');
            // ---- 分割线 ----
            Divider.strokeWidth(1);
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // ---- 宠物球列表 ----
            if (this.petBallInstances.length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create();
                        Column.width('100%');
                        Column.layoutWeight(1);
                        Column.justifyContent(FlexAlign.Center);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('😺');
                        Text.fontSize(48);
                        Text.margin({ bottom: 12 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('还没有宠物球');
                        Text.fontSize(16);
                        Text.fontColor('#888888');
                        Text.margin({ bottom: 4 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('点击下方按钮添加第一个吧');
                        Text.fontSize(13);
                        Text.fontColor('#AAAAAA');
                    }, Text);
                    Text.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        List.create();
                        List.width('100%');
                        List.layoutWeight(1);
                        List.divider({ strokeWidth: 1, color: '#F0F0F0' });
                    }, List);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const instance = _item;
                            {
                                const itemCreation = (elmtId, isInitialRender) => {
                                    ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                                    ListItem.create(deepRenderFunction, true);
                                    if (!isInitialRender) {
                                        ListItem.pop();
                                    }
                                    ViewStackProcessor.StopGetAccessRecording();
                                };
                                const itemCreation2 = (elmtId, isInitialRender) => {
                                    ListItem.create(deepRenderFunction, true);
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create();
                                        Row.width('100%');
                                        Row.padding({ left: 20, right: 16, top: 14, bottom: 14 });
                                        Row.alignItems(VerticalAlign.Center);
                                        Row.onClick(() => {
                                            // 选择模式下点击整行切换勾选
                                            if (this.selectMode) {
                                                this.toggleSelect(instance.id);
                                            }
                                        });
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        If.create();
                                        // 选择模式下显示勾选框
                                        if (this.selectMode) {
                                            this.ifElseBranchUpdateFunction(0, () => {
                                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                                    Checkbox.create();
                                                    Checkbox.select(this.selectedIds.has(instance.id));
                                                    Checkbox.selectedColor('#4ECDC4');
                                                    Checkbox.onChange((checked: boolean) => {
                                                        this.toggleSelect(instance.id);
                                                    });
                                                    Checkbox.margin({ right: 12 });
                                                }, Checkbox);
                                                Checkbox.pop();
                                            });
                                        }
                                        // 球颜色预览
                                        else {
                                            this.ifElseBranchUpdateFunction(1, () => {
                                            });
                                        }
                                    }, If);
                                    If.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 球颜色预览
                                        Circle.create();
                                        // 球颜色预览
                                        Circle.width(40);
                                        // 球颜色预览
                                        Circle.height(40);
                                        // 球颜色预览
                                        Circle.fill(this.getBallColor(instance));
                                        // 球颜色预览
                                        Circle.stroke('#E0E0E0');
                                        // 球颜色预览
                                        Circle.strokeWidth(2);
                                        // 球颜色预览
                                        Circle.shadow({ radius: 6, color: '#10000000' });
                                        // 球颜色预览
                                        Circle.margin({ right: 14 });
                                    }, Circle);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        // 信息
                                        Column.create();
                                        // 信息
                                        Column.alignItems(HorizontalAlign.Start);
                                        // 信息
                                        Column.margin({ right: 8 });
                                    }, Column);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(this.shortId(instance.id));
                                        Text.fontSize(15);
                                        Text.fontWeight(FontWeight.Medium);
                                        Text.fontColor('#1A1A2E');
                                        Text.maxLines(1);
                                        Text.textOverflow({ overflow: TextOverflow.Ellipsis });
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(`等级 ${this.cultivationManager?.getLevel(instance.id) || 1}`);
                                        Text.fontSize(12);
                                        Text.fontColor('#999999');
                                    }, Text);
                                    Text.pop();
                                    // 信息
                                    Column.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Blank.create();
                                    }, Blank);
                                    Blank.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        If.create();
                                        if (!this.selectMode) {
                                            this.ifElseBranchUpdateFunction(0, () => {
                                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                                    // 桌面显示开关（正常模式）
                                                    Toggle.create({ type: ToggleType.Switch, isOn: this.coordinator.isDesktopVisible(instance.id) });
                                                    // 桌面显示开关（正常模式）
                                                    Toggle.selectedColor('#4ECDC4');
                                                    // 桌面显示开关（正常模式）
                                                    Toggle.onChange((isOn: boolean) => {
                                                        this.toggleDesktop(instance.id, isOn);
                                                    });
                                                    // 桌面显示开关（正常模式）
                                                    Toggle.margin({ right: 8 });
                                                }, Toggle);
                                                // 桌面显示开关（正常模式）
                                                Toggle.pop();
                                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                                    // 删除按钮（正常模式）
                                                    Button.createWithChild({ type: ButtonType.Circle });
                                                    // 删除按钮（正常模式）
                                                    Button.width(36);
                                                    // 删除按钮（正常模式）
                                                    Button.height(36);
                                                    // 删除按钮（正常模式）
                                                    Button.backgroundColor('#FFF0F0');
                                                    // 删除按钮（正常模式）
                                                    Button.onClick(() => {
                                                        this.confirmDeleteOne(instance.id);
                                                    });
                                                }, Button);
                                                this.observeComponentCreation2((elmtId, isInitialRender) => {
                                                    Text.create('🗑');
                                                    Text.fontSize(16);
                                                }, Text);
                                                Text.pop();
                                                // 删除按钮（正常模式）
                                                Button.pop();
                                            });
                                        }
                                        else {
                                            this.ifElseBranchUpdateFunction(1, () => {
                                            });
                                        }
                                    }, If);
                                    If.pop();
                                    Row.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.petBallInstances, forEachItemGenFunction, (instance: PetBallInstance) => instance.id, false, false);
                    }, ForEach);
                    ForEach.pop();
                    List.pop();
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // ---- 底部操作栏 ----
            Column.create();
            // ---- 底部操作栏 ----
            Column.width('100%');
            // ---- 底部操作栏 ----
            Column.padding({ top: 8, bottom: 24 });
            // ---- 底部操作栏 ----
            Column.backgroundColor('#FAFAFA');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.selectMode) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // ===== 选择模式底栏 =====
                        Row.create();
                        // ===== 选择模式底栏 =====
                        Row.width('100%');
                        // ===== 选择模式底栏 =====
                        Row.padding({ top: 12, bottom: 12 });
                        // ===== 选择模式底栏 =====
                        Row.backgroundColor('#FFFFFF');
                        // ===== 选择模式底栏 =====
                        Row.border({ width: { top: 1 }, color: '#F0F0F0' });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 全选 / 取消全选
                        Row.create();
                        // 全选 / 取消全选
                        Row.margin({ left: 20 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Checkbox.create();
                        Checkbox.select(this.selectedIds.size === this.petBallInstances.length && this.petBallInstances.length > 0);
                        Checkbox.selectedColor('#4ECDC4');
                        Checkbox.onChange((checked: boolean) => {
                            if (checked) {
                                this.selectAll();
                            }
                            else {
                                this.deselectAll();
                            }
                        });
                    }, Checkbox);
                    Checkbox.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('全选');
                        Text.fontSize(14);
                        Text.fontColor('#666666');
                        Text.margin({ left: 6 });
                    }, Text);
                    Text.pop();
                    // 全选 / 取消全选
                    Row.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Blank.create();
                    }, Blank);
                    Blank.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 批量删除按钮
                        Button.createWithLabel('🗑 批量删除');
                        // 批量删除按钮
                        Button.fontSize(14);
                        // 批量删除按钮
                        Button.fontWeight(FontWeight.Medium);
                        // 批量删除按钮
                        Button.height(40);
                        // 批量删除按钮
                        Button.padding({ left: 16, right: 16 });
                        // 批量删除按钮
                        Button.borderRadius(20);
                        // 批量删除按钮
                        Button.backgroundColor(this.selectedIds.size > 0 ? '#FF6B6B' : '#E0E0E0');
                        // 批量删除按钮
                        Button.fontColor(this.selectedIds.size > 0 ? '#FFFFFF' : '#999999');
                        // 批量删除按钮
                        Button.enabled(this.selectedIds.size > 0);
                        // 批量删除按钮
                        Button.onClick(() => {
                            this.confirmDeleteSelected();
                        });
                        // 批量删除按钮
                        Button.margin({ right: 16 });
                    }, Button);
                    // 批量删除按钮
                    Button.pop();
                    // ===== 选择模式底栏 =====
                    Row.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.createWithLabel('＋ 添加新宠物球');
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.fontSize(16);
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.fontWeight(FontWeight.Medium);
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.width('90%');
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.height(48);
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.borderRadius(24);
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.backgroundColor('#4ECDC4');
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.fontColor('#FFFFFF');
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.shadow({ radius: 8, color: '#204ECDC4', offsetY: 3 });
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.margin({ bottom: 16 });
                        // ===== 正常模式底栏 =====
                        // 添加按钮
                        Button.onClick(() => {
                            this.createNewPetBall();
                        });
                    }, Button);
                    // ===== 正常模式底栏 =====
                    // 添加按钮
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 导航按钮行
                        Row.create();
                        // 导航按钮行
                        Row.width('90%');
                        // 导航按钮行
                        Row.justifyContent(FlexAlign.SpaceEvenly);
                    }, Row);
                    this.NavButton.bind(this)('⚙', '设置', () => {
                        this.getUIContext().getRouter().pushUrl({ url: 'pages/SettingsPage' });
                    });
                    this.NavButton.bind(this)('🎨', '资源', () => {
                        this.getUIContext().getRouter().pushUrl({ url: 'pages/ResourceManagerPage' });
                    });
                    this.NavButton.bind(this)('📤', '传递', () => {
                        const selected = this.petBallInstances.find(b => this.coordinator.isDesktopVisible(b.id)) || this.petBallInstances[0];
                        if (selected) {
                            this.initiateTransfer(selected.id);
                        }
                        else {
                            this.showToast('没有可传递的宠物球');
                        }
                    });
                    this.NavButton.bind(this)('🐛', '测试', () => {
                        this.testShowPetBalls();
                    });
                    // 导航按钮行
                    Row.pop();
                });
            }
        }, If);
        If.pop();
        // ---- 底部操作栏 ----
        Column.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // ---- 宠物球回退渲染层（手机端浮窗不可用时，在主窗口内渲染宠物球） ----
            if (this.showFallbackOverlay) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        __Common__.create();
                        __Common__.zIndex(9999);
                        __Common__.backgroundColor('#00000000');
                    }, __Common__);
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new PetBallFallbackOverlay(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 623, col: 9 });
                                ViewPU.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "PetBallFallbackOverlay" });
                    }
                    __Common__.pop();
                });
            }
            // ---- 删除确认遮罩 ----
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // ---- 删除确认遮罩 ----
            if (this.showDeleteConfirm) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Stack.create();
                        Stack.width('100%');
                        Stack.height('100%');
                    }, Stack);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 暗色背景层：点击可关闭
                        Column.create();
                        // 暗色背景层：点击可关闭
                        Column.width('100%');
                        // 暗色背景层：点击可关闭
                        Column.height('100%');
                        // 暗色背景层：点击可关闭
                        Column.backgroundColor('#60000000');
                        // 暗色背景层：点击可关闭
                        Column.onClick(() => this.cancelDelete());
                    }, Column);
                    // 暗色背景层：点击可关闭
                    Column.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        // 弹窗卡片层：用空 onClick 吞掉事件，防止穿透到背景层
                        Column.create();
                        // 弹窗卡片层：用空 onClick 吞掉事件，防止穿透到背景层
                        Column.width('75%');
                        // 弹窗卡片层：用空 onClick 吞掉事件，防止穿透到背景层
                        Column.padding(24);
                        // 弹窗卡片层：用空 onClick 吞掉事件，防止穿透到背景层
                        Column.borderRadius(16);
                        // 弹窗卡片层：用空 onClick 吞掉事件，防止穿透到背景层
                        Column.backgroundColor('#FFFFFF');
                        // 弹窗卡片层：用空 onClick 吞掉事件，防止穿透到背景层
                        Column.shadow({ radius: 20, color: '#30000000' });
                        // 弹窗卡片层：用空 onClick 吞掉事件，防止穿透到背景层
                        Column.onClick(() => { });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('确认删除');
                        Text.fontSize(18);
                        Text.fontWeight(FontWeight.Bold);
                        Text.margin({ bottom: 10 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.deleteTargetIds.length > 1
                            ? `即将删除 ${this.deleteTargetIds.length} 个宠物球，删除后将从桌面消失且无法恢复`
                            : '删除后宠物球将从桌面消失且无法恢复');
                        Text.fontSize(14);
                        Text.fontColor('#666666');
                        Text.textAlign(TextAlign.Center);
                        Text.margin({ bottom: 20 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create();
                        Row.width('100%');
                        Row.justifyContent(FlexAlign.SpaceEvenly);
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('取消');
                        Button.fontSize(15);
                        Button.width('40%');
                        Button.height(40);
                        Button.borderRadius(20);
                        Button.backgroundColor('#F0F0F0');
                        Button.fontColor('#666666');
                        Button.onClick(() => this.cancelDelete());
                    }, Button);
                    Button.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('删除');
                        Button.fontSize(15);
                        Button.width('40%');
                        Button.height(40);
                        Button.borderRadius(20);
                        Button.backgroundColor('#FF6B6B');
                        Button.fontColor('#FFFFFF');
                        Button.onClick(() => this.executeDelete());
                    }, Button);
                    Button.pop();
                    Row.pop();
                    // 弹窗卡片层：用空 onClick 吞掉事件，防止穿透到背景层
                    Column.pop();
                    Stack.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Stack.pop();
    }
    NavButton(icon: string, label: string, action: () => void, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(64);
            Column.padding({ top: 8, bottom: 8 });
            Column.borderRadius(12);
            Column.onClick(action);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(icon);
            Text.fontSize(22);
            Text.margin({ bottom: 2 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(label);
            Text.fontSize(11);
            Text.fontColor('#666666');
        }, Text);
        Text.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
function requestAnimationFrame(cb: () => void): number {
    return setTimeout(cb, 16);
}
function cancelAnimationFrame(id: number): void {
    clearTimeout(id);
}
class PetBallFallbackOverlay extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__petBalls = new ObservedPropertyObjectPU([], this, "petBalls");
        this.__screenWidth = new ObservedPropertySimplePU(360, this, "screenWidth");
        this.__screenHeight = new ObservedPropertySimplePU(800, this, "screenHeight");
        this.__ballSize = new ObservedPropertySimplePU(100, this, "ballSize");
        this.__isDragging = new ObservedPropertySimplePU(false, this, "isDragging");
        this.__selectedId = new ObservedPropertySimplePU('', this, "selectedId");
        this.coordinator = DesktopPetCoordinator.getInstance();
        this.motionEngine = null;
        this.collisionEngine = null;
        this.animFrameId = -1;
        this.lastTime = 0;
        this.frameInterval = 16.67;
        this.tickCounter = 0;
        this.changeListener = () => {
            this.onCoordinatorChanged();
        };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: PetBallFallbackOverlay_Params) {
        if (params.petBalls !== undefined) {
            this.petBalls = params.petBalls;
        }
        if (params.screenWidth !== undefined) {
            this.screenWidth = params.screenWidth;
        }
        if (params.screenHeight !== undefined) {
            this.screenHeight = params.screenHeight;
        }
        if (params.ballSize !== undefined) {
            this.ballSize = params.ballSize;
        }
        if (params.isDragging !== undefined) {
            this.isDragging = params.isDragging;
        }
        if (params.selectedId !== undefined) {
            this.selectedId = params.selectedId;
        }
        if (params.coordinator !== undefined) {
            this.coordinator = params.coordinator;
        }
        if (params.motionEngine !== undefined) {
            this.motionEngine = params.motionEngine;
        }
        if (params.collisionEngine !== undefined) {
            this.collisionEngine = params.collisionEngine;
        }
        if (params.animFrameId !== undefined) {
            this.animFrameId = params.animFrameId;
        }
        if (params.lastTime !== undefined) {
            this.lastTime = params.lastTime;
        }
        if (params.frameInterval !== undefined) {
            this.frameInterval = params.frameInterval;
        }
        if (params.tickCounter !== undefined) {
            this.tickCounter = params.tickCounter;
        }
        if (params.changeListener !== undefined) {
            this.changeListener = params.changeListener;
        }
    }
    updateStateVars(params: PetBallFallbackOverlay_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__petBalls.purgeDependencyOnElmtId(rmElmtId);
        this.__screenWidth.purgeDependencyOnElmtId(rmElmtId);
        this.__screenHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__ballSize.purgeDependencyOnElmtId(rmElmtId);
        this.__isDragging.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedId.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__petBalls.aboutToBeDeleted();
        this.__screenWidth.aboutToBeDeleted();
        this.__screenHeight.aboutToBeDeleted();
        this.__ballSize.aboutToBeDeleted();
        this.__isDragging.aboutToBeDeleted();
        this.__selectedId.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __petBalls: ObservedPropertyObjectPU<PetBallInstance[]>;
    get petBalls() {
        return this.__petBalls.get();
    }
    set petBalls(newValue: PetBallInstance[]) {
        this.__petBalls.set(newValue);
    }
    private __screenWidth: ObservedPropertySimplePU<number>;
    get screenWidth() {
        return this.__screenWidth.get();
    }
    set screenWidth(newValue: number) {
        this.__screenWidth.set(newValue);
    }
    private __screenHeight: ObservedPropertySimplePU<number>;
    get screenHeight() {
        return this.__screenHeight.get();
    }
    set screenHeight(newValue: number) {
        this.__screenHeight.set(newValue);
    }
    private __ballSize: ObservedPropertySimplePU<number>;
    get ballSize() {
        return this.__ballSize.get();
    }
    set ballSize(newValue: number) {
        this.__ballSize.set(newValue);
    }
    private __isDragging: ObservedPropertySimplePU<boolean>;
    get isDragging() {
        return this.__isDragging.get();
    }
    set isDragging(newValue: boolean) {
        this.__isDragging.set(newValue);
    }
    private __selectedId: ObservedPropertySimplePU<string>;
    get selectedId() {
        return this.__selectedId.get();
    }
    set selectedId(newValue: string) {
        this.__selectedId.set(newValue);
    }
    private coordinator: DesktopPetCoordinator;
    private motionEngine: MotionEngine | null;
    private collisionEngine: CollisionEngine | null;
    private animFrameId: number;
    private lastTime: number;
    private frameInterval: number;
    private tickCounter: number;
    // 用闭包保存监听器引用
    private changeListener: () => void;
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
        }
        catch (_e) {
            this.screenWidth = 360;
            this.screenHeight = 800;
        }
        this.ballSize = 100;
        this.motionEngine = new MotionEngine(this.screenWidth, this.screenHeight, this.ballSize / 2);
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
            }
            else {
                this.coordinator.removeFromDesktop(id);
            }
        }
        this.petBalls = visible;
        if (visible.length > 0 && this.animFrameId === -1) {
            this.lastTime = Date.now();
            this.animLoop();
        }
        else if (visible.length === 0 && this.animFrameId !== -1) {
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
        if (!this.motionEngine)
            return;
        const validIds = new Set(this.coordinator.getDesktopVisibleIds());
        this.petBalls = this.petBalls.filter(b => validIds.has(b.id));
        if (this.petBalls.length === 0)
            return;
        for (const ball of this.petBalls) {
            if (this.isDragging && ball.id === this.selectedId)
                continue;
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
                    const vels = PhysicsUtils.calculateElasticCollision(this.petBalls[i1].position, this.petBalls[i1].velocity, this.petBalls[i2].position, this.petBalls[i2].velocity);
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
        if (!this.isDragging)
            return;
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
        if (id.length <= 8)
            return id;
        return '...' + id.slice(-4);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.width('100%');
            Stack.height('100%');
            Stack.backgroundColor('transparent');
            Stack.hitTestBehavior(HitTestMode.Transparent);
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const ball = _item;
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Stack.create();
                    Stack.width(this.ballSize);
                    Stack.height(this.ballSize);
                    Stack.position({
                        x: ball.position.x - this.ballSize / 2,
                        y: ball.position.y - this.ballSize / 2
                    });
                    Stack.hitTestBehavior(HitTestMode.Block);
                    Gesture.create(GesturePriority.Low);
                    GestureGroup.create(GestureMode.Exclusive);
                    PanGesture.create({ fingers: 1, direction: PanDirection.All });
                    PanGesture.onActionStart(() => this.handleDragStart(ball.id));
                    PanGesture.onActionUpdate((e: GestureEvent) => this.handleDragUpdate(ball.id, e.offsetX, e.offsetY));
                    PanGesture.onActionEnd(() => this.handleDragEnd(ball.id));
                    PanGesture.pop();
                    TapGesture.create({ count: 1 });
                    TapGesture.onAction(() => this.handleTap(ball.id));
                    TapGesture.pop();
                    GestureGroup.pop();
                    Gesture.pop();
                }, Stack);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Circle.create();
                    Circle.width(this.ballSize);
                    Circle.height(this.ballSize);
                    Circle.fill(this.ballColor(ball.affectionValue));
                    Circle.stroke('#FFA500');
                    Circle.strokeWidth(3);
                    Circle.shadow({ radius: 12, color: '#30000000', offsetX: 2, offsetY: 4 });
                }, Circle);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Text.create(this.shortId(ball.id));
                    Text.fontSize(10);
                    Text.fontColor('#FFFFFF');
                    Text.backgroundColor('#40000000');
                    Text.borderRadius(4);
                    Text.padding({ left: 4, right: 4, top: 1, bottom: 1 });
                }, Text);
                Text.pop();
                Stack.pop();
            };
            this.forEachUpdateFunction(elmtId, this.petBalls, forEachItemGenFunction, (ball: PetBallInstance) => ball.id, false, false);
        }, ForEach);
        ForEach.pop();
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.desktoppetball", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
