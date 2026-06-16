import type distributedData from "@ohos:data.distributedData";
export interface DeviceInfo {
    deviceId: string;
    deviceName: string;
    deviceType: string;
    networkId: string;
}
/**
 * Distributed capability wrapper.
 * Distributed features (device discovery, pairing, data sync) require
 * physical devices and appropriate permissions. They gracefully degrade
 * to no-ops when unavailable.
 */
export class DistributedAPIWrapper {
    private initialized: boolean = false;
    async init(context: Context): Promise<void> {
        // Distributed features require device pairing, skip in standalone mode
        this.initialized = true;
        console.info('DistributedAPIWrapper initialized (degraded mode)');
    }
    async discoverDevices(): Promise<DeviceInfo[]> {
        return [];
    }
    async authenticateDevice(deviceId: string): Promise<boolean> {
        return false;
    }
    async unauthenticateDevice(deviceId: string): Promise<boolean> {
        return false;
    }
    async createKvStore(storeId: string): Promise<distributedData.SingleKVStore | null> {
        return null;
    }
    async putData(kvStore: distributedData.SingleKVStore, key: string, value: Uint8Array): Promise<boolean> {
        return false;
    }
    async getData(kvStore: distributedData.SingleKVStore, key: string): Promise<ArrayBuffer | null> {
        return null;
    }
    async syncData(kvStore: distributedData.SingleKVStore, deviceIds: string[]): Promise<boolean> {
        return false;
    }
    registerDeviceStateCallback(callback: (deviceInfo: DeviceInfo, state: string) => void): boolean {
        return false;
    }
    unregisterDeviceStateCallback(): boolean {
        return false;
    }
}
