interface Position {
  x: number;
  y: number;
}

interface Velocity {
  vx: number;
  vy: number;
  speed: number;
}

interface PetBallStateData {
  position: Position;
  velocity: Velocity;
  state: 'normal' | 'following';
  affectionValue: number;
}

interface DialogData {
  title: string;
  message: string;
}

export class AppStateManager {
  private static instance: AppStateManager;
  
  private _isForeground: boolean = true;
  private _isInitialized: boolean = false;
  private _lastActiveTime: number = Date.now();

  private constructor() {}

  static getInstance(): AppStateManager {
    if (!AppStateManager.instance) {
      AppStateManager.instance = new AppStateManager();
    }
    return AppStateManager.instance;
  }

  setForeground(isForeground: boolean): void {
    this._isForeground = isForeground;
    if (isForeground) {
      this._lastActiveTime = Date.now();
    }
  }

  isForeground(): boolean {
    return this._isForeground;
  }

  setInitialized(isInitialized: boolean): void {
    this._isInitialized = isInitialized;
  }

  isInitialized(): boolean {
    return this._isInitialized;
  }

  getLastActiveTime(): number {
    return this._lastActiveTime;
  }

  updateActiveTime(): void {
    this._lastActiveTime = Date.now();
  }
}

export class PetBallStateManager {
  private static instance: PetBallStateManager;
  
  private _petBallStates: Map<string, PetBallStateData> = new Map();

  private constructor() {}

  static getInstance(): PetBallStateManager {
    if (!PetBallStateManager.instance) {
      PetBallStateManager.instance = new PetBallStateManager();
    }
    return PetBallStateManager.instance;
  }

  setPetBallState(instanceId: string, state: PetBallStateData): void {
    this._petBallStates.set(instanceId, state);
  }

  getPetBallState(instanceId: string): PetBallStateData | null {
    return this._petBallStates.get(instanceId) || null;
  }

  getAllPetBallStates(): Map<string, PetBallStateData> {
    return new Map(this._petBallStates);
  }

  clearPetBallState(instanceId: string): void {
    this._petBallStates.delete(instanceId);
  }

  clearAllPetBallStates(): void {
    this._petBallStates.clear();
  }
}

export class UIStateManager {
  private static instance: UIStateManager;
  
  private _currentPage: string = 'main';
  private _isDialogVisible: boolean = false;
  private _dialogData: DialogData | null = null;

  private constructor() {}

  static getInstance(): UIStateManager {
    if (!UIStateManager.instance) {
      UIStateManager.instance = new UIStateManager();
    }
    return UIStateManager.instance;
  }

  setCurrentPage(page: string): void {
    this._currentPage = page;
  }

  getCurrentPage(): string {
    return this._currentPage;
  }

  showDialog(data: DialogData): void {
    this._isDialogVisible = true;
    this._dialogData = data;
  }

  hideDialog(): void {
    this._isDialogVisible = false;
    this._dialogData = null;
  }

  isDialogVisible(): boolean {
    return this._isDialogVisible;
  }

  getDialogData(): DialogData | null {
    return this._dialogData;
  }
}
