# 安装指南

## 概述

本指南将帮助您在 Nginx 中安装和配置 SSL Keylog 功能。

## 系统要求

- Nginx 1.28.0 或更高版本
- OpenSSL 1.1.1 或更高版本
- Linux/Unix 操作系统
- 基本的编译工具（gcc, make 等）

## 安装步骤

### 1. 下载 Nginx 源码

```bash
# 下载 Nginx 1.28.0
wget http://nginx.org/download/nginx-1.28.0.tar.gz
tar -xzf nginx-1.28.0.tar.gz
cd nginx-1.28.0
```

### 2. 应用补丁

```bash
# 应用 SSL Keylog 补丁
patch -p1 < ../nginx-sslkeylog/patches/nginx-1.28.0-sslkeylog.patch
```

### 3. 配置编译选项

```bash
# 基本配置（HTTP 代理 + gRPC）
./configure --with-http_ssl_module --with-http_v2_module

# 完整配置（包含所有模块）
./configure --with-http_ssl_module --with-http_v2_module --with-stream_ssl_module
```

### 4. 编译和安装

```bash
# 编译
make

# 安装
make install
```

### 5. 验证安装

```bash
# 检查 Nginx 版本和模块
nginx -V

# 检查配置语法
nginx -t
```

## 自动化安装

您也可以使用提供的脚本进行自动化安装：

```bash
# 使用通用补丁应用脚本
./scripts/apply-patch.sh nginx-1.28.0
```

## 故障排除

### 常见问题

1. **编译错误：找不到 OpenSSL**
   ```bash
   # 安装 OpenSSL 开发包
   sudo apt-get install libssl-dev  # Ubuntu/Debian
   sudo yum install openssl-devel   # CentOS/RHEL
   ```

2. **补丁应用失败**
   ```bash
   # 检查 Nginx 版本是否匹配
   # 确保补丁文件路径正确
   # 检查是否有未提交的修改
   ```

3. **配置错误**
   ```bash
   # 检查配置语法
   nginx -t
   
   # 查看错误日志
   tail -f /var/log/nginx/error.log
   ```

### 获取帮助

如果遇到问题，请：

1. 检查 [故障排除指南](troubleshooting.md)
2. 查看 [配置示例](../examples/)
3. 提交 GitHub Issue

## 卸载

如果需要卸载 SSL Keylog 功能：

```bash
# 重新编译 Nginx（不应用补丁）
cd nginx-1.28.0
./configure --with-http_ssl_module --with-http_v2_module
make && make install
```

## 安全注意事项

⚠️ **重要提醒**：SSL Keylog 功能会记录敏感信息，请在生产环境中谨慎使用。 