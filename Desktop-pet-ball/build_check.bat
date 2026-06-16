@echo off
echo ========================================
echo 宠物球应用构建检查脚本
echo ========================================

echo.
echo 1. 检查项目结构...
if exist "entry\src\main\ets\pages\Index.ets" (
    echo   ✓ Index.ets 存在
) else (
    echo   ✗ Index.ets 不存在
)

if exist "entry\src\main\ets\pages\FloatWindowPage.ets" (
    echo   ✓ FloatWindowPage.ets 存在
) else (
    echo   ✗ FloatWindowPage.ets 不存在
)

if exist "entry\src\main\ets\entry\EntryAbility.ets" (
    echo   ✓ EntryAbility.ets 存在
) else (
    echo   ✗ EntryAbility.ets 不存在
)

echo.
echo 2. 检查配置文件...
if exist "entry\src\main\module.json5" (
    echo   ✓ module.json5 存在
) else (
    echo   ✗ module.json5 不存在
)

if exist "build-profile.json5" (
    echo   ✓ build-profile.json5 存在
) else (
    echo   ✗ build-profile.json5 不存在
)

echo.
echo 3. 检查依赖配置...
if exist "oh-package.json5" (
    echo   ✓ oh-package.json5 存在
) else (
    echo   ✗ oh-package.json5 不存在
)

echo.
echo 4. 检查权限配置...
findstr /C:"ohos.permission.SYSTEM_FLOAT_WINDOW" "entry\src\main\module.json5" >nul
if %errorlevel% equ 0 (
    echo   ✓ SYSTEM_FLOAT_WINDOW 权限已配置
) else (
    echo   ✗ SYSTEM_FLOAT_WINDOW 权限未配置
)

echo.
echo 5. 检查构建日志...
if exist ".hvigor\outputs\build-logs\build.log" (
    echo   ✓ 构建日志存在
    echo   最近构建时间:
    powershell -Command "(Get-Item '.hvigor\outputs\build-logs\build.log').LastWriteTime"
) else (
    echo   ✗ 构建日志不存在
)

echo.
echo ========================================
echo 检查完成
echo ========================================
echo.
echo 建议操作:
echo 1. 在 DevEco Studio 中打开项目
echo 2. 点击 "Sync Now" 同步项目
echo 3. 连接真机设备
echo 4. 点击运行按钮
echo 5. 查看控制台日志
echo.
echo 关键日志:
echo   - "Create float window failed" - 浮窗创建失败
echo   - "Fallback to in-window pet rendering" - 回退机制激活
echo   - "加载了 X 个宠物球" - 宠物球实例加载
echo   - "Show fallback overlay" - 回退渲染层显示
echo.
pause