import { PetBallInstance } from '../dao/DataModels';
import { MotionEngine } from '../engine/MotionEngine';
import { CollisionEngine } from '../engine/CollisionEngine';
import { DeviceAdapter } from '../service/DeviceAdapter';
import { PhysicsUtils } from '../utils/PhysicsUtils';
import { DesktopPetCoordinator } from '../coordinator/DesktopPetCoordinator';
import { common } from '@kit.AbilityKit';

/**
 * 桌面悬浮窗页面 — 只展示 Coordinator 中标记为"桌面可见"的宠物球。
 * 球的管理（创建/删除/切换可见）由主窗口 Index 面板控制。
 */
@Entry
@Component
struct FloatWindowPage {
  @State petBallInstances: PetBallInstance[] = [];
  @State screenWidth: number = 360;
  @State screenHeight: number = 800;
  @State petBallSize: number = 120;
  @State isDragging: boolean = false;
  @State selectedId: string = '';

  private motionEngine: MotionEngine | null = null;
  private collisionEngine: CollisionEngine | null = null;
  private deviceAdapter: DeviceAdapter = new DeviceAdapter();
  private coordinator: DesktopPetCoordinator = DesktopPetCoordinator.getInstance();
  private animFrameId: number = -1;
  private lastTime: number = 0;
  private frameInterval: number = 16.67;
  private counter: number = 0;

  // 用闭包保存监听器引用以支持取消注册
  private changeListener: () => void = () => {
    this.onCoordinatorChanged();
  };

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
    } catch (_e) {
      this.screenWidth = 360;
      this.screenHeight = 800;
      this.petBallSize = 120;
    }

    this.motionEngine = new MotionEngine(
      this.screenWidth,
      this.screenHeight,
      this.petBallSize / 2
    );
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
      } else {
        // 实例已被删除，同步清理 coordinator
        this.coordinator.removeFromDesktop(id);
      }
    }

    this.petBallInstances = visible;

    if (visible.length > 0 && this.animFrameId === -1) {
      this.lastTime = Date.now();
      this.animLoop();
    } else if (visible.length === 0 && this.animFrameId !== -1) {
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
    if (!this.motionEngine) return;

    // 同步清理已被移除的球
    const validIds = new Set(this.coordinator.getDesktopVisibleIds());
    this.petBallInstances = this.petBallInstances.filter(b => validIds.has(b.id));
    if (this.petBallInstances.length === 0) return;

    for (const ball of this.petBallInstances) {
      if (this.isDragging && ball.id === this.selectedId) continue;
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
          const vels = PhysicsUtils.calculateElasticCollision(
            this.petBallInstances[i1].position, this.petBallInstances[i1].velocity,
            this.petBallInstances[i2].position, this.petBallInstances[i2].velocity
          );
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
    if (!this.isDragging) return;
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
    if (id.length <= 8) return id;
    return '...' + id.slice(-4);
  }

  build() {
    Stack() {
      ForEach(this.petBallInstances, (ball: PetBallInstance) => {
        Stack() {
          Circle()
            .width(this.petBallSize)
            .height(this.petBallSize)
            .fill(this.color(ball))
            .stroke('#FFA500')
            .strokeWidth(3)
            .shadow({ radius: 12, color: '#30000000', offsetX: 2, offsetY: 4 })

          // 小标签
          Text(this.shortId(ball.id))
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor('#40000000')
            .borderRadius(4)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
        }
        .width(this.petBallSize)
        .height(this.petBallSize)
        .position({
          x: ball.position.x - this.petBallSize / 2,
          y: ball.position.y - this.petBallSize / 2
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

function requestAnimationFrame(cb: () => void): number {
  return setTimeout(cb, 16);
}

function cancelAnimationFrame(id: number): void {
  clearTimeout(id);
}
