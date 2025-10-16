# ==============================
# 🏗️ 第一阶段：构建 jar 包
# ==============================
FROM gradle:8.10.0-jdk17 AS builder

WORKDIR /app

# 只复制 gradle 配置文件（提升缓存命中率）
COPY build.gradle settings.gradle gradlew ./
COPY gradle gradle
RUN ./gradlew --version

# 再复制源码
COPY src src

# 构建 jar
RUN ./gradlew clean build -x test

# ==============================
# 🚀 第二阶段：运行应用
# ==============================
FROM eclipse-temurin:17-jre-focal

WORKDIR /app

# 从 builder 阶段复制 jar 文件
COPY --from=builder /app/build/libs/*.jar app.jar

# 环境变量
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8

EXPOSE 8080

# 安全：非 root 用户
RUN adduser --disabled-password appuser
USER appuser

ENTRYPOINT ["java", "-jar", "app.jar"]
