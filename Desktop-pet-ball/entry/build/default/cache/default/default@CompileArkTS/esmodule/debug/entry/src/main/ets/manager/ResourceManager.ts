import type { PetBallResource } from '../dao/DataModels';
import { ResourceDAO } from "@bundle:com.example.desktoppetball/entry/ets/dao/ResourceDAO";
import { ImageServiceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/adapter/ImageServiceAdapter";
import type common from "@ohos:app.ability.common";
export class ResourceManager {
    private resourceDAO: ResourceDAO;
    private imageServiceAdapter: ImageServiceAdapter;
    private resources: Map<string, PetBallResource> = new Map();
    private presetResources: PetBallResource[] = [];
    constructor() {
        this.resourceDAO = new ResourceDAO();
        this.imageServiceAdapter = new ImageServiceAdapter();
        this.initPresetResources();
    }
    async init(context: common.Context): Promise<void> {
        this.resourceDAO.init(context);
        this.imageServiceAdapter.init(context);
        await this.loadResources();
    }
    private initPresetResources(): void {
        this.presetResources = [
            {
                id: 'preset_cat',
                type: 'preset',
                name: '猫咪',
                animalType: 'cat',
                imagePath: 'resources/rawfile/pet_cat.png',
                createdAt: Date.now(),
                status: 'active'
            },
            {
                id: 'preset_dog',
                type: 'preset',
                name: '狗狗',
                animalType: 'dog',
                imagePath: 'resources/rawfile/pet_dog.png',
                createdAt: Date.now(),
                status: 'active'
            },
            {
                id: 'preset_bird',
                type: 'preset',
                name: '小鸟',
                animalType: 'bird',
                imagePath: 'resources/rawfile/pet_bird.png',
                createdAt: Date.now(),
                status: 'active'
            }
        ];
        this.presetResources.forEach(resource => {
            this.resources.set(resource.id, resource);
        });
    }
    private async loadResources(): Promise<void> {
        const customResources = await this.resourceDAO.listResources();
        customResources.forEach(resource => {
            this.resources.set(resource.id, resource);
        });
    }
    async createCustomResourceFromCamera(): Promise<PetBallResource | null> {
        try {
            const result = await this.imageServiceAdapter.takePhotoFromCamera();
            if (!result) {
                return null;
            }
            return await this.saveCustomResource(result.imageData, '自定义宠物球');
        }
        catch (error) {
            console.error('Create custom resource from camera failed:', error);
            return null;
        }
    }
    async createCustomResourceFromGallery(): Promise<PetBallResource | null> {
        try {
            const result = await this.imageServiceAdapter.pickImageFromGallery();
            if (!result) {
                return null;
            }
            return await this.saveCustomResource(result.imageData, '自定义宠物球');
        }
        catch (error) {
            console.error('Create custom resource from gallery failed:', error);
            return null;
        }
    }
    private async saveCustomResource(imageData: ArrayBuffer, name: string): Promise<PetBallResource | null> {
        const id = `custom_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const imagePath = `pet_balls/custom/${id}.png`;
        const resource: PetBallResource = {
            id: id,
            type: 'custom',
            name: name,
            imagePath: imagePath,
            createdAt: Date.now(),
            status: 'active'
        };
        const success = await this.resourceDAO.saveResource(resource, imageData);
        if (success) {
            this.resources.set(id, resource);
            return resource;
        }
        return null;
    }
    getResource(resourceId: string): PetBallResource | null {
        return this.resources.get(resourceId) || null;
    }
    getAllResources(): PetBallResource[] {
        return Array.from(this.resources.values()).filter(r => r.status === 'active');
    }
    getPresetResources(): PetBallResource[] {
        return this.presetResources.filter(r => r.status === 'active');
    }
    getCustomResources(): PetBallResource[] {
        return this.getAllResources().filter(r => r.type === 'custom');
    }
    async deleteResource(resourceId: string): Promise<boolean> {
        const resource = this.resources.get(resourceId);
        if (!resource) {
            return false;
        }
        if (resource.type === 'preset') {
            console.error('Cannot delete preset resource');
            return false;
        }
        const success = await this.resourceDAO.deleteResource(resourceId);
        if (success) {
            resource.status = 'deleted';
            this.resources.set(resourceId, resource);
            return true;
        }
        return false;
    }
    async loadResourceImage(resourceId: string): Promise<ArrayBuffer | null> {
        const resource = this.resources.get(resourceId);
        if (!resource) {
            return null;
        }
        if (resource.type === 'preset') {
            return null;
        }
        return await this.resourceDAO.loadResourceImage(resourceId);
    }
    getResourceCount(): number {
        return this.getAllResources().length;
    }
    hasResource(resourceId: string): boolean {
        const resource = this.resources.get(resourceId);
        return resource !== undefined && resource.status === 'active';
    }
}
