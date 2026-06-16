if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface SettingsPage_Params {
    config?: AppConfig;
    motionModeIndex?: number;
    judgmentLineIndex?: number;
    configManager?: ConfigManager;
    logger?: Logger;
}
import type { AppConfig } from '../dao/DataModels';
import { ConfigManager } from "@bundle:com.example.desktoppetball/entry/ets/service/ConfigManager";
import { Logger } from "@bundle:com.example.desktoppetball/entry/ets/utils/Logger";
import type common from "@ohos:app.ability.common";
class SettingsPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__config = new ObservedPropertyObjectPU({
            motionMode: 'free_rolling',
            motionSpeed: 100,
            judgmentLinePosition: 'bottom',
            petBallSizeCoefficient: 1.0,
            version: '1.0.0'
        }, this, "config");
        this.__motionModeIndex = new ObservedPropertySimplePU(0, this, "motionModeIndex");
        this.__judgmentLineIndex = new ObservedPropertySimplePU(0, this, "judgmentLineIndex");
        this.configManager = new ConfigManager();
        this.logger = Logger.getInstance();
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: SettingsPage_Params) {
        if (params.config !== undefined) {
            this.config = params.config;
        }
        if (params.motionModeIndex !== undefined) {
            this.motionModeIndex = params.motionModeIndex;
        }
        if (params.judgmentLineIndex !== undefined) {
            this.judgmentLineIndex = params.judgmentLineIndex;
        }
        if (params.configManager !== undefined) {
            this.configManager = params.configManager;
        }
        if (params.logger !== undefined) {
            this.logger = params.logger;
        }
    }
    updateStateVars(params: SettingsPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__config.purgeDependencyOnElmtId(rmElmtId);
        this.__motionModeIndex.purgeDependencyOnElmtId(rmElmtId);
        this.__judgmentLineIndex.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__config.aboutToBeDeleted();
        this.__motionModeIndex.aboutToBeDeleted();
        this.__judgmentLineIndex.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __config: ObservedPropertyObjectPU<AppConfig>;
    get config() {
        return this.__config.get();
    }
    set config(newValue: AppConfig) {
        this.__config.set(newValue);
    }
    private __motionModeIndex: ObservedPropertySimplePU<number>;
    get motionModeIndex() {
        return this.__motionModeIndex.get();
    }
    set motionModeIndex(newValue: number) {
        this.__motionModeIndex.set(newValue);
    }
    private __judgmentLineIndex: ObservedPropertySimplePU<number>;
    get judgmentLineIndex() {
        return this.__judgmentLineIndex.get();
    }
    set judgmentLineIndex(newValue: number) {
        this.__judgmentLineIndex.set(newValue);
    }
    private configManager: ConfigManager;
    private logger: Logger;
    async aboutToAppear(): Promise<void> {
        // 获取上下文 - 修复API调用
        const context = getContext(this) as common.UIAbilityContext;
        await this.configManager.init(context);
        const loadedConfig = await this.configManager.loadConfig();
        if (loadedConfig) {
            this.config = loadedConfig;
        }
        const modes = ['free_rolling', 'static', 'slingshot', 'following'];
        this.motionModeIndex = modes.indexOf(this.config.motionMode);
        if (this.motionModeIndex < 0)
            this.motionModeIndex = 0;
        this.judgmentLineIndex = ['bottom', 'top', 'left', 'right'].indexOf(this.config.judgmentLinePosition);
    }
    private async saveConfig(): Promise<void> {
        await this.configManager.saveConfig();
        this.logger.info('SettingsPage', 'Config saved');
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
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
            Text.create('设置');
            Text.fontSize(20);
            Text.fontWeight(FontWeight.Bold);
            Text.layoutWeight(1);
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('保存');
            Button.fontSize(16);
            Button.width(70);
            Button.height(40);
            Button.onClick(async () => {
                await this.saveConfig();
                this.getUIContext().getRouter().back();
            });
        }, Button);
        Button.pop();
        // 标题栏
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.layoutWeight(1);
            Scroll.backgroundColor('#F0F0F5');
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 运动模式设置
            Column.create();
            // 运动模式设置
            Column.width('100%');
            // 运动模式设置
            Column.padding(20);
            // 运动模式设置
            Column.backgroundColor('#FFFFFF');
            // 运动模式设置
            Column.borderRadius(10);
            // 运动模式设置
            Column.margin({ top: 15, left: 15, right: 15 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('运动模式');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.width('100%');
            Text.margin({ bottom: 15 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Grid.create();
            Grid.columnsTemplate('1fr 1fr');
            Grid.rowsTemplate('1fr 1fr');
            Grid.width('100%');
            Grid.height(120);
        }, Grid);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = (_item, index: number) => {
                const item = _item;
                {
                    const itemCreation2 = (elmtId, isInitialRender) => {
                        GridItem.create(() => { }, false);
                    };
                    const observedDeepRender = () => {
                        this.observeComponentCreation2(itemCreation2, GridItem);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item);
                            Text.fontSize(16);
                            Text.fontColor(this.motionModeIndex === index ? '#FF6B6B' : '#666666');
                            Text.padding(10);
                            Text.backgroundColor(this.motionModeIndex === index ? '#FFE5E5' : '#F5F5F5');
                            Text.borderRadius(8);
                            Text.onClick(() => {
                                this.motionModeIndex = index;
                                const modes = ['free_rolling', 'static', 'slingshot', 'following'];
                                this.config.motionMode = modes[index] as 'free_rolling' | 'static' | 'slingshot' | 'following';
                            });
                        }, Text);
                        Text.pop();
                        GridItem.pop();
                    };
                    observedDeepRender();
                }
            };
            this.forEachUpdateFunction(elmtId, ['自由滚动', '静止', '弹弓发射', '跟随'], forEachItemGenFunction, undefined, true, false);
        }, ForEach);
        ForEach.pop();
        Grid.pop();
        // 运动模式设置
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 运动速度设置
            Column.create();
            // 运动速度设置
            Column.width('100%');
            // 运动速度设置
            Column.padding(20);
            // 运动速度设置
            Column.backgroundColor('#FFFFFF');
            // 运动速度设置
            Column.borderRadius(10);
            // 运动速度设置
            Column.margin({ top: 15, left: 15, right: 15 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('运动速度');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.width('100%');
            Text.margin({ bottom: 15 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.justifyContent(FlexAlign.SpaceBetween);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('慢');
            Text.fontSize(14);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Slider.create({
                value: this.config.motionSpeed,
                min: 20,
                max: 200,
                step: 10
            });
            Slider.width('60%');
            Slider.blockColor('#FF6B6B');
            Slider.trackColor('#FFE5E5');
            Slider.onChange((value: number) => {
                this.config.motionSpeed = value;
            });
        }, Slider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('快');
            Text.fontSize(14);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`当前速度: ${this.config.motionSpeed}`);
            Text.fontSize(14);
            Text.fontColor('#666666');
            Text.margin({ top: 10 });
        }, Text);
        Text.pop();
        // 运动速度设置
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 宠物球大小设置
            Column.create();
            // 宠物球大小设置
            Column.width('100%');
            // 宠物球大小设置
            Column.padding(20);
            // 宠物球大小设置
            Column.backgroundColor('#FFFFFF');
            // 宠物球大小设置
            Column.borderRadius(10);
            // 宠物球大小设置
            Column.margin({ top: 15, left: 15, right: 15 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('宠物球大小');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.width('100%');
            Text.margin({ bottom: 15 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.justifyContent(FlexAlign.SpaceBetween);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('小');
            Text.fontSize(14);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Slider.create({
                value: this.config.petBallSizeCoefficient,
                min: 0.5,
                max: 2.0,
                step: 0.1
            });
            Slider.width('60%');
            Slider.blockColor('#4ECDC4');
            Slider.trackColor('#E5F9F6');
            Slider.onChange((value: number) => {
                this.config.petBallSizeCoefficient = value;
            });
        }, Slider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('大');
            Text.fontSize(14);
            Text.fontColor('#999999');
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`当前大小系数: ${this.config.petBallSizeCoefficient.toFixed(1)}`);
            Text.fontSize(14);
            Text.fontColor('#666666');
            Text.margin({ top: 10 });
        }, Text);
        Text.pop();
        // 宠物球大小设置
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 判定线位置设置
            Column.create();
            // 判定线位置设置
            Column.width('100%');
            // 判定线位置设置
            Column.padding(20);
            // 判定线位置设置
            Column.backgroundColor('#FFFFFF');
            // 判定线位置设置
            Column.borderRadius(10);
            // 判定线位置设置
            Column.margin({ top: 15, left: 15, right: 15 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('判定线位置');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.width('100%');
            Text.margin({ bottom: 15 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Grid.create();
            Grid.columnsTemplate('1fr 1fr');
            Grid.rowsTemplate('1fr 1fr');
            Grid.width('100%');
            Grid.height(120);
        }, Grid);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = (_item, index: number) => {
                const item = _item;
                {
                    const itemCreation2 = (elmtId, isInitialRender) => {
                        GridItem.create(() => { }, false);
                    };
                    const observedDeepRender = () => {
                        this.observeComponentCreation2(itemCreation2, GridItem);
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            Text.create(item);
                            Text.fontSize(16);
                            Text.fontColor(this.judgmentLineIndex === index ? '#FF6B6B' : '#666666');
                            Text.padding(10);
                            Text.backgroundColor(this.judgmentLineIndex === index ? '#FFE5E5' : '#F5F5F5');
                            Text.borderRadius(8);
                            Text.onClick(() => {
                                this.judgmentLineIndex = index;
                                this.config.judgmentLinePosition = ['bottom', 'top', 'left', 'right'][index] as 'bottom' | 'top' | 'left' | 'right';
                            });
                        }, Text);
                        Text.pop();
                        GridItem.pop();
                    };
                    observedDeepRender();
                }
            };
            this.forEachUpdateFunction(elmtId, ['底部', '顶部', '左侧', '右侧'], forEachItemGenFunction, undefined, true, false);
        }, ForEach);
        ForEach.pop();
        Grid.pop();
        // 判定线位置设置
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 版本信息
            Column.create();
            // 版本信息
            Column.width('100%');
            // 版本信息
            Column.padding(20);
            // 版本信息
            Column.backgroundColor('#FFFFFF');
            // 版本信息
            Column.borderRadius(10);
            // 版本信息
            Column.margin({ top: 15, left: 15, right: 15, bottom: 30 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('版本信息');
            Text.fontSize(18);
            Text.fontWeight(FontWeight.Bold);
            Text.width('100%');
            Text.margin({ bottom: 15 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(`版本: ${this.config.version}`);
            Text.fontSize(14);
            Text.fontColor('#666666');
        }, Text);
        Text.pop();
        // 版本信息
        Column.pop();
        Column.pop();
        Scroll.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "SettingsPage";
    }
}
registerNamedRoute(() => new SettingsPage(undefined, {}), "", { bundleName: "com.example.desktoppetball", moduleName: "entry", pagePath: "pages/SettingsPage", pageFullPath: "entry/src/main/ets/pages/SettingsPage", integratedHsp: "false", moduleType: "followWithHap" });
