# 小红书微服务架构

基于 Spring Boot 的微服务架构项目，包含用户服务、笔记服务和 Feed 服务。

## 🏗️ 架构概览

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Service  │    │  Note Service   │    │  Feed Service   │
│   (Port: 8081)  │    │  (Port: 8082)   │    │  (Port: 8083)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     MySQL       │    │     Redis       │    │     Kafka       │
│   (Port: 3306)  │    │   (Port: 6379)  │    │   (Port: 9092)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 快速开始

### 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 4GB 可用内存
- 至少 10GB 可用磁盘空间

### 一键部署

```bash
# 克隆项目
git clone <repository-url>
cd xiaohongshu-all

# 运行部署脚本
chmod +x deploy.sh
./deploy.sh
```

### 手动部署

```bash
# 1. 构建并启动所有服务
docker-compose up -d

# 2. 查看服务状态
docker-compose ps

# 3. 查看服务日志
docker-compose logs -f [服务名]
```

## 📋 服务详情

### 微服务

| 服务名称     | 端口 | 描述         | 健康检查                              |
| ------------ | ---- | ------------ | ------------------------------------- |
| user-service | 8081 | 用户管理服务 | http://localhost:8081/actuator/health |
| note-service | 8082 | 笔记管理服务 | http://localhost:8082/actuator/health |
| feed-service | 8083 | Feed 流服务  | http://localhost:8083/actuator/health |

### 基础设施

| 服务名称  | 端口 | 描述         | 版本     |
| --------- | ---- | ------------ | -------- |
| MySQL     | 3306 | 主数据库     | 8.0      |
| Redis     | 6379 | 缓存数据库   | 7-alpine |
| Kafka     | 9092 | 消息队列     | 7.4.0    |
| Zookeeper | 2181 | Kafka 协调器 | 7.4.0    |

## 🗄️ 数据库设计

### 用户服务数据库 (user_service_db)

```sql
-- 用户表
users (id, username, email, password, nickname, avatar, bio, created_at, updated_at)

-- 关注关系表
follows (id, follower_id, following_id, created_at)
```

### 笔记服务数据库 (notes_db)

```sql
-- 笔记表
notes (id, user_id, title, content, images, tags, likes_count, comments_count, created_at, updated_at)

-- 标签表
tags (id, name, created_at)

-- 笔记标签关联表
note_tags (note_id, tag_id)
```

### Feed 服务数据库 (feed_db)

```sql
-- 用户Feed表
user_feeds (id, user_id, note_id, created_at)
```

## 🔧 配置说明

### 环境变量

所有服务都通过环境变量进行配置，主要配置项包括：

- `SPRING_DATASOURCE_URL`: 数据库连接 URL
- `SPRING_DATASOURCE_USERNAME`: 数据库用户名
- `SPRING_DATASOURCE_PASSWORD`: 数据库密码
- `SPRING_REDIS_HOST`: Redis 主机地址
- `SPRING_KAFKA_BOOTSTRAP_SERVERS`: Kafka 服务器地址
- `JWT_SECRET`: JWT 密钥
- `USER_SERVICE_URL`: 用户服务 URL
- `NOTE_SERVICE_URL`: 笔记服务 URL

### 网络配置

所有服务都在 `xiaohongshu-network` 网络中运行，服务间可以通过服务名相互访问。

## 📝 API 文档

### 用户服务 API

- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `GET /api/users/{id}` - 获取用户信息
- `POST /api/users/{id}/follow` - 关注用户
- `DELETE /api/users/{id}/follow` - 取消关注

### 笔记服务 API

- `POST /api/notes` - 创建笔记
- `GET /api/notes/{id}` - 获取笔记详情
- `GET /api/notes` - 获取笔记列表
- `PUT /api/notes/{id}` - 更新笔记
- `DELETE /api/notes/{id}` - 删除笔记
- `POST /api/tags` - 创建标签
- `GET /api/tags` - 获取标签列表

### Feed 服务 API

- `GET /api/feeds/{userId}` - 获取用户 Feed 流
- `POST /api/feeds/events` - 处理 Feed 事件

## 🛠️ 开发指南

### 本地开发

1. 确保 Docker 服务正在运行
2. 启动基础设施服务：
   ```bash
   docker-compose up mysql redis kafka -d
   ```
3. 在 IDE 中运行微服务应用

### 构建镜像

```bash
# 构建单个服务镜像
docker-compose build user-service

# 构建所有服务镜像
docker-compose build
```

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f user-service
```

## 🔍 故障排除

### 常见问题

1. **服务启动失败**

   ```bash
   # 检查服务状态
   docker-compose ps

   # 查看服务日志
   docker-compose logs [服务名]
   ```

2. **数据库连接失败**

   ```bash
   # 检查MySQL容器状态
   docker-compose exec mysql mysqladmin ping -h localhost
   ```

3. **Kafka 连接失败**
   ```bash
   # 检查Kafka容器状态
   docker-compose exec kafka kafka-topics --bootstrap-server localhost:9092 --list
   ```

### 清理环境

```bash
# 停止所有服务
docker-compose down

# 停止服务并删除数据卷
docker-compose down -v

# 删除所有镜像
docker-compose down --rmi all
```

## 📊 监控和健康检查

所有服务都配置了健康检查端点：

- 用户服务: `http://localhost:8081/actuator/health`
- 笔记服务: `http://localhost:8082/actuator/health`
- Feed 服务: `http://localhost:8083/actuator/health`

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue
- 发送邮件至 [your-email@example.com]

---

**注意**: 这是一个演示项目，生产环境部署前请确保：

- 修改默认密码
- 配置适当的网络安全策略
- 设置数据备份策略
- 配置监控和告警系统
