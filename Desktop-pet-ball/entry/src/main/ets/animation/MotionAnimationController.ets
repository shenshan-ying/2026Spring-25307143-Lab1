import { PerformanceMonitor } from '../utils/PerformanceMonitor';
import { PetBallInstance, Position } from '../dao/DataModels';

export class MotionAnimationController {
  private performanceMonitor: PerformanceMonitor;
  private animationFrameId: number = -1;
  private isAnimating: boolean = false;
  private lastFrameTime: number = 0;
  private targetFrameRate: number = 60;
  private frameInterval: number = 1000 / 60;

  private instances: PetBallInstance[] = [];
  private updateCallback: ((instances: PetBallInstance[]) => void) | null = null;

  constructor() {
    this.performanceMonitor = PerformanceMonitor.getInstance();
  }

  start(): void {
    if (this.isAnimating) {
      return;
    }

    this.isAnimating = true;
    this.lastFrameTime = Date.now();
    this.performanceMonitor.startMonitoring();
    
    this.animationLoop();
  }

  stop(): void {
    this.isAnimating = false;
    
    if (this.animationFrameId !== -1) {
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = -1;
    }
    
    this.performanceMonitor.stopMonitoring();
  }

  private animationLoop(): void {
    if (!this.isAnimating) {
      return;
    }

    const currentTime = Date.now();
    const deltaTime = currentTime - this.lastFrameTime;

    if (deltaTime >= this.frameInterval) {
      this.performanceMonitor.recordFrame();
      this.update(deltaTime);
      this.lastFrameTime = currentTime;
    }

    this.animationFrameId = requestAnimationFrame(() => {
      this.animationLoop();
    });
  }

  private update(deltaTime: number): void {
    if (this.updateCallback) {
      this.updateCallback(this.instances);
    }
  }

  setUpdateCallback(callback: (instances: PetBallInstance[]) => void): void {
    this.updateCallback = callback;
  }

  setInstances(instances: PetBallInstance[]): void {
    this.instances = instances;
  }

  setTargetFrameRate(fps: number): void {
    this.targetFrameRate = fps;
    this.frameInterval = 1000 / fps;
  }

  getTargetFrameRate(): number {
    return this.targetFrameRate;
  }

  getCurrentFps(): number {
    return this.performanceMonitor.getCurrentFps();
  }

  getAverageFps(): number {
    return this.performanceMonitor.getAverageFps();
  }

  isPerformanceGood(): boolean {
    return this.performanceMonitor.isPerformanceGood();
  }

  isRunning(): boolean {
    return this.isAnimating;
  }

  pause(): void {
    this.stop();
  }

  resume(): void {
    this.start();
  }
}

function requestAnimationFrame(callback: () => void): number {
  const id = setTimeout(callback, 16);
  return id;
}

function cancelAnimationFrame(id: number): void {
  clearTimeout(id);
}