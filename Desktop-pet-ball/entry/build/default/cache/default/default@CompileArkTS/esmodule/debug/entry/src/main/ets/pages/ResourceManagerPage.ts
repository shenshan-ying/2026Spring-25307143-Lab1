if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface ResourceManagerPage_Params {
    resources?: PetBallResource[];
    selectedResourceId?: string;
    showAddDialog?: boolean;
    resourceManager?: ResourceManager;
    permissionManager?: PermissionManager;
    logger?: Logger;
}
import type { PetBallResource } from '../dao/DataModels';
import { ResourceManager } from "@bundle:com.example.desktoppetball/entry/ets/manager/ResourceManager";
import { PermissionManager } from "@bundle:com.example.desktoppetball/entry/ets/service/PermissionManager";
import { Logger } from "@bundle:com.example.desktoppetball/entry/ets/utils/Logger";
import type common from "@ohos:app.ability.common";
class ResourceManagerPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__resources = new ObservedPropertyObjectPU([], this, "resources");
        this.__selectedResourceId = new ObservedPropertySimplePU('', this, "selectedResourceId");
        this.__showAddDialog = new ObservedPropertySimplePU(false, this, "showAddDialog");
        this.resourceManager = new ResourceManager();
        this.permissionManager = new PermissionManager();
        this.logger = Logger.getInstance();
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: ResourceManagerPage_Params) {
        if (params.resources !== undefined) {
            this.resources = params.resources;
        }
        if (params.selectedResourceId !== undefined) {
            this.selectedResourceId = params.selectedResourceId;
        }
        if (params.showAddDialog !== undefined) {
            this.showAddDialog = params.showAddDialog;
        }
        if (params.resourceManager !== undefined) {
            this.resourceManager = params.resourceManager;
        }
        if (params.permissionManager !== undefined) {
            this.permissionManager = params.permissionManager;
        }
        if (params.logger !== undefined) {
            this.logger = params.logger;
        }
    }
    updateStateVars(params: ResourceManagerPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__resources.purgeDependencyOnElmtId(rmElmtId);
        this.__selectedResourceId.purgeDependencyOnElmtId(rmElmtId);
        this.__showAddDialog.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__resources.aboutToBeDeleted();
        this.__selectedResourceId.aboutToBeDeleted();
        this.__showAddDialog.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __resources: ObservedPropertyObjectPU<PetBallResource[]>;
    get resources() {
        return this.__resources.get();
    }
    set resources(newValue: PetBallResource[]) {
        this.__resources.set(newValue);
    }
    private __selectedResourceId: ObservedPropertySimplePU<string>;
    get selectedResourceId() {
        return this.__selectedResourceId.get();
    }
    set selectedResourceId(newValue: string) {
        this.__selectedResourceId.set(newValue);
    }
    private __showAddDialog: ObservedPropertySimplePU<boolean>;
    get showAddDialog() {
        return this.__showAddDialog.get();
    }
    set showAddDialog(newValue: boolean) {
        this.__showAddDialog.set(newValue);
    }
    private resourceManager: ResourceManager;
    private permissionManager: PermissionManager;
    private logger: Logger;
    async aboutToAppear(): Promise<void> {
        const context = getContext(this) as common.UIAbilityContext;
        this.permissionManager.init(context);
        await this.resourceManager.init(context);
        await this.loadResources();
    }
    private async loadResources(): Promise<void> {
        this.resources = await this.resourceManager.getAllResources();
        // 如果没有资源，添加预设资源
        if (this.resources.length === 0) {
            await this.addPresetResources();
        }
    }
    private async addPresetResources(): Promise<void> {
        const presets: PetBallResource[] = [
            {
                id: 'preset_cat',
                type: 'preset',
                name: '猫咪球',
                animalType: 'cat',
                imagePath: 'cat_ball.png',
                createdAt: Date.now(),
                status: 'active'
            },
            {
                id: 'preset_dog',
                type: 'preset',
                name: '狗狗球',
                animalType: 'dog',
                imagePath: 'dog_ball.png',
                createdAt: Date.now(),
                status: 'active'
            },
            {
                id: 'preset_bird',
                type: 'preset',
                name: '小鸟球',
                animalType: 'bird',
                imagePath: 'bird_ball.png',
                createdAt: Date.now(),
                status: 'active'
            }
        ];
        // 预设资源已在 ResourceManager 构造函数中初始化
        this.resources = this.resourceManager.getAllResources();
    }
    private async deleteResource(resourceId: string): Promise<void> {
        await this.resourceManager.deleteResource(resourceId);
        this.resources = this.resourceManager.getAllResources();
    }
    private async pickFromGallery(): Promise<void> {
        const result = await this.permissionManager.requestPermission('ohos.permission.READ_MEDIA');
        if (!result.granted) {
            this.logger.warn('ResourceManagerPage', 'READ_MEDIA permission denied');
            return;
        }
        const resource = await this.resourceManager.createCustomResourceFromGallery();
        if (resource) {
            this.resources = this.resourceManager.getAllResources();
            this.logger.info('ResourceManagerPage', `Created resource from gallery: ${resource.id}`);
        }
    }
    private async takePhoto(): Promise<void> {
        const result = await this.permissionManager.requestPermission('ohos.permission.CAMERA');
        if (!result.granted) {
            this.logger.warn('ResourceManagerPage', 'CAMERA permission denied');
            return;
        }
        const resource = await this.resourceManager.createCustomResourceFromCamera();
        if (resource) {
            this.resources = this.resourceManager.getAllResources();
            this.logger.info('ResourceManagerPage', `Created resource from camera: ${resource.id}`);
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.bindSheet({ value: this.showAddDialog, changeEvent: newValue => { this.showAddDialog = newValue; } }, { builder: () => {
                    this.AddResourceSheet.call(this);
                } }, {
                height: 300,
                backgroundColor: Color.White,
                dragBar: true
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标题栏
            Row.create();
            // 标题栏
            Row.width('100%');
            // 标题栏
            Row.padding(15);
            // 标题栏
            Row.backgroundColor('#FFFFFF');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('返回');
            Button.fontSize(16);
            Button.width(70);
            Button.height(40);
            Button.onClick(() => {
                this.getUIContext().getRouter().back();
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('资源管理');
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
            Text.layoutWeight(1);
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('+');
            Button.fontSize(20);
            Button.width(40);
            Button.height(40);
            Button.onClick(() => {
                this.showAddDialog = true;
            });
        }, Button);
        Button.pop();
        // 标题栏
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 资源列表
            Scroll.create();
            // 资源列表
            Scroll.layoutWeight(1);
            // 资源列表
            Scroll.backgroundColor('#F0F0F5');
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 预设资源
            Column.create();
            // 预设资源
            Column.width('100%');
            // 预设资源
            Column.padding(20);
            // 预设资源
            Column.backgroundColor('#FFFFFF');
            // 预设资源
            Column.borderRadius(10);
            // 预设资源
            Column.margin({ top: 15, left: 15, right: 15 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('预设资源');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.width('100%');
            Text.margin({ bottom: 15 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const resource = _item;
                this.ResourceItem.bind(this)(resource);
            };
            this.forEachUpdateFunction(elmtId, this.resources.filter(r => r.type === 'preset'), forEachItemGenFunction, (resource: PetBallResource) => resource.id, false, false);
        }, ForEach);
        ForEach.pop();
        // 预设资源
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 自定义资源
            Column.create();
            // 自定义资源
            Column.width('100%');
            // 自定义资源
            Column.padding(20);
            // 自定义资源
            Column.backgroundColor('#FFFFFF');
            // 自定义资源
            Column.borderRadius(10);
            // 自定义资源
            Column.margin({ top: 15, left: 15, right: 15, bottom: 30 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('自定义资源');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.width('100%');
            Text.margin({ bottom: 15 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.resources.filter(r => r.type === 'custom').length === 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('暂无自定义资源');
                        Text.fontSize(14);
                        Text.fontColor('#999999');
                        Text.width('100%');
                        Text.textAlign(TextAlign.Center);
                        Text.padding(20);
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const resource = _item;
                            this.ResourceItem.bind(this)(resource);
                        };
                        this.forEachUpdateFunction(elmtId, this.resources.filter(r => r.type === 'custom'), forEachItemGenFunction, (resource: PetBallResource) => resource.id, false, false);
                    }, ForEach);
                    ForEach.pop();
                });
            }
        }, If);
        If.pop();
        // 自定义资源
        Column.pop();
        Column.pop();
        // 资源列表
        Scroll.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 底部操作栏
            Row.create();
            // 底部操作栏
            Row.width('100%');
            // 底部操作栏
            Row.padding(15);
            // 底部操作栏
            Row.backgroundColor('#FFFFFF');
            // 底部操作栏
            Row.justifyContent(FlexAlign.SpaceBetween);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('从相册选择');
            Button.fontSize(16);
            Button.width('45%');
            Button.height(50);
            Button.backgroundColor('#4ECDC4');
            Button.onClick(async () => {
                await this.pickFromGallery();
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('拍摄照片');
            Button.fontSize(16);
            Button.width('45%');
            Button.height(50);
            Button.backgroundColor('#FF6B6B');
            Button.onClick(async () => {
                await this.takePhoto();
            });
        }, Button);
        Button.pop();
        // 底部操作栏
        Row.pop();
        Column.pop();
    }
    ResourceItem(resource: PetBallResource, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding(15);
            Row.backgroundColor('#F9F9F9');
            Row.borderRadius(8);
            Row.margin({ bottom: 10 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 资源图标
            Column.create();
            // 资源图标
            Column.margin({ right: 15 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create();
            Circle.width(60);
            Circle.height(60);
            Circle.fill(this.getResourceColor(resource));
        }, Circle);
        // 资源图标
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 资源信息
            Column.create();
            // 资源信息
            Column.layoutWeight(1);
            // 资源信息
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(resource.name);
            Text.fontSize(16);
            Text.fontWeight(FontWeight.Bold);
            Text.width('100%');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`${resource.type === 'preset' ? '预设' : '自定义'} | ${resource.animalType || '未知'}`);
            Text.fontSize(12);
            Text.fontColor('#999999');
            Text.width('100%');
            Text.margin({ top: 5 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(new Date(resource.createdAt).toLocaleDateString());
            Text.fontSize(12);
            Text.fontColor('#CCCCCC');
            Text.width('100%');
            Text.margin({ top: 5 });
        }, Text);
        Text.pop();
        // 资源信息
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 操作按钮
            if (resource.type === 'custom') {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Button.createWithLabel('删除');
                        Button.fontSize(14);
                        Button.width(60);
                        Button.height(35);
                        Button.backgroundColor('#FF6B6B');
                        Button.onClick(async () => {
                            await this.deleteResource(resource.id);
                        });
                    }, Button);
                    Button.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Row.pop();
    }
    AddResourceSheet(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.padding(20);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('添加自定义资源');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ bottom: 20 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.justifyContent(FlexAlign.SpaceBetween);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('从相册选择');
            Button.fontSize(16);
            Button.width('45%');
            Button.height(50);
            Button.backgroundColor('#4ECDC4');
            Button.onClick(async () => {
                this.showAddDialog = false;
                await this.pickFromGallery();
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('拍摄照片');
            Button.fontSize(16);
            Button.width('45%');
            Button.height(50);
            Button.backgroundColor('#FF6B6B');
            Button.onClick(async () => {
                this.showAddDialog = false;
                await this.takePhoto();
            });
        }, Button);
        Button.pop();
        Row.pop();
        Column.pop();
    }
    private getResourceColor(resource: PetBallResource): string {
        const colors: Record<string, string> = {
            'cat': '#FFD700',
            'dog': '#FFA500',
            'bird': '#4ECDC4'
        };
        return colors[resource.animalType || ''] || '#FF6B6B';
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "ResourceManagerPage";
    }
}
registerNamedRoute(() => new ResourceManagerPage(undefined, {}), "", { bundleName: "com.example.desktoppetball", moduleName: "entry", pagePath: "pages/ResourceManagerPage", pageFullPath: "entry/src/main/ets/pages/ResourceManagerPage", integratedHsp: "false", moduleType: "followWithHap" });
