import { PetBallResource } from '../dao/DataModels';

export interface AnimationFrame {
  duration: number;
  transform?: string;
  opacity?: number;
}

export class InteractionAnimationPlayer {
  private currentAnimation: AnimationFrame[] = [];
  private animationIndex: number = 0;
  private isPlaying: boolean = false;
  private animationTimer: number = -1;

  private readonly ANIMATIONS: Record<string, AnimationFrame[]> = {
    'head_rub': [
      { duration: 200, transform: 'rotate(-10deg)' },
      { duration: 200, transform: 'rotate(10deg)' },
      { duration: 200, transform: 'rotate(-10deg)' },
      { duration: 200, transform: 'rotate(0deg)' }
    ],
    'tongue_out': [
      { duration: 300, transform: 'scale(1.1)' },
      { duration: 500, transform: 'scale(1.0)' }
    ],
    'wing_extend': [
      { duration: 300, transform: 'scaleX(1.2)' },
      { duration: 400, transform: 'scaleX(1.0)' }
    ],
    'collision': [
      { duration: 100, transform: 'scale(0.9)' },
      { duration: 100, transform: 'scale(1.1)' },
      { duration: 100, transform: 'scale(1.0)' }
    ]
  };

  playAnimation(animalType: 'cat' | 'dog' | 'bird'): Promise<void> {
    return new Promise((resolve) => {
      let animationType: string;
      
      switch (animalType) {
        case 'cat':
          animationType = 'head_rub';
          break;
        case 'dog':
          animationType = 'tongue_out';
          break;
        case 'bird':
          animationType = 'wing_extend';
          break;
        default:
          animationType = 'head_rub';
      }

      this.play(animationType, resolve);
    });
  }

  playCollisionAnimation(): Promise<void> {
    return new Promise((resolve) => {
      this.play('collision', resolve);
    });
  }

  private play(animationType: string, onComplete: () => void): void {
    if (this.isPlaying) {
      return;
    }

    const animation = this.ANIMATIONS[animationType];
    if (!animation) {
      onComplete();
      return;
    }

    this.currentAnimation = animation;
    this.animationIndex = 0;
    this.isPlaying = true;

    this.playNextFrame(onComplete);
  }

  private playNextFrame(onComplete: () => void): void {
    if (this.animationIndex >= this.currentAnimation.length) {
      this.isPlaying = false;
      onComplete();
      return;
    }

    const frame = this.currentAnimation[this.animationIndex];
    this.animationIndex++;

    this.animationTimer = setTimeout(() => {
      this.playNextFrame(onComplete);
    }, frame.duration);
  }

  stop(): void {
    if (this.animationTimer !== -1) {
      clearTimeout(this.animationTimer);
      this.animationTimer = -1;
    }
    
    this.isPlaying = false;
    this.currentAnimation = [];
    this.animationIndex = 0;
  }

  isAnimationPlaying(): boolean {
    return this.isPlaying;
  }

  getCurrentFrame(): AnimationFrame | null {
    if (!this.isPlaying || this.animationIndex === 0) {
      return null;
    }
    
    return this.currentAnimation[this.animationIndex - 1];
  }
}