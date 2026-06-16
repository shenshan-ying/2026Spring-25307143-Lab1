import fs from '@ohos.file.fs';
import util from '@ohos.util';
import { PetBallResource } from './DataModels';
import { common } from '@kit.AbilityKit';

const CUSTOM_RESOURCE_PATH = 'pet_balls/custom/';

export class ResourceDAO {
  private context: common.Context | null = null;

  init(context: common.Context): void {
    this.context = context;
    this.ensureCustomDirectory();
  }

  private ensureCustomDirectory(): void {
    if (!this.context) {
      return;
    }

    try {
      const filesDir = this.context.filesDir;
      const customPath = `${filesDir}/${CUSTOM_RESOURCE_PATH}`;
      
      if (!fs.accessSync(customPath)) {
        fs.mkdirSync(customPath, true);
      }
    } catch (error) {
      console.error('Ensure custom directory failed:', error);
    }
  }

  async saveResource(resource: PetBallResource, imageData: ArrayBuffer): Promise<boolean> {
    if (!this.context) {
      console.error('Context not initialized');
      return false;
    }

    try {
      const filesDir = this.context.filesDir;
      const filePath = `${filesDir}/${resource.imagePath}`;
      
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, imageData);
      fs.closeSync(file);
      
      return true;
    } catch (error) {
      console.error('Save resource failed:', error);
      return false;
    }
  }

  async loadResource(resourceId: string): Promise<PetBallResource | null> {
    if (!this.context) {
      console.error('Context not initialized');
      return null;
    }

    try {
      const filesDir = this.context.filesDir;
      const metadataPath = `${filesDir}/pet_balls/metadata_${resourceId}.json`;
      
      if (!fs.accessSync(metadataPath)) {
        return null;
      }
      
      const file = fs.openSync(metadataPath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(metadataPath);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      
      const decoder = new util.TextDecoder('utf-8');
      const metadataStr = decoder.decodeToString(new Uint8Array(buffer));
      
      return JSON.parse(metadataStr) as PetBallResource;
    } catch (error) {
      console.error('Load resource failed:', error);
      return null;
    }
  }

  async deleteResource(resourceId: string): Promise<boolean> {
    if (!this.context) {
      console.error('Context not initialized');
      return false;
    }

    try {
      const filesDir = this.context.filesDir;
      const resource = await this.loadResource(resourceId);
      
      if (resource) {
        const imagePath = `${filesDir}/${resource.imagePath}`;
        if (fs.accessSync(imagePath)) {
          fs.unlinkSync(imagePath);
        }
        
        const metadataPath = `${filesDir}/pet_balls/metadata_${resourceId}.json`;
        if (fs.accessSync(metadataPath)) {
          fs.unlinkSync(metadataPath);
        }
      }
      
      return true;
    } catch (error) {
      console.error('Delete resource failed:', error);
      return false;
    }
  }

  async listResources(): Promise<PetBallResource[]> {
    if (!this.context) {
      console.error('Context not initialized');
      return [];
    }

    try {
      const filesDir = this.context.filesDir;
      const metadataDir = `${filesDir}/pet_balls`;
      
      if (!fs.accessSync(metadataDir)) {
        return [];
      }
      
      const resources: PetBallResource[] = [];
      const files = fs.listFileSync(metadataDir);
      
      for (const file of files) {
        if (file.startsWith('metadata_') && file.endsWith('.json')) {
          const resourceId = file.replace('metadata_', '').replace('.json', '');
          const resource = await this.loadResource(resourceId);
          if (resource && resource.status === 'active') {
            resources.push(resource);
          }
        }
      }
      
      return resources;
    } catch (error) {
      console.error('List resources failed:', error);
      return [];
    }
  }

  async loadResourceImage(resourceId: string): Promise<ArrayBuffer | null> {
    if (!this.context) {
      console.error('Context not initialized');
      return null;
    }

    try {
      const resource = await this.loadResource(resourceId);
      if (!resource) {
        return null;
      }
      
      const filesDir = this.context.filesDir;
      const imagePath = `${filesDir}/${resource.imagePath}`;
      
      if (!fs.accessSync(imagePath)) {
        return null;
      }
      
      const file = fs.openSync(imagePath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(imagePath);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      
      return buffer;
    } catch (error) {
      console.error('Load resource image failed:', error);
      return null;
    }
  }
}