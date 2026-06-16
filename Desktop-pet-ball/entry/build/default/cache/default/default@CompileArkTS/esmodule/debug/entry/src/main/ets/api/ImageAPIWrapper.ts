import camera from "@ohos:multimedia.camera";
import image from "@ohos:multimedia.image";
import photoAccessHelper from "@ohos:file.photoAccessHelper";
import type common from "@ohos:app.ability.common";
import fs from "@ohos:file.fs";
export class ImageAPIWrapper {
    private context: common.Context | null = null;
    private cameraManager: camera.CameraManager | null = null;
    init(context: common.Context): void {
        this.context = context;
        this.initCameraManager();
    }
    private async initCameraManager(): Promise<void> {
        if (!this.context) {
            return;
        }
        try {
            this.cameraManager = camera.getCameraManager(this.context);
        }
        catch (error) {
            console.error('Init camera manager failed:', error);
        }
    }
    async openCamera(): Promise<camera.CameraInput | null> {
        if (!this.cameraManager) {
            console.error('Camera manager not initialized');
            return null;
        }
        try {
            const cameras = await this.cameraManager.getSupportedCameras();
            if (cameras.length === 0) {
                console.error('No camera available');
                return null;
            }
            const cameraInput = await this.cameraManager.createCameraInput(cameras[0]);
            await cameraInput.open();
            return cameraInput;
        }
        catch (error) {
            console.error('Open camera failed:', error);
            return null;
        }
    }
    async takePhoto(cameraInput: camera.CameraInput): Promise<image.PixelMap | null> {
        try {
            const photoCaptureSetting: camera.PhotoCaptureSetting = {
                quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
                rotation: camera.ImageRotation.ROTATION_0
            };
            const photoOutput = await this.createPhotoOutput();
            if (!photoOutput) {
                return null;
            }
            return new Promise((resolve) => {
                photoOutput.on('photoAvailable', async (err, photo) => {
                    if (err || !photo) {
                        console.error('Take photo failed:', err);
                        resolve(null);
                        return;
                    }
                    try {
                        // Camera Photo 的 main 属性是 Image 类型，无法直接转换为 PixelMap
                        // 对于模拟器环境，相机功能不可用，返回 null
                        console.warn('Camera photo PixelMap extraction not supported on this platform');
                        resolve(null);
                    }
                    catch (err) {
                        console.error('Failed to process photo:', err);
                        resolve(null);
                    }
                });
                photoOutput.capture(photoCaptureSetting);
            });
        }
        catch (error) {
            console.error('Take photo failed:', error);
            return null;
        }
    }
    private async createPhotoOutput(): Promise<camera.PhotoOutput | null> {
        return null;
    }
    async pickImageFromGallery(): Promise<image.ImageSource | null> {
        try {
            // 使用新的 photoAccessHelper API
            const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
            photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
            photoSelectOptions.maxSelectNumber = 1;
            const photoPicker = new photoAccessHelper.PhotoViewPicker();
            const photoSelectResult = await photoPicker.select(photoSelectOptions);
            if (photoSelectResult.photoUris.length === 0) {
                return null;
            }
            const uri = photoSelectResult.photoUris[0];
            // 通过文件描述符创建 ImageSource
            const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
            const imageSource = image.createImageSource(file.fd);
            fs.closeSync(file);
            return imageSource;
        }
        catch (error) {
            console.error('Pick image from gallery failed:', error);
            return null;
        }
    }
    async cropImage(imageSource: image.ImageSource, x: number, y: number, width: number, height: number): Promise<image.PixelMap | null> {
        try {
            const region: image.Region = {
                x: x,
                y: y,
                size: {
                    width: width,
                    height: height
                }
            };
            const decodingOptions: image.DecodingOptions = {
                desiredRegion: region
            };
            const pixelMap = await imageSource.createPixelMap(decodingOptions);
            return pixelMap;
        }
        catch (error) {
            console.error('Crop image failed:', error);
            return null;
        }
    }
    async scaleImage(pixelMap: image.PixelMap, targetWidth: number, targetHeight: number): Promise<boolean> {
        try {
            await pixelMap.scale(targetWidth / (await pixelMap.getImageInfo()).size.width, targetHeight / (await pixelMap.getImageInfo()).size.height);
            return true;
        }
        catch (error) {
            console.error('Scale image failed:', error);
            return false;
        }
    }
    async convertImageFormat(pixelMap: image.PixelMap, format: string = 'image/png'): Promise<ArrayBuffer | null> {
        try {
            const imagePackerApi = image.createImagePacker();
            const packOpts: image.PackingOption = {
                format: format,
                quality: 100
            };
            const data = await imagePackerApi.packing(pixelMap, packOpts);
            imagePackerApi.release();
            return data;
        }
        catch (error) {
            console.error('Convert image format failed:', error);
            return null;
        }
    }
    closeCamera(cameraInput: camera.CameraInput): void {
        try {
            cameraInput.close();
        }
        catch (error) {
            console.error('Close camera failed:', error);
        }
    }
}
