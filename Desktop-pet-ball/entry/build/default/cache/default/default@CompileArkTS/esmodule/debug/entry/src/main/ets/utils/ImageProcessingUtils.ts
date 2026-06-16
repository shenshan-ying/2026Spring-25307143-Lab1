import image from "@ohos:multimedia.image";
interface ProcessResult {
    pixelMap: image.PixelMap;
    imageData: ArrayBuffer;
}
export class ImageProcessingUtils {
    static readonly TARGET_DIAMETER: number = 120;
    static readonly TARGET_QUALITY: number = 80;
    static readonly MAX_FILE_SIZE: number = 500 * 1024;
    static async cropToCircle(imageSource: image.ImageSource, centerX: number, centerY: number, radius: number): Promise<image.PixelMap | null> {
        try {
            const imageInfo = await imageSource.getImageInfo();
            const width = imageInfo.size.width;
            const height = imageInfo.size.height;
            const croppingPixelMap = await imageSource.createPixelMap({
                desiredSize: {
                    width: width,
                    height: height
                }
            });
            const size = radius * 2;
            const targetPixelMap = await image.createPixelMap(new ArrayBuffer(size * size * 4), {
                size: { width: size, height: size },
                pixelFormat: image.PixelMapFormat.RGBA_8888,
                editable: true
            });
            // 读取源图像像素数据
            const srcBuffer = new ArrayBuffer(width * height * 4);
            await croppingPixelMap.readPixelsToBuffer(srcBuffer);
            const srcData = new Uint8Array(srcBuffer);
            // 创建目标像素数据
            const destBuffer = new ArrayBuffer(size * size * 4);
            const destData = new Uint8Array(destBuffer);
            for (let y = 0; y < size; y++) {
                for (let x = 0; x < size; x++) {
                    const dx = x - radius;
                    const dy = y - radius;
                    const distance = Math.sqrt(dx * dx + dy * dy);
                    if (distance <= radius) {
                        const srcX = Math.floor(centerX - radius + x);
                        const srcY = Math.floor(centerY - radius + y);
                        if (srcX >= 0 && srcX < width && srcY >= 0 && srcY < height) {
                            const srcIdx = (srcY * width + srcX) * 4;
                            const destIdx = (y * size + x) * 4;
                            destData[destIdx] = srcData[srcIdx];
                            destData[destIdx + 1] = srcData[srcIdx + 1];
                            destData[destIdx + 2] = srcData[srcIdx + 2];
                            destData[destIdx + 3] = srcData[srcIdx + 3];
                        }
                    }
                }
            }
            await targetPixelMap.writeBufferToPixels(destBuffer);
            return targetPixelMap;
        }
        catch (error) {
            console.error('Crop to circle failed:', error);
            return null;
        }
    }
    static async resizeImage(pixelMap: image.PixelMap, targetWidth: number, targetHeight: number): Promise<image.PixelMap | null> {
        try {
            const imageInfo = await pixelMap.getImageInfo();
            const width = imageInfo.size.width;
            const height = imageInfo.size.height;
            const scaleX = targetWidth / width;
            const scaleY = targetHeight / height;
            const scaledPixelMap = await image.createPixelMap(new ArrayBuffer(targetWidth * targetHeight * 4), {
                size: { width: targetWidth, height: targetHeight },
                pixelFormat: image.PixelMapFormat.RGBA_8888,
                editable: true
            });
            // 读取源图像像素数据
            const srcBuffer = new ArrayBuffer(width * height * 4);
            await pixelMap.readPixelsToBuffer(srcBuffer);
            const srcData = new Uint8Array(srcBuffer);
            // 创建目标像素数据
            const destBuffer = new ArrayBuffer(targetWidth * targetHeight * 4);
            const destData = new Uint8Array(destBuffer);
            for (let y = 0; y < targetHeight; y++) {
                for (let x = 0; x < targetWidth; x++) {
                    const srcX = Math.floor(x / scaleX);
                    const srcY = Math.floor(y / scaleY);
                    const srcIdx = (srcY * width + srcX) * 4;
                    const destIdx = (y * targetWidth + x) * 4;
                    destData[destIdx] = srcData[srcIdx];
                    destData[destIdx + 1] = srcData[srcIdx + 1];
                    destData[destIdx + 2] = srcData[srcIdx + 2];
                    destData[destIdx + 3] = srcData[srcIdx + 3];
                }
            }
            await scaledPixelMap.writeBufferToPixels(destBuffer);
            return scaledPixelMap;
        }
        catch (error) {
            console.error('Resize image failed:', error);
            return null;
        }
    }
    static async compressImage(pixelMap: image.PixelMap, quality: number = ImageProcessingUtils.TARGET_QUALITY): Promise<ArrayBuffer | null> {
        try {
            const imagePackerApi = image.createImagePacker();
            const packOpts: image.PackingOption = {
                format: 'image/jpeg',
                quality: quality
            };
            const data = await imagePackerApi.packing(pixelMap, packOpts);
            imagePackerApi.release();
            return data;
        }
        catch (error) {
            console.error('Compress image failed:', error);
            return null;
        }
    }
    static async convertToPNG(pixelMap: image.PixelMap): Promise<ArrayBuffer | null> {
        try {
            const imagePackerApi = image.createImagePacker();
            const packOpts: image.PackingOption = {
                format: 'image/png',
                quality: 100
            };
            const data = await imagePackerApi.packing(pixelMap, packOpts);
            imagePackerApi.release();
            return data;
        }
        catch (error) {
            console.error('Convert to PNG failed:', error);
            return null;
        }
    }
    static async processCustomPetBall(imageSource: image.ImageSource): Promise<ProcessResult | null> {
        try {
            const imageInfo = await imageSource.getImageInfo();
            const width = imageInfo.size.width;
            const height = imageInfo.size.height;
            const centerX = width / 2;
            const centerY = height / 2;
            const radius = Math.min(width, height) / 2;
            const croppedPixelMap = await ImageProcessingUtils.cropToCircle(imageSource, centerX, centerY, radius);
            if (!croppedPixelMap) {
                return null;
            }
            const resizedPixelMap = await ImageProcessingUtils.resizeImage(croppedPixelMap, ImageProcessingUtils.TARGET_DIAMETER, ImageProcessingUtils.TARGET_DIAMETER);
            if (!resizedPixelMap) {
                return null;
            }
            const imageData = await ImageProcessingUtils.convertToPNG(resizedPixelMap);
            if (!imageData) {
                return null;
            }
            if (imageData.byteLength > ImageProcessingUtils.MAX_FILE_SIZE) {
                const compressedData = await ImageProcessingUtils.compressImage(resizedPixelMap, ImageProcessingUtils.TARGET_QUALITY);
                if (compressedData && compressedData.byteLength <= ImageProcessingUtils.MAX_FILE_SIZE) {
                    const result: ProcessResult = {
                        pixelMap: resizedPixelMap,
                        imageData: compressedData
                    };
                    return result;
                }
            }
            const result: ProcessResult = {
                pixelMap: resizedPixelMap,
                imageData: imageData
            };
            return result;
        }
        catch (error) {
            console.error('Process custom pet ball failed:', error);
            return null;
        }
    }
    static async processCustomPetBallFromPixelMap(pixelMap: image.PixelMap): Promise<ProcessResult | null> {
        try {
            const imageInfo = await pixelMap.getImageInfo();
            const width = imageInfo.size.width;
            const height = imageInfo.size.height;
            const centerX = width / 2;
            const centerY = height / 2;
            const radius = Math.min(width, height) / 2;
            // 直接从 PixelMap 裁剪圆形
            const size = radius * 2;
            const targetPixelMap = await image.createPixelMap(new ArrayBuffer(size * size * 4), {
                size: { width: size, height: size },
                pixelFormat: image.PixelMapFormat.RGBA_8888,
                editable: true
            });
            const srcBuffer = new ArrayBuffer(width * height * 4);
            await pixelMap.readPixelsToBuffer(srcBuffer);
            const srcData = new Uint8Array(srcBuffer);
            const destBuffer = new ArrayBuffer(size * size * 4);
            const destData = new Uint8Array(destBuffer);
            for (let y = 0; y < size; y++) {
                for (let x = 0; x < size; x++) {
                    const dx = x - radius;
                    const dy = y - radius;
                    const distance = Math.sqrt(dx * dx + dy * dy);
                    if (distance <= radius) {
                        const srcX = Math.floor(centerX - radius + x);
                        const srcY = Math.floor(centerY - radius + y);
                        if (srcX >= 0 && srcX < width && srcY >= 0 && srcY < height) {
                            const srcIdx = (srcY * width + srcX) * 4;
                            const destIdx = (y * size + x) * 4;
                            destData[destIdx] = srcData[srcIdx];
                            destData[destIdx + 1] = srcData[srcIdx + 1];
                            destData[destIdx + 2] = srcData[srcIdx + 2];
                            destData[destIdx + 3] = srcData[srcIdx + 3];
                        }
                    }
                }
            }
            await targetPixelMap.writeBufferToPixels(destBuffer);
            const resizedPixelMap = await ImageProcessingUtils.resizeImage(targetPixelMap, ImageProcessingUtils.TARGET_DIAMETER, ImageProcessingUtils.TARGET_DIAMETER);
            if (!resizedPixelMap) {
                return null;
            }
            const imageData = await ImageProcessingUtils.convertToPNG(resizedPixelMap);
            if (!imageData) {
                return null;
            }
            const result: ProcessResult = {
                pixelMap: resizedPixelMap,
                imageData: imageData
            };
            return result;
        }
        catch (error) {
            console.error('Process custom pet ball from PixelMap failed:', error);
            return null;
        }
    }
}
