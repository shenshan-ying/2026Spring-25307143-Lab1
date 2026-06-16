import { ImageAPIWrapper } from '../api/ImageAPIWrapper';
import { ImageProcessingUtils } from '../utils/ImageProcessingUtils';
import image from '@ohos.multimedia.image';
import { common } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';

interface ProcessResult {
  pixelMap: image.PixelMap;
  imageData: ArrayBuffer;
}

export class ImageServiceAdapter {
  private imageAPI: ImageAPIWrapper;

  constructor() {
    this.imageAPI = new ImageAPIWrapper();
  }

  init(context: common.Context): void {
    this.imageAPI.init(context);
  }

  async takePhotoFromCamera(): Promise<ProcessResult | null> {
    try {
      const cameraInput = await this.imageAPI.openCamera();
      if (!cameraInput) {
        return null;
      }

      const pixelMap = await this.imageAPI.takePhoto(cameraInput);
      this.imageAPI.closeCamera(cameraInput);

      if (!pixelMap) {
        return null;
      }

      return await ImageProcessingUtils.processCustomPetBallFromPixelMap(pixelMap);
    } catch (error) {
      console.error('Take photo from camera failed:', error);
      return null;
    }
  }

  async pickImageFromGallery(): Promise<ProcessResult | null> {
    try {
      const imageSource = await this.imageAPI.pickImageFromGallery();
      if (!imageSource) {
        return null;
      }

      return await ImageProcessingUtils.processCustomPetBall(imageSource);
    } catch (error) {
      console.error('Pick image from gallery failed:', error);
      return null;
    }
  }

  async cropToCircle(
    imageSource: image.ImageSource,
    centerX: number,
    centerY: number,
    radius: number
  ): Promise<image.PixelMap | null> {
    return await ImageProcessingUtils.cropToCircle(imageSource, centerX, centerY, radius);
  }

  async resizeImage(
    pixelMap: image.PixelMap,
    targetWidth: number,
    targetHeight: number
  ): Promise<image.PixelMap | null> {
    return await ImageProcessingUtils.resizeImage(pixelMap, targetWidth, targetHeight);
  }

  async compressImage(
    pixelMap: image.PixelMap,
    quality: number = 80
  ): Promise<ArrayBuffer | null> {
    return await ImageProcessingUtils.compressImage(pixelMap, quality);
  }

  async convertToPNG(pixelMap: image.PixelMap): Promise<ArrayBuffer | null> {
    return await ImageProcessingUtils.convertToPNG(pixelMap);
  }
}
