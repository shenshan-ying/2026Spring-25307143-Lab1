import display from '@ohos.display';
import { DeviceInfo } from '../dao/DataModels';
import { common } from '@kit.AbilityKit';

interface PerformanceInfo {
  performanceLevel: 'low' | 'medium' | 'high';
  cpuCores: number;
  availableMemory: number;
  gpuPerformanceLevel: 'low' | 'medium' | 'high';
}

interface ScreenSize {
  width: number;
  height: number;
}

export class DeviceAdapter {
  private context: common.Context | null = null;
  private deviceInfo: DeviceInfo | null = null;

  init(context: common.Context): void {
    this.context = context;
    this.detectDevice();
  }

  private detectDevice(): void {
    if (!this.context) {
      return;
    }

    try {
      const displayInfo = display.getDefaultDisplaySync();
      
      // display API 返回物理像素，ArkUI position 使用 vp 单位，需要转换
      const densityScale = displayInfo.densityDPI / 160;
      const screenWidth = Math.round(displayInfo.width / densityScale);
      const screenHeight = Math.round(displayInfo.height / densityScale);
      const screenDensity = displayInfo.densityDPI;

      const deviceType = this.detectDeviceType(screenWidth, screenHeight);
      const performanceLevel = this.detectPerformanceLevel(screenWidth, screenHeight, screenDensity);

      this.deviceInfo = {
        type: deviceType,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        screenDensity: screenDensity,
        performanceLevel: performanceLevel.performanceLevel,
        cpuCores: performanceLevel.cpuCores,
        availableMemory: performanceLevel.availableMemory,
        gpuPerformanceLevel: performanceLevel.gpuPerformanceLevel
      };
    } catch (error) {
      console.error('Detect device failed:', error);
      this.deviceInfo = this.getDefaultDeviceInfo();
    }
  }

  private detectDeviceType(
    screenWidth: number,
    screenHeight: number
  ): 'phone' | 'tablet' | 'computer' {
    const minDimension = Math.min(screenWidth, screenHeight);
    const maxDimension = Math.max(screenWidth, screenHeight);
    const aspectRatio = maxDimension / minDimension;

    if (minDimension >= 1200) {
      return 'computer';
    } else if (minDimension >= 600 || aspectRatio < 1.5) {
      return 'tablet';
    } else {
      return 'phone';
    }
  }

  private detectPerformanceLevel(
    screenWidth: number,
    screenHeight: number,
    screenDensity: number
  ): PerformanceInfo {
    const pixels = screenWidth * screenHeight * (screenDensity / 160) ** 2;

    let performanceLevel: 'low' | 'medium' | 'high';
    let gpuPerformanceLevel: 'low' | 'medium' | 'high';

    if (pixels > 2073600) {
      performanceLevel = 'high';
      gpuPerformanceLevel = 'high';
    } else if (pixels > 921600) {
      performanceLevel = 'medium';
      gpuPerformanceLevel = 'medium';
    } else {
      performanceLevel = 'low';
      gpuPerformanceLevel = 'low';
    }

    const result: PerformanceInfo = {
      performanceLevel: performanceLevel,
      cpuCores: 4,
      availableMemory: 2048,
      gpuPerformanceLevel: gpuPerformanceLevel
    };
    return result;
  }

  private getDefaultDeviceInfo(): DeviceInfo {
    return {
      type: 'phone',
      screenWidth: 1080,
      screenHeight: 1920,
      screenDensity: 480,
      performanceLevel: 'medium',
      cpuCores: 4,
      availableMemory: 2048,
      gpuPerformanceLevel: 'medium'
    };
  }

  getDeviceInfo(): DeviceInfo | null {
    return this.deviceInfo;
  }

  getDeviceType(): 'phone' | 'tablet' | 'computer' {
    return this.deviceInfo?.type || 'phone';
  }

  getScreenSize(): ScreenSize {
    const result: ScreenSize = {
      width: this.deviceInfo?.screenWidth || 1080,
      height: this.deviceInfo?.screenHeight || 1920
    };
    return result;
  }

  getAdaptedPetBallSize(baseSize: number = 120): number {
    const coefficient = this.getPerformanceCoefficient();
    return Math.round(baseSize * coefficient);
  }

  getPerformanceCoefficient(): number {
    const performanceLevel = this.deviceInfo?.performanceLevel || 'medium';
    
    switch (performanceLevel) {
      case 'high':
        return 1.2;
      case 'medium':
        return 1.0;
      case 'low':
        return 0.8;
      default:
        return 1.0;
    }
  }

  getMaxInstanceCount(): number {
    const performanceLevel = this.deviceInfo?.performanceLevel || 'medium';
    
    switch (performanceLevel) {
      case 'high':
        return 5;
      case 'medium':
        return 3;
      case 'low':
        return 2;
      default:
        return 3;
    }
  }

  getAnimationFrameRate(): number {
    const performanceLevel = this.deviceInfo?.performanceLevel || 'medium';
    
    switch (performanceLevel) {
      case 'high':
        return 60;
      case 'medium':
        return 60;
      case 'low':
        return 30;
      default:
        return 60;
    }
  }

  getCollisionDetectionInterval(): number {
    const frameRate = this.getAnimationFrameRate();
    return 1000 / frameRate;
  }
}