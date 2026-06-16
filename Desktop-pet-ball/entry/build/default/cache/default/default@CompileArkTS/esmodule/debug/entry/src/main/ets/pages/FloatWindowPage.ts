if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface FloatWindowPage_Params {
    petBallInstances?: PetBallInstance[];
    screenWidth?: number;
    screenHeight?: number;
    petBallSize?: number;
    isDragging?: boolean;
    selectedId?: string;
    motionEngine?: MotionEngine | null;
    collisionEngine?: CollisionEngine | null;
    deviceAdapter?: DeviceAdapter;
    coordinator?: DesktopPetCoordinator;
    animFrameId?: number;
    lastTime?: number;
    frameInterval?: number;
    counter?: number;
    changeListener?: () => void;
}
import type { PetBallInstance } from '../dao/DataModels';
import { MotionEngine } from "@bundle:com.example.desktoppetball/entry/ets/engine/MotionEngine";
import { CollisionEngine } from "@bundle:com.example.desktoppetball/entry/ets/engine/CollisionEngine";
import { DeviceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/service/DeviceAdapter";
import { PhysicsUtils } from "@bundle:com.example.desktoppetball/entry/ets/utils/PhysicsUtils";
import { DesktopPetCoordinator } from "@bundle:com.example.desktoppetball/entry/ets/coordinator/DesktopPetCoordinator";
import type common from "@ohos:app.ability.common";
class FloatWindowPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__petBallInstances = new ObservedPropertyObjectPU([], this, "petBallInstances");
        this.__screenWidth = new ObservedPropertySimplePU(360, this, "screenWidth");
        this.__screenHeight = new ObservedPropertySimplePU(800, this, "screenHeight");
        this.__petBallSize = new ObservedPropertySimplePU(120, this, "petBallSize");
        this.__isDragging = new ObservedPropertySimplePU(false, this, "isDragging");
        this.__selectedId = new ObservedPropertySimplePU('', this, "selectedId");
        this.motionEngine = null;
        this.collisionEngine = null;
        this.deviceAdapter = new DeviceAdapter();
        this.coordinator = DesktopPetCoordinator.getInstance();
        this.animFrameId = -1;
        this.lastTime = 0;
        this.frameInterval = 16.67;
        this.counter = 0;
        this.changeListener = () => {
            this.onCoordinatorChanged();
        };
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: FloatWindowPage_Params) {
        if (params.petBallInstances !== undefined) {
            this.petBallInstances = params.petBallInstances;
        }
        if (params.screenWidth !== undefined) {
            this.screenWidth = params.screenWidth;
        }
        if (params.screenHeight !== undefined) {
            this.screenHeight = params.screenHeight;
        }
        if (params.petBallSize !== undefined) {
            this.petBallSize = params.petBallSize;
        }
        if (params.isDragging !== undefined) {
            this.isDragging = params.isDragging;
        }
        if (params.selectedId !== undefined) {
            this.selectedId = params.selectedId;
        }
        if (params.motionEngine !== undefined) {
            this.motionEngine = params.motionEngine;
        }
        if (params.collisionEngine !== undefined) {
            this.collisionEngine = params.collisionEngine;
        }
        if (params.deviceAdapter !== undefined) {
            this.deviceAdapter = params.deviceAdapter;
        }
        if (params.coordinator !== undefined) {
            this.coordinator = params.coordinator;
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
        if (params.counter !== undefined) {
            this.counter = params.counter;
        }
        if (params.changeListener !== undefined) {
            this.changeListener = params.changeListener;
        }
    }
    updateStateVars(params: FloatWindowPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__petBallInstances.purgeDependencyOnElmtId(rmElmtId);
        this.__screenWidth.purgeDependencyOnElmtId(rmElmtId);
        this.__screenHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__petBallSize.purgeDependencyOnElmtId(rmElmtId);
        this.__isDragging.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedId.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__petBallInstances.aboutToBeDeleted();
        this.__screenWidth.aboutToBeDeleted();
        this.__screenHeight.aboutToBeDeleted();
        this.__petBallSize.aboutToBeDeleted();
        this.__isDragging.aboutToBeDeleted();
        this.__selectedId.aboutToBeDeleted();
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
    private __petBallSize: ObservedPropertySimplePU<number>;
    get petBallSize() {
        return this.__petBallSize.get();
    }
    set petBallSize(newValue: number) {
        this.__petBallSize.set(newValue);
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
    private motionEngine: MotionEngine | null;
    private collisionEngine: CollisionEngine | null;
    private deviceAdapter: DeviceAdapter;
    private coordinator: DesktopPetCoordinator;
    private animFrameId: number;
    private lastTime: number;
    private frameInterval: number;
    private counter: number;
    // 用闭包保存监听器引用以支持取消注册
    private changeListener: () => void;
    aboutToAppear(): void {
        this.initDevice();
        this.coordinator.onChange(this.changeListener);
        // 立即尝试加载
        this.onCoordinatorChanged();
    }
    aboutToDisappear(): void {
        if (this.animFrameId !== -1) {
            cancelAnimationFrame(this.animFrameId);
            this.animFrameId = -1;
        }
        this.coordinator.offChange(this.changeListener);
    }
    private initDevice(): void {
        try {
            const ctx = getContext(this) as common.UIAbilityContext;
            this.deviceAdapter.init(ctx);
            const size = this.deviceAdapter.getScreenSize();
            this.screenWidth = size.width;
            this.screenHeight = size.height;
            this.petBallSize = this.deviceAdapter.getAdaptedPetBallSize(120);
        }
        catch (_e) {
            this.screenWidth = 360;
            this.screenHeight = 800;
            this.petBallSize = 120;
        }
        this.motionEngine = new MotionEngine(this.screenWidth, this.screenHeight, this.petBallSize / 2);
        this.motionEngine.setStrategy('free_rolling');
        this.collisionEngine = new CollisionEngine(this.petBallSize / 2);
    }
    /**
     * Coordinator 变化回调：重新加载桌面可见的球列表，启动或停止动画循环
     */
    private onCoordinatorChanged(): void {
        const mgr = this.coordinator.getInstanceManager();
        if (!mgr) {
            this.petBallInstances = [];
            return;
        }
        const visibleIds = this.coordinator.getDesktopVisibleIds();
        // 过滤：只保留实例管理器中存在且被标记为桌面可见的
        const visible: PetBallInstance[] = [];
        for (const id of visibleIds) {
            const inst = mgr.getInstance(id);
            if (inst) {
                visible.push(inst);
            }
            else {
                // 实例已被删除，同步清理 coordinator
                this.coordinator.removeFromDesktop(id);
            }
        }
        this.petBallInstances = visible;
        if (visible.length > 0 && this.animFrameId === -1) {
            this.lastTime = Date.now();
            this.animLoop();
        }
        else if (visible.length === 0 && this.animFrameId !== -1) {
            cancelAnimationFrame(this.animFrameId);
            this.animFrameId = -1;
        }
    }
    // ---------- 物理动画 ----------
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
        // 同步清理已被移除的球
        const validIds = new Set(this.coordinator.getDesktopVisibleIds());
        this.petBallInstances = this.petBallInstances.filter(b => validIds.has(b.id));
        if (this.petBallInstances.length === 0)
            return;
        for (const ball of this.petBallInstances) {
            if (this.isDragging && ball.id === this.selectedId)
                continue;
            const r = this.motionEngine.update(ball.position, ball.velocity, dt);
            ball.position = r.position;
            ball.velocity = r.velocity;
        }
        // 碰撞检测
        if (this.collisionEngine && this.petBallInstances.length > 1) {
            const cols = this.collisionEngine.detectCollisions(this.petBallInstances);
            for (const pair of cols.collisionPairs) {
                const i1 = this.petBallInstances.findIndex(b => b.id === pair.instance1.id);
                const i2 = this.petBallInstances.findIndex(b => b.id === pair.instance2.id);
                if (i1 !== -1 && i2 !== -1) {
                    const vels = PhysicsUtils.calculateElasticCollision(this.petBallInstances[i1].position, this.petBallInstances[i1].velocity, this.petBallInstances[i2].position, this.petBallInstances[i2].velocity);
                    this.petBallInstances[i1].velocity = vels.velocity1;
                    this.petBallInstances[i2].velocity = vels.velocity2;
                }
            }
        }
        this.counter++;
        if (this.counter % 4 === 0) {
            this.petBallInstances = [...this.petBallInstances];
        }
    }
    // ---------- 交互 ----------
    private handleTap(id: string): void {
        const found = this.petBallInstances.find(b => b.id === id);
        if (found) {
            found.affectionValue = (found.affectionValue + 1) % 5;
            this.petBallInstances = [...this.petBallInstances];
        }
    }
    private handleDragStart(id: string): void {
        this.selectedId = id;
        this.isDragging = true;
    }
    private handleDragUpdate(id: string, ox: number, oy: number): void {
        if (!this.isDragging)
            return;
        const ball = this.petBallInstances.find(b => b.id === id);
        if (ball) {
            ball.position.x += ox;
            ball.position.y += oy;
            ball.velocity = { vx: 0, vy: 0, speed: 0 };
            this.petBallInstances = [...this.petBallInstances];
        }
    }
    private handleDragEnd(id: string): void {
        this.isDragging = false;
        this.selectedId = '';
    }
    // ---------- 外观 ----------
    private color(ball: PetBallInstance): string {
        const colors = ['#FFD700', '#FFA500', '#FF6B6B', '#4ECDC4', '#45B7D1'];
        return colors[ball.affectionValue % colors.length];
    }
    private shortId(id: string): string {
        // 截取最后 4 位显示
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
                    Stack.width(this.petBallSize);
                    Stack.height(this.petBallSize);
                    Stack.position({
                        x: ball.position.x - this.petBallSize / 2,
                        y: ball.position.y - this.petBallSize / 2
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
                    Circle.width(this.petBallSize);
                    Circle.height(this.petBallSize);
                    Circle.fill(this.color(ball));
                    Circle.stroke('#FFA500');
                    Circle.strokeWidth(3);
                    Circle.shadow({ radius: 12, color: '#30000000', offsetX: 2, offsetY: 4 });
                }, Circle);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    // 小标签
                    Text.create(this.shortId(ball.id));
                    // 小标签
                    Text.fontSize(10);
                    // 小标签
                    Text.fontColor('#FFFFFF');
                    // 小标签
                    Text.backgroundColor('#40000000');
                    // 小标签
                    Text.borderRadius(4);
                    // 小标签
                    Text.padding({ left: 4, right: 4, top: 1, bottom: 1 });
                }, Text);
                // 小标签
                Text.pop();
                Stack.pop();
            };
            this.forEachUpdateFunction(elmtId, this.petBallInstances, forEachItemGenFunction, (ball: PetBallInstance) => ball.id, false, false);
        }, ForEach);
        ForEach.pop();
        Stack.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "FloatWindowPage";
    }
}
function requestAnimationFrame(cb: () => void): number {
    return setTimeout(cb, 16);
}
function cancelAnimationFrame(id: number): void {
    clearTimeout(id);
}
registerNamedRoute(() => new FloatWindowPage(undefined, {}), "", { bundleName: "com.example.desktoppetball", moduleName: "entry", pagePath: "pages/FloatWindowPage", pageFullPath: "entry/src/main/ets/pages/FloatWindowPage", integratedHsp: "false", moduleType: "followWithHap" });
