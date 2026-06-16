import type { PetBallInstance } from '../dao/DataModels';
import type { StateManager } from './StateManager';
import { TimerServiceAdapter } from "@bundle:com.example.desktoppetball/entry/ets/adapter/TimerServiceAdapter";
export type InteractionType = 'dialog' | 'gift_request' | 'action';
export class InteractionData {
    message: string = '';
    title: string = '';
    action: string = '';
}
export interface ActiveInteraction {
    instanceId: string;
    type: InteractionType;
    timestamp: number;
    data?: InteractionData;
}
export class ActiveInteractionManager {
    private stateManager: StateManager;
    private timerAdapter: TimerServiceAdapter;
    private lastInteractionTime: Map<string, number> = new Map();
    private triggerProbability: number = 0.3;
    private minInterval: number = 300000; // 5分钟
    private maxInactiveTime: number = 300000; // 5分钟
    private interactionHistory: ActiveInteraction[] = [];
    private maxHistorySize: number = 50;
    constructor(stateManager: StateManager) {
        this.stateManager = stateManager;
        this.timerAdapter = new TimerServiceAdapter();
    }
    init(): void {
        this.startInteractionTimer();
    }
    private startInteractionTimer(): void {
        this.timerAdapter.createInteractionTimer(() => {
            this.checkActiveInteraction();
        }, 60000); // 每分钟检查一次
        this.timerAdapter.startInteractionTimer();
    }
    private async checkActiveInteraction(): Promise<void> {
        // 检查所有追随状态的宠物球
        // 如果用户长时间未交互，则概率触发主动交互
        // 此处为简化实现
    }
    async checkAndTriggerInteraction(instance: PetBallInstance): Promise<ActiveInteraction | null> {
        if (instance.state !== 'following') {
            return null;
        }
        const lastInteraction = this.lastInteractionTime.get(instance.id) || instance.lastInteractionTime;
        const timeSinceLastInteraction = Date.now() - lastInteraction;
        if (timeSinceLastInteraction < this.maxInactiveTime) {
            return null;
        }
        const lastActiveInteraction = this.getLastActiveInteraction(instance.id);
        if (lastActiveInteraction) {
            const timeSinceLastActive = Date.now() - lastActiveInteraction.timestamp;
            if (timeSinceLastActive < this.minInterval) {
                return null;
            }
        }
        if (Math.random() > this.triggerProbability) {
            return null;
        }
        const interaction = await this.triggerInteraction(instance);
        return interaction;
    }
    private async triggerInteraction(instance: PetBallInstance): Promise<ActiveInteraction> {
        const types: InteractionType[] = ['dialog', 'gift_request', 'action'];
        const type = types[Math.floor(Math.random() * types.length)];
        const interaction: ActiveInteraction = {
            instanceId: instance.id,
            type: type,
            timestamp: Date.now()
        };
        this.interactionHistory.push(interaction);
        if (this.interactionHistory.length > this.maxHistorySize) {
            this.interactionHistory.shift();
        }
        console.info(`Triggered active interaction for ${instance.id}: ${type}`);
        return interaction;
    }
    recordUserInteraction(instanceId: string): void {
        this.lastInteractionTime.set(instanceId, Date.now());
    }
    private getLastActiveInteraction(instanceId: string): ActiveInteraction | null {
        const reversedHistory = [...this.interactionHistory].reverse();
        return reversedHistory.find(interaction => interaction.instanceId === instanceId) || null;
    }
    setTriggerProbability(probability: number): void {
        this.triggerProbability = Math.max(0, Math.min(1, probability));
    }
    setMinInterval(interval: number): void {
        this.minInterval = interval;
    }
    setMaxInactiveTime(time: number): void {
        this.maxInactiveTime = time;
    }
    getInteractionHistory(): ActiveInteraction[] {
        return [...this.interactionHistory];
    }
    clearHistory(): void {
        this.interactionHistory = [];
    }
    stopInteractionTimer(): void {
        this.timerAdapter.stopInteractionTimer();
    }
    resumeInteractionTimer(): void {
        this.timerAdapter.startInteractionTimer();
    }
}
