# 阶段1：构建依赖
FROM python:3.12-slim as builder

WORKDIR /app
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 安装系统依赖（根据项目需求调整）
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc python3-dev && \
    rm -rf /var/lib/apt/lists/*

# 安装Python依赖（分层优化，利用Docker缓存）
COPY requirements.txt .
RUN pip install --user --no-warn-script-location -r requirements.txt

# ---

# 阶段2：生产镜像
FROM python:3.12-slim 

WORKDIR /app
# 从builder阶段复制已安装的Python包
COPY --from=builder /root/.local /root/.local
# 复制项目代码（通过.dockerignore过滤无关文件）
COPY . .

# 安全配置：使用非root用户
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# 环境变量
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    UVICORN_HOST=0.0.0.0 \
    UVICORN_PORT=8000

# 暴露端口
EXPOSE 8000

# 健康检查端点（需在FastAPI中实现/health）
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8000/health || exit 1

# 启动命令（推荐使用Uvicorn + Gunicorn组合）
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000", "--workers", "4", "app.main:app"]