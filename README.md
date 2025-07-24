# Nginx SSL Keylog 功能 / Nginx SSL Keylog Feature

[English](#english) | [中文](#chinese)

---

## English

### Overview

This patch adds SSL session key logging functionality to Nginx 1.28.0, supporting HTTP proxy and gRPC modules. When Nginx acts as a proxy forwarding HTTPS requests to upstream servers, it automatically records SSL session keys to a specified file, facilitating network debugging and security analysis.

### Features

- 🔐 **SSL Key Logging** - Automatically records TLS 1.2/1.3 session keys
- 🌐 **HTTP Proxy Support** - SSL key logging for HTTP proxy module
- ⚡ **gRPC Support** - SSL key logging for gRPC module
- 📝 **Standard Format** - Outputs in NSS Key Log Format
- ⚙️ **Flexible Configuration** - Configurable key log file path

### Quick Start

```bash
# Apply the patch
patch -p1 < patches/nginx-{version}-sslkeylog.patch

# Configure and compile
./configure --with-http_ssl_module --with-http_v2_module
make && make install
```

### Configuration

#### HTTP Proxy Module
```nginx
# Enable SSL keylog
proxy_ssl_keylog on;
proxy_ssl_keylog_file /var/log/nginx/http_ssl_keys.log;
```

#### gRPC Module
```nginx
# Enable SSL keylog
grpc_ssl_keylog on;
grpc_ssl_keylog_file /var/log/nginx/grpc_ssl_keys.log;
```

### Example Configuration

#### HTTP Proxy
```nginx
http {    
    server {
        listen 80;
        
        location / {
            proxy_ssl_keylog on;
            proxy_ssl_keylog_file /var/log/nginx/http_ssl_keys.log;
            
            proxy_pass https://backend.example.com;
        }
    }
}
```

#### gRPC Proxy
```nginx
http {
    server {
        listen 80;
        
        location / {
            grpc_ssl_keylog on;
            grpc_ssl_keylog_file /var/log/nginx/grpc_ssl_keys.log;
            
            grpc_pass grpcs://backend.example.com:443;
        }
    }
}
```

### Modified Files

- `src/http/modules/ngx_http_proxy_module.c` - HTTP proxy module
- `src/http/modules/ngx_http_grpc_module.c` - gRPC module

### Technical Implementation

- Uses OpenSSL's `SSL_CTX_set_keylog_callback` function
- Automatically records session keys after SSL handshake completion
- Outputs in NSS Key Log Format
- Supports append mode for file writing

### Requirements

- Nginx 1.28.0
- OpenSSL 1.1.1 or higher
- HTTP SSL module enabled

### Security Considerations

⚠️ **Important**: The key log file contains sensitive information. Please:
- Protect the log file with appropriate permissions
- Use this feature carefully in production environments
- Ensure nginx process has write permissions to the log file

### Use Cases

- Network debugging and troubleshooting
- SSL/TLS protocol analysis
- Security research and penetration testing
- Wireshark traffic analysis

### Verification

After applying the patch and compiling:

1. Configure SSL keylog functionality
2. Send HTTPS requests through nginx proxy
3. Check the specified log file for key information
4. Verify key format with tools like Wireshark

---

## Chinese

### 概述

这个patch为nginx 1.28.0添加了SSL会话密钥记录功能，支持HTTP代理和gRPC模块。当nginx作为代理转发HTTPS请求到上游服务器时，自动将会话密钥记录到指定文件，便于网络调试和安全分析。

### 功能特性

- 🔐 **SSL密钥记录** - 自动记录TLS 1.2/1.3会话密钥
- 🌐 **HTTP代理支持** - HTTP代理模块的SSL密钥记录
- ⚡ **gRPC支持** - gRPC模块的SSL密钥记录
- 📝 **标准格式** - 按照NSS Key Log Format格式输出
- ⚙️ **灵活配置** - 可配置的密钥日志文件路径

### 快速开始

```bash
# 应用patch
patch -p1 < patches/nginx-{version}-sslkeylog.patch

# 配置编译
./configure --with-http_ssl_module --with-http_v2_module
make && make install
```

### 配置指令

#### HTTP代理模块
```nginx
# 启用SSL keylog
proxy_ssl_keylog on;
proxy_ssl_keylog_file /var/log/nginx/http_ssl_keys.log;
```

#### gRPC模块
```nginx
# 启用SSL keylog
grpc_ssl_keylog on;
grpc_ssl_keylog_file /var/log/nginx/grpc_ssl_keys.log;
```

### 配置示例

#### HTTP代理配置
```nginx
http {    
    server {
        listen 80;
        
        location / {
            proxy_ssl_keylog on;
            proxy_ssl_keylog_file /var/log/nginx/http_ssl_keys.log;
            
            proxy_pass https://backend.example.com;
        }
    }
}
```

#### gRPC配置
```nginx
http {
    server {
        listen 80;
        
        location / {
            grpc_ssl_keylog on;
            grpc_ssl_keylog_file /var/log/nginx/grpc_ssl_keys.log;
            
            grpc_pass grpcs://backend.example.com:443;
        }
    }
}
```

### 修改的文件

- `src/http/modules/ngx_http_proxy_module.c` - HTTP代理模块
- `src/http/modules/ngx_http_grpc_module.c` - gRPC模块

### 技术实现

- 利用OpenSSL的`SSL_CTX_set_keylog_callback`回调函数
- 在SSL握手完成后自动记录会话密钥
- 按照NSS Key Log Format格式输出
- 支持文件追加模式写入

### 系统要求

- OpenSSL 1.1.1或更高版本
- 启用HTTP SSL模块

### 安全注意事项

⚠️ **重要提示**：密钥日志文件包含敏感信息，请：
- 使用适当的权限保护日志文件
- 在生产环境中谨慎使用此功能
- 确保nginx进程有写入日志文件的权限

### 应用场景

- 网络调试和故障排除
- SSL/TLS协议分析
- 安全研究和渗透测试
- Wireshark流量分析

### 功能验证

应用patch并编译安装后，可以通过以下方式验证功能：

1. 配置SSL keylog功能
2. 发送HTTPS请求到nginx代理
3. 检查指定的日志文件是否包含密钥信息
4. 使用Wireshark等工具验证密钥格式是否正确

---

## License

This project is based on Nginx and follows the same license terms as Nginx.

## Contributing

Feel free to submit issues and enhancement requests!

## Acknowledgments

- Uses OpenSSL's keylog callback functionality
- Follows NSS Key Log Format standard
