import type { PetBallInstance } from '../dao/DataModels';
import type { InstanceManager } from '../manager/InstanceManager';
/**
 * 桌面宠物协调器 — 跨窗口（主窗口 & 浮窗）共享的单例
 * Index 管理面板通过它控制哪些球显示在桌面；FloatWindowPage 通过它获取可见球列表并订阅变化
 */
export class DesktopPetCoordinator {
    private static instance: DesktopPetCoordinator;
    private desktopVisibleIds: Set<string> = new Set();
    private instanceManager: InstanceManager | null = null;
    private listeners: Array<() => void> = [];
    private constructor() {
    }
    static getInstance(): DesktopPetCoordinator {
        if (!DesktopPetCoordinator.instance) {
            DesktopPetCoordinator.instance = new DesktopPetCoordinator();
        }
        return DesktopPetCoordinator.instance;
    }
    // ---------- InstanceManager ----------
    setInstanceManager(manager: InstanceManager): void {
        this.instanceManager = manager;
    }
    getInstanceManager(): InstanceManager | null {
        return this.instanceManager;
    }
    // ---------- 桌面可见性 ----------
    isDesktopVisible(id: string): boolean {
        return this.desktopVisibleIds.has(id);
    }
    setDesktopVisible(id: string, visible: boolean): void {
        if (visible) {
            this.desktopVisibleIds.add(id);
        }
        else {
            this.desktopVisibleIds.delete(id);
        }
        this.notifyListeners();
    }
    getDesktopVisibleIds(): string[] {
        return Array.from(this.desktopVisibleIds);
    }
    getVisibleCount(): number {
        return this.desktopVisibleIds.size;
    }
    // 删除时清理
    removeFromDesktop(id: string): void {
        this.desktopVisibleIds.delete(id);
        this.notifyListeners();
    }
    // 获取所有桌面可见的实例
    getDesktopVisibleInstances(): PetBallInstance[] {
        if (!this.instanceManager)
            return [];
        const all = this.instanceManager.getAllInstances();
        return all.filter(inst => this.desktopVisibleIds.has(inst.id));
    }
    // ---------- 变更监听（供 FloatWindowPage 使用）----------
    onChange(listener: () => void): void {
        this.listeners.push(listener);
    }
    offChange(listener: () => void): void {
        const idx = this.listeners.indexOf(listener);
        if (idx !== -1) {
            this.listeners.splice(idx, 1);
        }
    }
    private notifyListeners(): void {
        for (const fn of this.listeners) {
            fn();
        }
    }
    /** 外部主动触发通知（如 InstanceManager 已就绪） */
    notifyReady(): void {
        this.notifyListeners();
    }
}
