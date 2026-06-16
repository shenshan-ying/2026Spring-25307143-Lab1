import window from '@ohos.window';
import { BusinessError } from '@kit.BasicServicesKit';
import { Position } from '../dao/DataModels';

export interface WindowCreateOptions {
  width: number;
  height: number;
  x: number;
  y: number;
  windowType: window.WindowType;
}

export class WindowAPIWrapper {
  private context: Context | null = null;
  private floatWindow: window.Window | null = null;

  init(context: Context): void {
    this.context = context;
  }

  async createFloatWindow(options: WindowCreateOptions): Promise<window.Window | null> {
    if (!this.context) {
      console.error('Context not initialized');
      return null;
    }

    return new Promise((resolve) => {
      const config: window.Configuration = {
        name: 'floatWindow',
        windowType: options.windowType,
        ctx: this.context!
      };
      try {
        window.createWindow(config, (err: BusinessError, data: window.Window) => {
          if (err.code) {
            console.error('Failed to create float window: ' + JSON.stringify(err));
            resolve(null);
            return;
          }
          this.floatWindow = data;
          data.resize(options.width, options.height);
          data.moveWindowTo(options.x, options.y);
          resolve(data);
        });
      } catch (error) {
        console.error('Create float window exception: ' + error);
        resolve(null);
      }
    });
  }

  async destroyFloatWindow(): Promise<boolean> {
    return new Promise((resolve) => {
      if (!this.floatWindow) {
        resolve(true);
        return;
      }
      try {
        this.floatWindow.destroyWindow((err: BusinessError) => {
          if (err.code) {
            console.error('Failed to destroy window: ' + JSON.stringify(err));
            resolve(false);
            return;
          }
          this.floatWindow = null;
          resolve(true);
        });
      } catch (error) {
        resolve(false);
      }
    });
  }

  async updateWindowPosition(win: window.Window, position: Position): Promise<boolean> {
    return new Promise((resolve) => {
      try {
        win.moveWindowTo(position.x, position.y, (err: BusinessError) => {
          resolve(!err.code);
        });
      } catch (error) {
        resolve(false);
      }
    });
  }

  async setWindowLayer(win: window.Window): Promise<boolean> {
    try {
      await win.setWindowLayoutFullScreen(true);
      return true;
    } catch (error) {
      return false;
    }
  }

  getFloatWindow(): window.Window | null {
    return this.floatWindow;
  }
}
