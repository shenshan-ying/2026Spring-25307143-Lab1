import { PetBallInstance, TransferDataPacket, Position, Velocity } from '../dao/DataModels';
import { PairingManager } from './PairingManager';
import { InstanceManager } from './InstanceManager';
import { ResourceManager } from './ResourceManager';
import { CultivationManager } from './CultivationManager';
import { util } from '@kit.ArkTS';

export enum TransferState {
  IDLE = 'idle',
  PREPARING = 'preparing',
  TRANSFERRING = 'transferring',
  RECEIVING = 'receiving',
  COMPLETED = 'completed',
  FAILED = 'failed'
}

export class TransferController {
  private pairingManager: PairingManager;
  private instanceManager: InstanceManager;
  private resourceManager: ResourceManager;
  private cultivationManager: CultivationManager;
  private transferState: TransferState = TransferState.IDLE;
  private currentTransfer: TransferDataPacket | null = null;

  constructor(
    pairingManager: PairingManager,
    instanceManager: InstanceManager,
    resourceManager: ResourceManager,
    cultivationManager: CultivationManager
  ) {
    this.pairingManager = pairingManager;
    this.instanceManager = instanceManager;
    this.resourceManager = resourceManager;
    this.cultivationManager = cultivationManager;
  }

  async prepareTransfer(
    instance: PetBallInstance,
    targetDeviceId: string
  ): Promise<boolean> {
    if (this.transferState !== TransferState.IDLE) {
      console.error('Transfer already in progress');
      return false;
    }

    if (!this.pairingManager.isDevicePaired(targetDeviceId)) {
      console.error('Device not paired');
      return false;
    }

    this.transferState = TransferState.PREPARING;

    const resource = this.resourceManager.getResource(instance.resourceId);
    if (!resource) {
      this.transferState = TransferState.FAILED;
      return false;
    }

    const affectionData = await this.cultivationManager.loadAffection(instance.id);

    const transferPacket: TransferDataPacket = {
      instanceId: instance.id,
      resourceData: resource,
      affectionData: affectionData,
      position: instance.position,
      velocity: instance.velocity,
      state: instance.state,
      transferTime: Date.now(),
      sourceDeviceId: 'local',
      targetDeviceId: targetDeviceId
    };

    this.currentTransfer = transferPacket;
    return true;
  }

  async executeTransfer(): Promise<boolean> {
    if (!this.currentTransfer) {
      return false;
    }

    this.transferState = TransferState.TRANSFERRING;

    try {
      const dataStr = JSON.stringify(this.currentTransfer);
      const textEncoder = new util.TextEncoder();
      const encoded = textEncoder.encodeInto(dataStr);
      const data: ArrayBuffer = encoded.buffer.slice(0);

      const success = await this.pairingManager.sendData(
        `transfer_${this.currentTransfer.instanceId}`,
        data
      );

      if (success) {
        await this.instanceManager.destroyInstance(this.currentTransfer.instanceId);
        this.transferState = TransferState.COMPLETED;
        this.currentTransfer = null;
        return true;
      } else {
        this.transferState = TransferState.FAILED;
        return false;
      }
    } catch (error) {
      console.error('Execute transfer failed:', error);
      this.transferState = TransferState.FAILED;
      return false;
    }
  }

  async receiveTransfer(data: ArrayBuffer): Promise<PetBallInstance | null> {
    this.transferState = TransferState.RECEIVING;

    try {
      const textDecoder = new util.TextDecoder();
      const dataStr = textDecoder.decodeWithStream(new Uint8Array(data), { stream: false });
      const transferPacket: TransferDataPacket = JSON.parse(dataStr);

      const newInstance = this.instanceManager.createInstance(
        transferPacket.resourceData.id,
        transferPacket.position,
        transferPacket.velocity
      );

      if (!newInstance) {
        this.transferState = TransferState.FAILED;
        return null;
      }

      newInstance.state = transferPacket.state as 'normal' | 'following';
      await this.instanceManager.updateInstance(newInstance);

      await this.cultivationManager.setAffection(
        newInstance.id,
        transferPacket.affectionData.value
      );

      this.transferState = TransferState.COMPLETED;
      return newInstance;
    } catch (error) {
      console.error('Receive transfer failed:', error);
      this.transferState = TransferState.FAILED;
      return null;
    }
  }

  getTransferState(): TransferState {
    return this.transferState;
  }

  isTransferInProgress(): boolean {
    return this.transferState !== TransferState.IDLE;
  }

  resetTransferState(): void {
    this.transferState = TransferState.IDLE;
    this.currentTransfer = null;
  }

  getCurrentTransfer(): TransferDataPacket | null {
    return this.currentTransfer;
  }
}
