export interface Position {
  x: number;
  y: number;
}

export interface Velocity {
  vx: number;
  vy: number;
  speed: number;
}

export interface Size {
  width: number;
  height: number;
}

export interface Direction {
  angle: number;
  dx: number;
  dy: number;
}

export interface AppConfig {
  motionMode: 'free_rolling' | 'static' | 'slingshot' | 'following';
  motionSpeed: number;
  judgmentLinePosition: 'bottom' | 'top' | 'left' | 'right';
  petBallSizeCoefficient: number;
  version: string;
}

export interface PetBallInstance {
  id: string;
  resourceId: string;
  position: Position;
  velocity: Velocity;
  state: 'normal' | 'following';
  affectionValue: number;
  createdAt: number;
  lastInteractionTime: number;
}

export interface AffectionData {
  instanceId: string;
  value: number;
  level: number;
  lastAccumulateTime: number;
  followingThreshold: number;
}

export interface PetBallResource {
  id: string;
  type: 'preset' | 'custom';
  name: string;
  animalType?: 'cat' | 'dog' | 'bird';
  imagePath: string;
  createdAt: number;
  status: 'active' | 'deleted';
}

export interface AnimationResource {
  id: string;
  resourceId: string;
  type: 'head_rub' | 'tongue_out' | 'wing_extend' | 'collision';
  frames: string[];
  duration: number;
  frameRate: number;
}

export interface CollisionPair {
  instance1Id: string;
  instance2Id: string;
  collisionTime: number;
  collisionPoint: Position;
}

export interface DeviceInfo {
  type: 'phone' | 'tablet' | 'computer';
  screenWidth: number;
  screenHeight: number;
  screenDensity: number;
  performanceLevel: 'low' | 'medium' | 'high';
  cpuCores: number;
  availableMemory: number;
  gpuPerformanceLevel: 'low' | 'medium' | 'high';
}

export interface TransferDataPacket {
  instanceId: string;
  resourceData: PetBallResource;
  affectionData: AffectionData;
  position: Position;
  velocity: Velocity;
  state: string;
  transferTime: number;
  sourceDeviceId: string;
  targetDeviceId: string;
}

export interface DistributedDeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  isOnline: boolean;
  lastSeenTime: number;
}

export class InteractionEventData {
  private data: Map<string, string | number | boolean> = new Map();
  
  set(key: string, value: string | number | boolean): void {
    this.data.set(key, value);
  }
  
  get(key: string): string | number | boolean | undefined {
    return this.data.get(key);
  }
  
  has(key: string): boolean {
    return this.data.has(key);
  }
}

export interface InteractionEvent {
  type: 'click' | 'drag' | 'slingshot' | 'edge_slide';
  instanceId: string;
  timestamp: number;
  data: InteractionEventData;
}

export interface DialogOption {
  id: string;
  text: string;
  affectionBonus: number;
}

export interface Gift {
  id: string;
  name: string;
  type: string;
  affectionValue: number;
  icon: string;
}

export interface Backpack {
  gifts: Map<string, number>;
  lastUpdateTime: number;
}

export class BackpackImpl implements Backpack {
  gifts: Map<string, number> = new Map<string, number>();
  lastUpdateTime: number = 0;
  
  constructor() {
    this.gifts = new Map<string, number>();
    this.lastUpdateTime = Date.now();
  }
}