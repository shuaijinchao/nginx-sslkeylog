# 配置指南

## 配置指令

### HTTP 代理模块
- `proxy_ssl_keylog on | off;` - 启用或禁用 SSL 密钥记录
- `proxy_ssl_keylog_file path;` - 指定密钥日志文件路径

### gRPC 模块
- `grpc_ssl_keylog on | off;` - 启用或禁用 SSL 密钥记录
- `grpc_ssl_keylog_file path;` - 指定密钥日志文件路径

## 配置示例

```nginx
http {
    proxy_ssl_keylog on;
    proxy_ssl_keylog_file /var/log/nginx/ssl_keys.log;
    
    grpc_ssl_keylog on;
    grpc_ssl_keylog_file /var/log/nginx/grpc_ssl_keys.log;
}
``` 