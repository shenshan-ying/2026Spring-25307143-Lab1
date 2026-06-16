import window from "@ohos:window";
import { WindowAPIWrapper } from "@bundle:com.example.desktoppetball/entry/ets/api/WindowAPIWrapper";
import type { WindowCreateOptions } from "@bundle:com.example.desktoppetball/entry/ets/api/WindowAPIWrapper";
import type { Position } from '../dao/DataModels';
export class WindowServiceAdapter {
    private windowAPI: WindowAPIWrapper;
    private floatWindow: window.Window | null = null;
    constructor() {
        this.windowAPI = new WindowAPIWrapper();
    }
    init(context: Context): void {
        this.windowAPI.init(context);
    }
    async createFloatWindow(width: number, height: number, position: Position): Promise<window.Window | null> {
        const options: WindowCreateOptions = {
            width: width,
            height: height,
            x: position.x,
            y: position.y,
            windowType: window.WindowType.TYPE_FLOAT
        };
        this.floatWindow = await this.windowAPI.createFloatWindow(options);
        return this.floatWindow;
    }
    async destroyFloatWindow(): Promise<boolean> {
        return await this.windowAPI.destroyFloatWindow();
    }
    async updateWindowPosition(position: Position): Promise<boolean> {
        if (!this.floatWindow) {
            return false;
        }
        return await this.windowAPI.updateWindowPosition(this.floatWindow, position);
    }
    async setFloatWindowFullScreen(): Promise<boolean> {
        if (!this.floatWindow) {
            return false;
        }
        return await this.windowAPI.setWindowLayer(this.floatWindow);
    }
    getFloatWindow(): window.Window | null {
        return this.floatWindow;
    }
}
