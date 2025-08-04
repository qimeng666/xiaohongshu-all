#!/bin/bash

# 小红书微服务架构部署脚本
# 版本: 1.0

set -e

echo "🚀 开始部署小红书微服务架构..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

# 停止并删除现有容器
echo "🔄 清理现有容器..."
docker-compose down -v

# 构建镜像
echo "🔨 构建微服务镜像..."
docker-compose build --no-cache

# 启动服务
echo "🚀 启动所有服务..."
docker-compose up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 30

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

# 检查健康状态
echo "🏥 检查服务健康状态..."
for service in mysql redis zookeeper kafka user-service note-service feed-service; do
    echo "检查 $service 服务..."
    if docker-compose exec -T $service curl -f http://localhost:8081/actuator/health 2>/dev/null || \
       docker-compose exec -T $service redis-cli ping 2>/dev/null || \
       docker-compose exec -T $service mysqladmin ping -h localhost 2>/dev/null || \
       docker-compose exec -T $service echo ruok | nc localhost 2181 2>/dev/null || \
       docker-compose exec -T $service kafka-topics --bootstrap-server localhost:9092 --list 2>/dev/null; then
        echo "✅ $service 服务运行正常"
    else
        echo "❌ $service 服务可能有问题"
    fi
done

echo "🎉 部署完成！"
echo ""
echo "📋 服务访问地址："
echo "  用户服务: http://localhost:8081"
echo "  笔记服务: http://localhost:8082"
echo "  Feed服务: http://localhost:8083"
echo "  MySQL: localhost:3306"
echo "  Redis: localhost:6379"
echo "  Kafka: localhost:9092"
echo ""
echo "📝 常用命令："
echo "  查看日志: docker-compose logs -f [服务名]"
echo "  停止服务: docker-compose down"
echo "  重启服务: docker-compose restart [服务名]"
echo "  查看状态: docker-compose ps" 