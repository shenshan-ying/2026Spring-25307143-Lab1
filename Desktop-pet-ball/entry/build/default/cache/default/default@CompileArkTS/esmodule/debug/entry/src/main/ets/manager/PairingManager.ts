import { DistributedServiceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/adapter/DistributedServiceAdapter";
import type { PairingResult, DeviceInfo } from "@bundle:com.example.desktoppetball/entry/ets/adapter/DistributedServiceAdapter";
export class PairingManager {
    private distributedAdapter: DistributedServiceAdapter;
    private pairedDevices: Map<string, DeviceInfo> = new Map();
    private pairingTimeout: number = 30000; // 30秒
    private isPairing: boolean = false;
    constructor() {
        this.distributedAdapter = new DistributedServiceAdapter();
    }
    async init(context: Context): Promise<void> {
        await this.distributedAdapter.init(context);
        this.registerDeviceStateCallback();
    }
    private registerDeviceStateCallback(): void {
        this.distributedAdapter.registerDeviceStateCallback((deviceInfo, state) => {
            this.handleDeviceStateChange(deviceInfo, state);
        });
    }
    private handleDeviceStateChange(deviceInfo: DeviceInfo, state: string): void {
        if (state === 'ONLINE') {
            console.info(`Device ${deviceInfo.deviceName} is online`);
        }
        else if (state === 'OFFLINE') {
            this.pairedDevices.delete(deviceInfo.deviceId);
            console.info(`Device ${deviceInfo.deviceName} is offline`);
        }
    }
    async discoverDevices(): Promise<DeviceInfo[]> {
        return await this.distributedAdapter.discoverDevices();
    }
    async startPairing(deviceId: string): Promise<PairingResult> {
        if (this.isPairing) {
            return {
                success: false,
                error: 'Already pairing with another device'
            };
        }
        this.isPairing = true;
        const timeoutPromise = new Promise<PairingResult>((resolve) => {
            setTimeout(() => {
                resolve({
                    success: false,
                    error: 'Pairing timeout'
                });
            }, this.pairingTimeout);
        });
        const pairingPromise = this.distributedAdapter.pairDevice(deviceId);
        try {
            const result = await Promise.race([pairingPromise, timeoutPromise]);
            if (result.success) {
                const devices = await this.discoverDevices();
                const device = devices.find(d => d.deviceId === deviceId);
                if (device) {
                    this.pairedDevices.set(deviceId, device);
                }
            }
            this.isPairing = false;
            return result;
        }
        catch (error) {
            this.isPairing = false;
            return {
                success: false,
                error: String(error)
            };
        }
    }
    async stopPairing(deviceId: string): Promise<boolean> {
        const success = await this.distributedAdapter.unpairDevice(deviceId);
        if (success) {
            this.pairedDevices.delete(deviceId);
        }
        return success;
    }
    getPairedDevices(): DeviceInfo[] {
        return Array.from(this.pairedDevices.values());
    }
    isDevicePaired(deviceId: string): boolean {
        return this.pairedDevices.has(deviceId);
    }
    getPairedDevice(deviceId: string): DeviceInfo | null {
        return this.pairedDevices.get(deviceId) || null;
    }
    setPairingTimeout(timeout: number): void {
        this.pairingTimeout = timeout;
    }
    isPairingInProgress(): boolean {
        return this.isPairing;
    }
    async initKvStore(storeId: string): Promise<boolean> {
        return await this.distributedAdapter.initKvStore(storeId);
    }
    async sendData(key: string, data: ArrayBuffer): Promise<boolean> {
        return await this.distributedAdapter.sendData(key, data);
    }
    async receiveData(key: string): Promise<ArrayBuffer | null> {
        return await this.distributedAdapter.receiveData(key);
    }
    async syncData(deviceIds: string[]): Promise<boolean> {
        return await this.distributedAdapter.syncData(deviceIds);
    }
}
