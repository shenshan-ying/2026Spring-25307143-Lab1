import { StorageAPIWrapper } from '../api/StorageAPIWrapper';
import { ConfigDataDAO } from '../dao/ConfigDataDAO';
import { AffectionDataDAO } from '../dao/AffectionDataDAO';
import { StateDataDAO } from '../dao/StateDataDAO';
import { AppConfig, AffectionData, PetBallInstance } from '../dao/DataModels';

export class StorageServiceAdapter {
  private storageAPI: StorageAPIWrapper;
  private configDAO: ConfigDataDAO;
  private affectionDAO: AffectionDataDAO;
  private stateDAO: StateDataDAO;

  constructor() {
    this.storageAPI = new StorageAPIWrapper();
    this.configDAO = new ConfigDataDAO();
    this.affectionDAO = new AffectionDataDAO();
    this.stateDAO = new StateDataDAO();
  }

  async init(context: Context): Promise<void> {
    this.storageAPI.init(context);
    await this.configDAO.init(context);
    await this.affectionDAO.init(context);
    await this.stateDAO.init(context);
  }

  async saveConfig(config: AppConfig): Promise<boolean> {
    return await this.configDAO.saveConfig(config);
  }

  async loadConfig(): Promise<AppConfig | null> {
    return await this.configDAO.loadConfig();
  }

  async clearConfig(): Promise<boolean> {
    return await this.configDAO.clearConfig();
  }

  async saveAffection(data: AffectionData): Promise<boolean> {
    return await this.affectionDAO.saveAffection(data);
  }

  async loadAffection(instanceId: string): Promise<AffectionData | null> {
    return await this.affectionDAO.loadAffection(instanceId);
  }

  async clearAffection(instanceId: string): Promise<boolean> {
    return await this.affectionDAO.clearAffection(instanceId);
  }

  async saveInstanceState(instance: PetBallInstance): Promise<boolean> {
    return await this.stateDAO.saveInstanceState(instance);
  }

  async loadInstanceState(instanceId: string): Promise<PetBallInstance | null> {
    return await this.stateDAO.loadInstanceState(instanceId);
  }

  async saveAllInstances(instances: PetBallInstance[]): Promise<boolean> {
    return await this.stateDAO.saveAllInstances(instances);
  }

  async loadAllInstances(): Promise<PetBallInstance[]> {
    return await this.stateDAO.loadAllInstances();
  }

  async clearInstanceState(instanceId: string): Promise<boolean> {
    return await this.stateDAO.clearInstanceState(instanceId);
  }

  async clearAllInstances(): Promise<boolean> {
    return await this.stateDAO.clearAllInstances();
  }

  async migrateAllData(oldVersion: string, newVersion: string): Promise<boolean> {
    try {
      await this.configDAO.migrateConfig(oldVersion, newVersion);
      await this.affectionDAO.migrateAffectionData(oldVersion, newVersion);
      await this.stateDAO.migrateStateData(oldVersion, newVersion);
      return true;
    } catch (error) {
      console.error('Migrate all data failed:', error);
      return false;
    }
  }
}