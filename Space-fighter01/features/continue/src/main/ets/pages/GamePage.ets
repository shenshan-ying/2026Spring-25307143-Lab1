/*
 * Copyright (c) 2026
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

import { GameDataSync, GameRecord } from '../utils/GameDataSync';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'GamePage';

// ---------- Constants ----------
const PLAYER_SIZE = 40;
const PLAYER_HP = 5;
const PLAYER_ATK = 1;
const BULLET_SIZE = 6;
const BULLET_SPEED = 8;
const PLAYER_SPEED = 6;
const BASE_ENEMY_SPEED = 1.5;
const INVINCIBLE_DURATION = 1000; // ms
const FIRE_COOLDOWN = 300; // ms
const GAME_LOOP_INTERVAL = 16; // ~60fps
const BASE_SPAWN_INTERVAL = 1500; // ms

// Enemy definitions
interface EnemyDef {
  type: 'low' | 'mid' | 'high';
  hp: number;
  atk: number;
  size: number;
  baseWeight: number;
  color: number;
  score: number;
}

const ENEMY_DEFS: EnemyDef[] = [
  { type: 'low', hp: 1, atk: 1, size: 20, baseWeight: 6, color: 0xFF4CAF50, score: 1 },
  { type: 'mid', hp: 2, atk: 1, size: 28, baseWeight: 3, color: 0xFFFFEB3B, score: 2 },
  { type: 'high', hp: 3, atk: 2, size: 36, baseWeight: 1, color: 0xFFF44336, score: 3 }
];

interface Bullet {
  x: number;
  y: number;
  active: boolean;
}

interface Enemy {
  x: number;
  y: number;
  hp: number;
  maxHp: number;
  atk: number;
  size: number;
  type: 'low' | 'mid' | 'high';
  color: number;
  speed: number;
  score: number;
  active: boolean;
}

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  life: number;
  maxLife: number;
  color: number;
  size: number;
}

interface EnemyWeights {
  low: number;
  mid: number;
  high: number;
}

interface EnemyData {
  x: number;
  y: number;
  hp: number;
  maxHp: number;
  atk: number;
  size: number;
  type: 'low' | 'mid' | 'high';
  color: number;
  speed: number;
  score: number;
  active: boolean;
}

interface BulletData {
  x: number;
  y: number;
  active: boolean;
}

@Component
export struct GamePage {
  @StorageLink('gameMode') gameMode: string = 'endless';
  @StorageLink('gameScore') gameScore: number = 0;
  @StorageLink('gamePlayerHP') gamePlayerHP: number = PLAYER_HP;
  @StorageLink('gamePlayerX') gamePlayerX: number = 0;
  @StorageLink('gamePlayerY') gamePlayerY: number = 0;
  @StorageLink('gameEnemies') gameEnemies: string = '[]';
  @StorageLink('gameBullets') gameBullets: string = '[]';
  @StorageLink('gameStatus') gameStatus: string = 'playing';
  @StorageLink('gameCurrentLevel') gameCurrentLevel: number = 1;
  @StorageLink('gameLevelKills') gameLevelKills: number = 0;
  @StorageLink('gameLevelTarget') gameLevelTarget: number = 8;
  @StorageLink('gameInvincible') gameInvincible: boolean = false;

  // Non-storage state
  private settings: Record<string, string | number | boolean> = {};
  private canvasSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.canvasSettings);
  private gameTimer: number = -1;
  private invincibleTimer: number = -1;
  private lastFireTime: number = 0;
  private lastSpawnTime: number = 0;
  private playerX: number = 0;
  private playerY: number = 0;
  private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private bullets: Bullet[] = [];
  private enemies: Enemy[] = [];
  private particles: Particle[] = [];
  private isPaused: boolean = false;
  private isGameOver: boolean = false;
  private levelClearShown: boolean = false;
  private levelClearTimer: number = -1;
  private isNewRecord: boolean = false;
  private dataSync: GameDataSync | null = null;
  private context: common.UIAbilityContext | null = null;

  aboutToAppear() {
    this.context = this.getUIContext().getHostContext()! as common.UIAbilityContext;
    // Init data sync service
    if (this.context) {
      this.dataSync = new GameDataSync(this.context);
      this.dataSync?.initKVStore();
    }

    // Check if state is being restored from continuation
    const savedScore = AppStorage.get<number>('gameScore');
    if (savedScore !== undefined && savedScore > 0) {
      // Restore from continuation - parse stored arrays
      this.bullets = this.parseBullets(this.gameBullets);
      this.enemies = this.parseEnemies(this.gameEnemies);
      this.playerX = this.gamePlayerX;
      this.playerY = this.gamePlayerY;
      this.isPaused = false;
      this.isGameOver = false;
      this.gameStatus = 'playing';
    } else {
      // Fresh start - init game state
      this.gameScore = 0;
      this.gamePlayerHP = PLAYER_HP;
      this.gameCurrentLevel = 1;
      this.gameLevelKills = 0;
      this.gameStatus = 'playing';
      this.levelClearShown = false;
      this.isGameOver = false;
      this.isPaused = false;
      this.bullets = [];
      this.enemies = [];
      this.particles = [];
      this.isNewRecord = false;
    }
  }

  aboutToDisappear() {
    this.stopGameLoop();
    if (this.invincibleTimer !== -1) {
      clearTimeout(this.invincibleTimer);
      this.invincibleTimer = -1;
    }
    if (this.levelClearTimer !== -1) {
      clearTimeout(this.levelClearTimer);
      this.levelClearTimer = -1;
    }
    // Save record to distributed KV if game was played
    if (this.gameScore > 0 && this.dataSync) {
      const record: GameRecord = {
        highScore: this.gameScore,
        highestLevel: this.gameCurrentLevel,
        totalKills: this.calcTotalKills(),
        totalKillsLow: 0,
        totalKillsMid: 0,
        totalKillsHigh: 0,
        endlessBestScore: this.gameMode === 'endless' ? this.gameScore : 0
      };
      this.dataSync!.saveGameRecord(record);
    }
    // Persist arrays to AppStorage before leaving
    this.syncToStorage();
  }

  private calcTotalKills(): number {
    // Simplified - return score since we don't track per-type in migration
    return this.gameScore;
  }

  // ---- Canvas lifecycle ----
  private onCanvasReady(): void {
    // Called when Canvas mounts - handled by onAreaChange
  }

  private onCanvasAreaChange(oldVal: Area, newVal: Area): void {
    this.canvasWidth = newVal.width as number;
    this.canvasHeight = newVal.height as number;
    if (this.playerX === 0 && this.playerY === 0) {
      this.playerX = this.canvasWidth / 2;
      this.playerY = this.canvasHeight - 80;
      this.gamePlayerX = this.playerX;
      this.gamePlayerY = this.playerY;
    }
    this.startGameLoop();
  }

  // ---- Game Loop ----
  private startGameLoop(): void {
    if (this.gameTimer !== -1) return;
    this.gameTimer = setInterval(() => {
      if (this.isPaused || this.isGameOver) return;
      this.update();
      this.draw();
    }, GAME_LOOP_INTERVAL);
  }

  private stopGameLoop(): void {
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer);
      this.gameTimer = -1;
    }
  }

  // ---- Update Logic ----
  private update(): void {
    const now = Date.now();
    const level = this.gameCurrentLevel;

    // Update level target
    if (this.gameMode === 'level') {
      this.gameLevelTarget = 5 + level * 3;
    }

    // Spawn enemies
    const spawnInterval = this.getSpawnInterval();
    if (now - this.lastSpawnTime > spawnInterval) {
      this.spawnEnemy();
      this.lastSpawnTime = now;
    }

    // Update bullets
    for (let b of this.bullets) {
      if (b.active) {
        b.y -= BULLET_SPEED;
        if (b.y < -10) b.active = false;
      }
    }

    // Update enemies
    const enemySpeed = this.getEnemySpeed();
    for (let e of this.enemies) {
      if (e.active) {
        e.y += enemySpeed;
        if (e.y > this.canvasHeight + 50) e.active = false;
      }
    }

    // Bullet-Enemy collision
    for (let b of this.bullets) {
      if (!b.active) continue;
      for (let e of this.enemies) {
        if (!e.active) continue;
        if (this.checkCollision(b.x, b.y, BULLET_SIZE, e.x, e.y, e.size)) {
          b.active = false;
          e.hp -= PLAYER_ATK;
          if (e.hp <= 0) {
            e.active = false;
            this.gameScore += e.score;
            this.spawnExplosion(e.x, e.y, e.color);
            if (this.gameMode === 'level') {
              this.gameLevelKills += 1;
            }
          }
          break;
        }
      }
    }

    // Enemy-Player collision
    if (!this.gameInvincible) {
      for (let e of this.enemies) {
        if (!e.active) continue;
        if (this.checkCollision(this.playerX, this.playerY, PLAYER_SIZE, e.x, e.y, e.size)) {
          this.gamePlayerHP -= e.atk;
          e.active = false;
          this.spawnExplosion(e.x, e.y, e.color);
          if (this.gamePlayerHP <= 0) {
            this.gamePlayerHP = 0;
            this.gameOver();
            return;
          }
          // Enter invincible state
          this.gameInvincible = true;
          this.invincibleTimer = setTimeout(() => {
            this.gameInvincible = false;
            this.invincibleTimer = -1;
          }, INVINCIBLE_DURATION);
          break;
        }
      }
    }

    // Check level clear
    if (this.gameMode === 'level' && this.gameLevelKills >= this.gameLevelTarget && !this.levelClearShown) {
      this.levelClearShown = true;
      this.gameStatus = 'levelClear';
      this.levelClearTimer = setTimeout(() => {
        this.nextLevel();
      }, 2000);
    }

    // Update particles
    for (let p of this.particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.life--;
      p.size *= 0.96;
    }
    this.particles = this.particles.filter(p => p.life > 0);

    // Cleanup inactive
    this.bullets = this.bullets.filter(b => b.active);
    this.enemies = this.enemies.filter(e => e.active);

    // Sync to AppStorage for continuation
    this.syncToStorage();
  }

  private getSpawnInterval(): number {
    if (this.gameMode === 'level') {
      return Math.max(800, 2000 - this.gameCurrentLevel * 100);
    }
    return BASE_SPAWN_INTERVAL;
  }

  private getEnemySpeed(): number {
    if (this.gameMode === 'level') {
      return BASE_ENEMY_SPEED * (1 + this.gameCurrentLevel * 0.15);
    }
    return BASE_ENEMY_SPEED;
  }

  private spawnEnemy(): void {
    const weights = this.calcEnemyWeights();
    const totalWeight = weights.low + weights.mid + weights.high;
    const rand = Math.random() * totalWeight;
    let chosenType: 'low' | 'mid' | 'high';
    if (rand < weights.low) {
      chosenType = 'low';
    } else if (rand < weights.low + weights.mid) {
      chosenType = 'mid';
    } else {
      chosenType = 'high';
    }

    const def = ENEMY_DEFS.find(d => d.type === chosenType)!;
    const x = Math.random() * (this.canvasWidth - 60) + 30;
    const enemy: Enemy = {
      x: x, y: -def.size,
      hp: def.hp, maxHp: def.hp,
      atk: def.atk, size: def.size,
      type: def.type, color: def.color,
      speed: this.getEnemySpeed(),
      score: def.score,
      active: true
    };
    this.enemies.push(enemy);
  }

  private calcEnemyWeights(): EnemyWeights {
    const level = this.gameCurrentLevel;
    const lowW = 6;
    const midW = 3;
    const highW = 1 * (1 + level * 0.3);
    return { low: lowW, mid: midW, high: highW };
  }

  private checkCollision(x1: number, y1: number, s1: number, x2: number, y2: number, s2: number): boolean {
    const dx = x1 - x2;
    const dy = y1 - y2;
    const dist = Math.sqrt(dx * dx + dy * dy);
    return dist < (s1 / 2 + s2 / 2);
  }

  private spawnExplosion(x: number, y: number, color: number): void {
    for (let i = 0; i < 12; i++) {
      const angle = (Math.PI * 2 / 12) * i;
      const speed = 2 + Math.random() * 3;
      this.particles.push({
        x: x, y: y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 20 + Math.random() * 10,
        maxLife: 30,
        color: color,
        size: 4 + Math.random() * 4
      } as Particle);
    }
  }

  private nextLevel(): void {
    this.gameCurrentLevel += 1;
    this.gameLevelKills = 0;
    this.levelClearShown = false;
    this.gameStatus = 'playing';
  }

  private gameOver(): void {
    this.isGameOver = true;
    this.gameStatus = 'gameover';
    this.stopGameLoop();
    // Check for new record
    this.checkNewRecord();
    // Save distributed record
    if (this.dataSync) {
      const record: GameRecord = {
        highScore: this.gameScore,
        highestLevel: this.gameCurrentLevel,
        totalKills: this.calcTotalKills(),
        totalKillsLow: 0,
        totalKillsMid: 0,
        totalKillsHigh: 0,
        endlessBestScore: this.gameMode === 'endless' ? this.gameScore : 0
      };
      this.dataSync!.saveGameRecord(record);
    }
  }

  private async checkNewRecord(): Promise<void> {
    if (!this.dataSync) return;
    const record = await this.dataSync.loadGameRecord();
    if (this.gameScore > record.highScore) {
      this.isNewRecord = true;
    }
  }

  private restart(): void {
    this.isGameOver = false;
    this.isPaused = false;
    this.isNewRecord = false;
    this.gameScore = 0;
    this.gamePlayerHP = PLAYER_HP;
    this.gameCurrentLevel = 1;
    this.gameLevelKills = 0;
    this.gameStatus = 'playing';
    this.levelClearShown = false;
    this.playerX = this.canvasWidth / 2;
    this.playerY = this.canvasHeight - 80;
    this.bullets = [];
    this.enemies = [];
    this.particles = [];
    this.gameInvincible = false;
    this.lastSpawnTime = 0;
    this.syncToStorage();
    this.startGameLoop();
  }

  private fire(): void {
    const now = Date.now();
    if (now - this.lastFireTime < FIRE_COOLDOWN) return;
    this.lastFireTime = now;
    this.bullets.push({
      x: this.playerX,
      y: this.playerY - PLAYER_SIZE / 2,
      active: true
    } as Bullet);
  }

  private syncToStorage(): void {
    this.gamePlayerX = this.playerX;
    this.gamePlayerY = this.playerY;
    this.gameEnemies = JSON.stringify(this.enemies.map(e => ({
      x: e.x, y: e.y, hp: e.hp, maxHp: e.maxHp,
      atk: e.atk, size: e.size, type: e.type,
      color: e.color, speed: e.speed, score: e.score, active: e.active
    } as EnemyData)));
    this.gameBullets = JSON.stringify(this.bullets.map(b => ({
      x: b.x, y: b.y, active: b.active
    } as BulletData)));
  }

  private parseEnemies(json: string): Enemy[] {
    try {
      const arr = JSON.parse(json) as EnemyData[];
      return arr.map((item: EnemyData) => ({
        x: item.x as number, y: item.y as number,
        hp: item.hp as number, maxHp: item.maxHp as number,
        atk: item.atk as number, size: item.size as number,
        type: item.type as 'low' | 'mid' | 'high',
        color: item.color as number, speed: item.speed as number,
        score: item.score as number, active: item.active as boolean
      } as Enemy));
    } catch {
      return [];
    }
  }

  private parseBullets(json: string): Bullet[] {
    try {
      const arr = JSON.parse(json) as BulletData[];
      return arr.map((item: BulletData) => ({
        x: item.x as number, y: item.y as number,
        active: item.active as boolean
      } as Bullet));
    } catch {
      return [];
    }
  }

  // ---- Drawing ----
  private draw(): void {
    if (!this.canvasCtx) return;
    const ctx = this.canvasCtx;
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    this.drawBackground(ctx);
    this.drawParticles(ctx);
    this.drawBullets(ctx);
    this.drawPlayer(ctx);
    this.drawEnemies(ctx);
    this.drawHUD(ctx);

    // Level clear overlay
    if (this.gameStatus === 'levelClear') {
      this.drawLevelClearOverlay(ctx);
    }
  }

  private drawBackground(ctx: CanvasRenderingContext2D): void {
    // Draw starfield background
    ctx.fillStyle = '#0a0a2e';
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
    // Simple stars
    const seed = 42;
    for (let i = 0; i < 30; i++) {
      const sx = ((seed * (i + 1) * 137) % this.canvasWidth);
      const sy = ((seed * (i + 1) * 89 + Date.now() * 0.02) % this.canvasHeight);
      const brightness = 100 + ((seed * (i + 1) * 53) % 155);
      ctx.fillStyle = `rgb(${brightness},${brightness},255)`;
      ctx.beginPath();
      ctx.arc(sx, sy, 1 + ((seed * (i + 1) * 7) % 2), 0, Math.PI * 2);
      ctx.fill();
    }
  }

  private drawPlayer(ctx: CanvasRenderingContext2D): void {
    if (this.gameInvincible && Math.floor(Date.now() / 100) % 2 === 0) return; // Blinking effect

    const x = this.playerX;
    const y = this.playerY;
    const size = PLAYER_SIZE;

    ctx.save();
    // Body (triangle)
    ctx.fillStyle = '#2196F3';
    ctx.beginPath();
    ctx.moveTo(x, y - size / 2);          // Top
    ctx.lineTo(x - size / 2, y + size / 2); // Bottom left
    ctx.lineTo(x - size / 4, y + size / 4);
    ctx.lineTo(x, y + size / 3);           // Bottom center indent
    ctx.lineTo(x + size / 4, y + size / 4);
    ctx.lineTo(x + size / 2, y + size / 2); // Bottom right
    ctx.closePath();
    ctx.fill();
    // Cockpit
    ctx.fillStyle = '#64B5F6';
    ctx.beginPath();
    ctx.arc(x, y - size / 6, size / 6, 0, Math.PI * 2);
    ctx.fill();
    // Wings glow
    ctx.fillStyle = 'rgba(33, 150, 243, 0.3)';
    ctx.beginPath();
    ctx.ellipse(x - size / 2.5, y + size / 4, size / 4, size / 8, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.beginPath();
    ctx.ellipse(x + size / 2.5, y + size / 4, size / 4, size / 8, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  private drawEnemies(ctx: CanvasRenderingContext2D): void {
    for (let e of this.enemies) {
      if (!e.active) continue;
      ctx.save();
      const colorStr = '#' + e.color.toString(16).padStart(6, '0');
      ctx.fillStyle = colorStr;

      if (e.type === 'low') {
        // Circle
        ctx.beginPath();
        ctx.arc(e.x, e.y, e.size / 2, 0, Math.PI * 2);
        ctx.fill();
        // Eyes
        ctx.fillStyle = '#fff';
        ctx.beginPath();
        ctx.arc(e.x - e.size / 5, e.y - e.size / 6, e.size / 10, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(e.x + e.size / 5, e.y - e.size / 6, e.size / 10, 0, Math.PI * 2);
        ctx.fill();
      } else if (e.type === 'mid') {
        // Diamond
        ctx.beginPath();
        ctx.moveTo(e.x, e.y - e.size / 2);
        ctx.lineTo(e.x + e.size / 2, e.y);
        ctx.lineTo(e.x, e.y + e.size / 2);
        ctx.lineTo(e.x - e.size / 2, e.y);
        ctx.closePath();
        ctx.fill();
        // Inner
        ctx.fillStyle = '#fff';
        ctx.beginPath();
        ctx.arc(e.x, e.y, e.size / 6, 0, Math.PI * 2);
        ctx.fill();
      } else {
        // Triangle (advanced)
        ctx.beginPath();
        ctx.moveTo(e.x, e.y - e.size / 2);
        ctx.lineTo(e.x + e.size / 2, e.y + e.size / 2);
        ctx.lineTo(e.x - e.size / 2, e.y + e.size / 2);
        ctx.closePath();
        ctx.fill();
        // Inner glow
        ctx.fillStyle = 'rgba(255,255,255,0.3)';
        ctx.beginPath();
        ctx.arc(e.x, e.y, e.size / 5, 0, Math.PI * 2);
        ctx.fill();
      }

      // HP bar
      if (e.hp < e.maxHp) {
        const barWidth = e.size;
        const barHeight = 4;
        const barX = e.x - barWidth / 2;
        const barY = e.y - e.size / 2 - 8;
        ctx.fillStyle = 'rgba(255,0,0,0.5)';
        ctx.fillRect(barX, barY, barWidth, barHeight);
        ctx.fillStyle = '#4CAF50';
        ctx.fillRect(barX, barY, barWidth * (e.hp / e.maxHp), barHeight);
      }
      ctx.restore();
    }
  }

  private drawBullets(ctx: CanvasRenderingContext2D): void {
    ctx.save();
    for (let b of this.bullets) {
      if (!b.active) continue;
      // Bullet glow
      const gradient = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, BULLET_SIZE);
      gradient.addColorStop(0, '#FFFFFF');
      gradient.addColorStop(0.5, '#64B5F6');
      gradient.addColorStop(1, 'rgba(100,181,246,0)');
      ctx.fillStyle = gradient;
      ctx.beginPath();
      ctx.arc(b.x, b.y, BULLET_SIZE, 0, Math.PI * 2);
      ctx.fill();
      // Core
      ctx.fillStyle = '#FFFFFF';
      ctx.beginPath();
      ctx.arc(b.x, b.y, BULLET_SIZE / 2, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.restore();
  }

  private drawParticles(ctx: CanvasRenderingContext2D): void {
    for (let p of this.particles) {
      const alpha = p.life / p.maxLife;
      const colorStr = '#' + p.color.toString(16).padStart(6, '0');
      ctx.globalAlpha = alpha;
      ctx.fillStyle = colorStr;
      ctx.beginPath();
      ctx.arc(p.x, p.y, Math.max(1, p.size), 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  }

  private drawHUD(ctx: CanvasRenderingContext2D): void {
    ctx.save();
    ctx.font = '18px sans-serif';

    // HP
    ctx.fillStyle = '#FF5252';
    ctx.fillText('❤️ ' + this.gamePlayerHP, 16, 36);

    // Score
    ctx.fillStyle = '#FFFFFF';
    ctx.textAlign = 'right';
    ctx.fillText('⭐ ' + this.gameScore, this.canvasWidth - 16, 36);

    // Level info (level mode)
    if (this.gameMode === 'level') {
      ctx.textAlign = 'left';
      ctx.fillStyle = '#FFD740';
      ctx.font = '14px sans-serif';
      ctx.fillText('🎯 第' + this.gameCurrentLevel + '关', 16, 60);

      // Progress bar
      const barX = 16;
      const barY = 70;
      const barW = Math.min(200, this.canvasWidth - 32);
      const barH = 8;
      const progress = this.gameLevelKills / this.gameLevelTarget;
      ctx.fillStyle = 'rgba(255,255,255,0.2)';
      ctx.roundRect(barX, barY, barW, barH, 4);
      ctx.fill();
      ctx.fillStyle = '#FFD740';
      ctx.roundRect(barX, barY, barW * Math.min(1, progress), barH, 4);
      ctx.fill();
      ctx.fillStyle = '#FFFFFF';
      ctx.font = '11px sans-serif';
      ctx.textAlign = 'left';
      ctx.fillText(this.gameLevelKills + '/' + this.gameLevelTarget, barX + 4, barY + barH - 1);
    }

    // Game Over overlay
    if (this.isGameOver) {
      this.drawGameOverOverlay(ctx);
    }

    ctx.restore();
  }

  private drawGameOverOverlay(ctx: CanvasRenderingContext2D): void {
    ctx.save();
    // Semi-transparent background
    ctx.fillStyle = 'rgba(0,0,0,0.7)';
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    ctx.textAlign = 'center';
    // Title
    ctx.fillStyle = '#FF5252';
    ctx.font = 'bold 48px sans-serif';
    ctx.fillText('💥 GAME OVER', this.canvasWidth / 2, this.canvasHeight / 2 - 80);

    // Score
    ctx.fillStyle = '#FFFFFF';
    ctx.font = '28px sans-serif';
    ctx.fillText('最终得分: ' + this.gameScore, this.canvasWidth / 2, this.canvasHeight / 2 - 20);

    // Mode info
    ctx.font = '18px sans-serif';
    ctx.fillStyle = '#FFD740';
    if (this.gameMode === 'level') {
      ctx.fillText('到达关卡: 第' + this.gameCurrentLevel + '关', this.canvasWidth / 2, this.canvasHeight / 2 + 20);
    }

    // New record badge
    if (this.isNewRecord) {
      ctx.fillStyle = '#FFD740';
      ctx.font = 'bold 24px sans-serif';
      ctx.fillText('🎉 新纪录！', this.canvasWidth / 2, this.canvasHeight / 2 + 60);
    }

    // Restart hint
    ctx.fillStyle = 'rgba(255,255,255,0.5)';
    ctx.font = '16px sans-serif';
    ctx.fillText('点击「重新开始」按钮继续', this.canvasWidth / 2, this.canvasHeight / 2 + 110);

    ctx.restore();
  }

  private drawLevelClearOverlay(ctx: CanvasRenderingContext2D): void {
    ctx.save();
    ctx.fillStyle = 'rgba(0,0,0,0.4)';
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
    ctx.textAlign = 'center';
    ctx.fillStyle = '#FFD740';
    ctx.font = 'bold 40px sans-serif';
    ctx.fillText('🎉 第' + this.gameCurrentLevel + '关通过！', this.canvasWidth / 2, this.canvasHeight / 2);
    ctx.fillStyle = '#FFFFFF';
    ctx.font = '20px sans-serif';
    ctx.fillText('准备进入下一关...', this.canvasWidth / 2, this.canvasHeight / 2 + 50);
    ctx.restore();
  }

  // ---- Touch/Gesture Handlers ----
  private onTouchMove(event: TouchEvent): void {
    if (this.isPaused || this.isGameOver) return;
    const touches = event.touches;
    if (touches.length > 0) {
      const touch = touches[0];
      this.playerX = Math.max(PLAYER_SIZE / 2, Math.min(this.canvasWidth - PLAYER_SIZE / 2, touch.x));
      this.playerY = Math.max(PLAYER_SIZE / 2, Math.min(this.canvasHeight - PLAYER_SIZE / 2, touch.y));
    }
  }

  private onTouchDown(event: TouchEvent): void {
    if (this.isPaused || this.isGameOver) return;
    this.fire();
  }

  private togglePause(): void {
    this.isPaused = !this.isPaused;
    this.gameStatus = this.isPaused ? 'paused' : 'playing';
  }

  @Consume navPathStack: NavPathStack;

  private exitGame(): void {
    this.stopGameLoop();
    if (this.invincibleTimer !== -1) {
      clearTimeout(this.invincibleTimer);
    }
    if (this.levelClearTimer !== -1) {
      clearTimeout(this.levelClearTimer);
    }
    this.navPathStack.pop();
  }

  build() {
    NavDestination() {
      Stack() {
        // Game Canvas
        Canvas(this.canvasCtx)
          .width('100%')
          .height('100%')
          .onReady(() => {
            this.onCanvasReady();
          })
          .onAreaChange((oldVal: Area, newVal: Area) => {
            this.onCanvasAreaChange(oldVal, newVal);
          })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Move) {
              this.onTouchMove(event);
            } else if (event.type === TouchType.Down) {
              this.onTouchDown(event);
            }
          })

        // Top bar — positioned at top, doesn't block game area
        Row() {
          // Pause button
          Button() {
            Text(this.isPaused ? '▶' : '⏸')
              .fontSize(20)
              .fontColor(Color.White)
          }
          .width(44)
          .height(44)
          .backgroundColor('rgba(0,0,0,0.4)')
          .borderRadius(22)
          .onClick(() => {
            this.togglePause();
          })

          Blank()

          // Exit button
          Button() {
            Text('✕')
              .fontSize(20)
              .fontColor(Color.White)
          }
          .width(44)
          .height(44)
          .backgroundColor('rgba(0,0,0,0.4)')
          .borderRadius(22)
          .onClick(() => {
            this.exitGame();
          })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8 })
        .position({ x: 0, y: 0 })
        .zIndex(1)

        // Pause overlay — full screen, centered
        if (this.isPaused && !this.isGameOver) {
          Column() {
            Text('⏸ 已暂停')
              .fontSize(36)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)

            Button() {
              Text('继续游戏')
                .fontSize(20)
                .fontColor(Color.White)
            }
            .width(180)
            .height(52)
            .backgroundColor('#2196F3')
            .borderRadius(26)
            .margin({ top: 20 })
            .onClick(() => {
              this.togglePause();
            })

            Button() {
              Text('退出游戏')
                .fontSize(18)
                .fontColor(Color.White)
            }
            .width(160)
            .height(44)
            .backgroundColor('rgba(255,255,255,0.2)')
            .borderRadius(22)
            .margin({ top: 12 })
            .onClick(() => {
              this.exitGame();
            })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.6)')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .zIndex(10)
        }

        // Game Over buttons — at bottom
        if (this.isGameOver) {
          Column() {
            Row() {
              Button() {
                Text('🔄 重新开始')
                  .fontSize(18)
                  .fontColor(Color.White)
              }
              .width(140)
              .height(48)
              .backgroundColor('#4CAF50')
              .borderRadius(24)
              .onClick(() => {
                this.restart();
              })

              Button() {
                Text('🚪 退出')
                  .fontSize(18)
                  .fontColor(Color.White)
              }
              .width(120)
              .height(48)
              .backgroundColor('rgba(255,255,255,0.2)')
              .borderRadius(24)
              .margin({ left: 16 })
              .onClick(() => {
                this.exitGame();
              })
            }
            .margin({ bottom: 60 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.End)
          .alignItems(HorizontalAlign.Center)
          .zIndex(10)
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .backgroundColor('#0a0a2e')
    .onBackPressed(() => {
      this.exitGame();
      return true;
    })
  }
}
