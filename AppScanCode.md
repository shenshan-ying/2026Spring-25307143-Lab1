项目根目录/
├── AppScope/                 # 🌐 应用级全局配置
│   ├── app.json5             # 应用元数据（包名/版本/图标/设备兼容性）
│   └── resources/            # 全局资源（多语言/图片/样式），多模块共享
│       ├── base/             # 默认资源（字符串/布局/图片）
│       └── en_US/            # 多语言资源目录（按区域划分）
│
├── entry/                    # 🚪 主入口模块（HAP包核心）
│   ├── src/main/
│   │   ├── ets/              # 🧠 ArkTS核心代码区
│   │   │   ├── entryability/ # 应用入口Ability（生命周期管理）
│   │   │   ├── pages/        # 页面组件（每个.ets文件对应一个UI页面）
│   │   │   ├── components/   # 可复用UI组件（自定义按钮/卡片等）
│   │   │   ├── model/        # 数据模型（定义数据结构/实体类）
│   │   │   ├── services/     # 业务逻辑层（网络请求/数据处理）
│   │   │   ├── database/     # 数据库操作（可选，存放DAO类）
│   │   │   └── common/       # 公共工具（路由/存储/常量等Utils）
│   │   ├── resources/        # 模块专属资源（仅本模块使用）
│   │   └── module.json5      # 模块配置（声明Ability/页面路由/权限）
│   └── oh-package.json5      # 模块依赖管理（三方库声明）
│
├── feature/                  # 🧩 功能模块（可选，扩展独立功能）
│   └── ...                   # 结构与entry类似，按需创建
│
├── oh_modules/               # 📦 三方依赖库（由ohpm自动生成）
├── build-profile.json5       # ⚙️ 工程级构建配置（SDK版本/编译选项）
├── hvigorfile.ts             # 🛠️ 工程级构建脚本（自定义任务）
└── oh-package.json5          # 🔗 全局依赖管理（声明所有模块共用依赖）