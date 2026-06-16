import { DistributedAPIWrapper } from "@bundle:com.example.desktoppetball/entry/ets/api/DistributedAPIWrapper";
import type { DeviceInfo } from "@bundle:com.example.desktoppetball/entry/ets/api/DistributedAPIWrapper";
import type distributedData from "@ohos:data.distributedData";
export type { DeviceInfo };
export interface PairingResult {
    success: boolean;
    deviceId?: string;
    error?: string;
}
export class DistributedServiceAdapter {
    private distributedAPI: DistributedAPIWrapper;
    private kvStore: distributedData.SingleKVStore | null = null;
    constructor() {
        this.distributedAPI = new DistributedAPIWrapper();
    }
    async init(context: Context): Promise<void> {
        await this.distributedAPI.init(context);
    }
    async discoverDevices(): Promise<DeviceInfo[]> {
        return await this.distributedAPI.discoverDevices();
    }
    async pairDevice(deviceId: string): Promise<PairingResult> {
        try {
            const success: boolean = await this.distributedAPI.authenticateDevice(deviceId);
            if (success) {
                const result: PairingResult = {
                    success: true,
                    deviceId: deviceId
                };
                return result;
            }
            else {
                const result: PairingResult = {
                    success: false,
                    error: 'Authentication failed'
                };
                return result;
            }
        }
        catch (error) {
            const result: PairingResult = {
                success: false,
                error: String(error)
            };
            return result;
        }
    }
    async unpairDevice(deviceId: string): Promise<boolean> {
        return await this.distributedAPI.unauthenticateDevice(deviceId);
    }
    async initKvStore(storeId: string): Promise<boolean> {
        this.kvStore = await this.distributedAPI.createKvStore(storeId);
        // Distributed KV store requires device pairing, may not be available
        return this.kvStore !== null;
    }
    async sendData(key: string, data: ArrayBuffer): Promise<boolean> {
        if (!this.kvStore) {
            console.error('KvStore not initialized');
            return false;
        }
        return await this.distributedAPI.putData(this.kvStore, key, new Uint8Array(data));
    }
    async receiveData(key: string): Promise<ArrayBuffer | null> {
        if (!this.kvStore) {
            console.error('KvStore not initialized');
            return null;
        }
        return await this.distributedAPI.getData(this.kvStore, key);
    }
    async syncData(deviceIds: string[]): Promise<boolean> {
        if (!this.kvStore) {
            console.error('KvStore not initialized');
            return false;
        }
        return await this.distributedAPI.syncData(this.kvStore, deviceIds);
    }
    registerDeviceStateCallback(callback: (deviceInfo: DeviceInfo, state: string) => void): boolean {
        return this.distributedAPI.registerDeviceStateCallback(callback);
    }
    unregisterDeviceStateCallback(): boolean {
        return this.distributedAPI.unregisterDeviceStateCallback();
    }
}
