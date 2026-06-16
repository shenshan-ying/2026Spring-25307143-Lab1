# 签名证书配置说明

## 生成签名证书

### 方法1：使用DevEco Studio自动生成
1. 打开DevEco Studio
2. 进入项目设置：File > Project Structure > Project > Signing Configs
3. 点击"Sign In"使用华为开发者账号登录
4. 点击"Automatically generate signature"自动生成签名
5. 保存生成的证书文件到本目录

### 方法2：手动生成签名证书
1. 访问华为开发者联盟官网：https://developer.huawei.com/consumer/cn/
2. 登录华为开发者账号
3. 进入"我的项目" > "应用签名"
4. 创建新的应用签名证书
5. 下载生成的证书文件到本目录：
   - `.p7b` 文件（证书文件）
   - `.p12` 文件（密钥库文件）
   - `keystore.txt` 文件（包含密码信息）

## 证书文件命名
请将下载的证书文件重命名为：
- 证书文件：`desktop-pet-ball.p7b`
- 密钥库文件：`desktop-pet-ball.p12`

## 密码配置
在 `build-profile.json5` 文件中配置正确的密码：
- `storePassword`: 密钥库密码
- `keyPassword`: 密钥密码

## 注意事项
1. 请妥善保管证书文件和密码，不要泄露
2. 正式发布应用时需要使用正式的发布证书
3. 调试阶段可以使用调试证书
4. 证书过期后需要重新生成

## 调试证书（可选）
对于调试目的，可以使用以下命令生成自签名证书：
```bash
# 生成密钥库
keytool -genkeypair -alias desktop-pet-ball -keyalg EC -keysize 256 -validity 365 -keystore desktop-pet-ball.p12 -storetype PKCS12 -storepass 123456 -keypass 123456

# 导出证书
keytool -exportcert -alias desktop-pet-ball -keystore desktop-pet-ball.p12 -storepass 123456 -file desktop-pet-ball.p7b
```

## 常见问题
1. **证书无效**：确保证书文件路径正确且文件存在
2. **密码错误**：检查storePassword和keyPassword是否正确
3. **证书过期**：重新生成证书并更新配置
4. **权限问题**：确保证书文件有正确的读取权限