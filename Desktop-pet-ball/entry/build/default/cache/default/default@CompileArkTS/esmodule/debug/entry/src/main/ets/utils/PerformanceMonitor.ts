export interface PerformanceData {
    fps: number;
    memoryUsage: number;
    cpuUsage: number;
    timestamp: number;
}
export class PerformanceMonitor {
    private static instance: PerformanceMonitor;
    private frameCount: number = 0;
    private lastFpsTime: number = 0;
    private currentFps: number = 60;
    private performanceHistory: PerformanceData[] = [];
    private maxHistorySize: number = 100;
    private isMonitoring: boolean = false;
    private constructor() { }
    static getInstance(): PerformanceMonitor {
        if (!PerformanceMonitor.instance) {
            PerformanceMonitor.instance = new PerformanceMonitor();
        }
        return PerformanceMonitor.instance;
    }
    startMonitoring(): void {
        this.isMonitoring = true;
        this.lastFpsTime = Date.now();
        this.frameCount = 0;
        console.info('Performance monitoring started');
    }
    stopMonitoring(): void {
        this.isMonitoring = false;
        console.info('Performance monitoring stopped');
    }
    recordFrame(): void {
        if (!this.isMonitoring) {
            return;
        }
        this.frameCount++;
        const currentTime = Date.now();
        const elapsed = currentTime - this.lastFpsTime;
        if (elapsed >= 1000) {
            this.currentFps = Math.round((this.frameCount * 1000) / elapsed);
            this.frameCount = 0;
            this.lastFpsTime = currentTime;
            this.recordPerformanceData();
        }
    }
    private recordPerformanceData(): void {
        const memoryUsage = this.getMemoryUsage();
        const cpuUsage = this.getCpuUsage();
        const data: PerformanceData = {
            fps: this.currentFps,
            memoryUsage: memoryUsage,
            cpuUsage: cpuUsage,
            timestamp: Date.now()
        };
        this.performanceHistory.push(data);
        if (this.performanceHistory.length > this.maxHistorySize) {
            this.performanceHistory.shift();
        }
    }
    private getMemoryUsage(): number {
        return 0;
    }
    private getCpuUsage(): number {
        return 0;
    }
    getCurrentFps(): number {
        return this.currentFps;
    }
    getAverageFps(): number {
        if (this.performanceHistory.length === 0) {
            return 60;
        }
        const totalFps = this.performanceHistory.reduce((sum, data) => sum + data.fps, 0);
        return Math.round(totalFps / this.performanceHistory.length);
    }
    getPerformanceHistory(): PerformanceData[] {
        return [...this.performanceHistory];
    }
    getLatestPerformanceData(): PerformanceData | null {
        if (this.performanceHistory.length === 0) {
            return null;
        }
        return this.performanceHistory[this.performanceHistory.length - 1];
    }
    isPerformanceGood(): boolean {
        return this.currentFps >= 55;
    }
    getPerformanceReport(): string {
        const avgFps = this.getAverageFps();
        const latestData = this.getLatestPerformanceData();
        return `
Performance Report:
  Current FPS: ${this.currentFps}
  Average FPS: ${avgFps}
  Memory Usage: ${latestData?.memoryUsage || 0} MB
  CPU Usage: ${latestData?.cpuUsage || 0}%
  Performance Status: ${this.isPerformanceGood() ? 'Good' : 'Poor'}
    `.trim();
    }
    clearHistory(): void {
        this.performanceHistory = [];
    }
}
