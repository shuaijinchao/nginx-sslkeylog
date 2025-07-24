# Nginx SSL Keylog 功能 / Nginx SSL Keylog Feature

[English](#english) | [中文](#chinese)

---

## English

### Overview

This patch adds SSL session key logging functionality to Nginx, supporting HTTP proxy and gRPC modules. When Nginx acts as a proxy forwarding HTTPS requests to upstream servers, it automatically records SSL session keys to a specified file, facilitating network debugging and security analysis.

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

#### HTTP Proxy Configuration
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

#### HTTP Session Keys
```nginx
CLIENT_RANDOM a46541c3ccbae8d0b54a5facb94f17e8609801c0cf7b127fd0f6706277e6b25a 85f7f4dfa1ba4a4d2ed6ce830c6f72fd1ed6d918acaf0219dc5dc584b84d9521e3a04aa5073d649fe0454814c30308ce
CLIENT_RANDOM ae68c19634ca01b15b127bfa536d5dffd3d05f941158816cf397817209bb2896 e92afff38b4257e6e1ddec7ff5cd516fadf0ce72a490e53bf16c346bdd3fa5bd56a59963bd8b23a91033cdca96cdd9d9
CLIENT_RANDOM e9b7997e3c5455becdf5cf8448d2b6b4e1fb709fc49972eca22e115fbd624507 4418b5ca72ee08e4c8f05430b5186130d496e2b816e49d89ee9e355bd7d41a75476a5dc4abe0f0f77483a944959f109c
CLIENT_RANDOM 4073409eba9e52e928cc2c926ca704608e1e7d1d38b4990c4b4d26ed236e7199 144b2075899ff38c085dd8b614f6fbc0579be55bda42546e1a0df195a18137ee61469fc7b921161833133f6a3b9b76a3
CLIENT_RANDOM 815ac0274b8508844acb97eec97c2d5a937890cd3ad76310bb49f553331eebe6 ddd1eb984e103fcfbb5ad53019c215c959e162d06158792c1a22bdeb8ebac0f9a0893ee4835f89bb988491ab8e4b4ff3
```

#### gRPC Proxy Configuration
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

#### gRPC Session Keys
```nginx
SERVER_HANDSHAKE_TRAFFIC_SECRET c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 7a21eb6b825d7f74131589507bece804027c5ec0243e79fd20b0aad44ef58077
EXPORTER_SECRET c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 7d98f9fd1428b086818e097be57c5338c826df8e4d9a1eca4e91acd1fd1bedff
SERVER_TRAFFIC_SECRET_0 c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 6d2cc100cd21a635f7b1a463f43afa1bb2da8c600b7b0c3a37d16ee026a24c7b
CLIENT_HANDSHAKE_TRAFFIC_SECRET c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 dfb5f2d9547eb731dc128a65269e2c85bee9d9ad3d43a87d38816f862c6ed4f8
CLIENT_TRAFFIC_SECRET_0 c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 70a7eb38ee2ab6a73c26e06c8cebc6ae07c6e84bb48a32fab3ed43e55d5a4eab
SERVER_HANDSHAKE_TRAFFIC_SECRET b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 3bf20eb40f65c7e342237e74469ede02d570b6234d8523f06997dd71aebdd12e
EXPORTER_SECRET b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 a19eabfe17e238f603604b24b2aab5c13af703eeda45579482de7c094e170a16
SERVER_TRAFFIC_SECRET_0 b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 9adfe1afc7aef9e3bf2e052c8462865d20bd802580ac8ce5766177d24391e671
CLIENT_HANDSHAKE_TRAFFIC_SECRET b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 7e8e518f00dd299d4ab77b58166ff4416eeee7e3bd2aa0938f7092bd774c16e9
CLIENT_TRAFFIC_SECRET_0 b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 3468bdb73a51a0fcc1b455d8fc85b52a99e3882e44ad1626905a6cb6e43f2274
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

这个 patch 为 nginx 添加了SSL会话密钥记录功能，支持HTTP代理和gRPC模块。当nginx作为代理转发HTTPS请求到上游服务器时，自动将会话密钥记录到指定文件，便于网络调试和安全分析。

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

#### HTTP 代理配置
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

#### HTTP 会话秘钥
```nginx
CLIENT_RANDOM a46541c3ccbae8d0b54a5facb94f17e8609801c0cf7b127fd0f6706277e6b25a 85f7f4dfa1ba4a4d2ed6ce830c6f72fd1ed6d918acaf0219dc5dc584b84d9521e3a04aa5073d649fe0454814c30308ce
CLIENT_RANDOM ae68c19634ca01b15b127bfa536d5dffd3d05f941158816cf397817209bb2896 e92afff38b4257e6e1ddec7ff5cd516fadf0ce72a490e53bf16c346bdd3fa5bd56a59963bd8b23a91033cdca96cdd9d9
CLIENT_RANDOM e9b7997e3c5455becdf5cf8448d2b6b4e1fb709fc49972eca22e115fbd624507 4418b5ca72ee08e4c8f05430b5186130d496e2b816e49d89ee9e355bd7d41a75476a5dc4abe0f0f77483a944959f109c
CLIENT_RANDOM 4073409eba9e52e928cc2c926ca704608e1e7d1d38b4990c4b4d26ed236e7199 144b2075899ff38c085dd8b614f6fbc0579be55bda42546e1a0df195a18137ee61469fc7b921161833133f6a3b9b76a3
CLIENT_RANDOM 815ac0274b8508844acb97eec97c2d5a937890cd3ad76310bb49f553331eebe6 ddd1eb984e103fcfbb5ad53019c215c959e162d06158792c1a22bdeb8ebac0f9a0893ee4835f89bb988491ab8e4b4ff3
```


#### gRPC 代理配置
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

#### gRPC 会话秘钥
```nginx
SERVER_HANDSHAKE_TRAFFIC_SECRET c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 7a21eb6b825d7f74131589507bece804027c5ec0243e79fd20b0aad44ef58077
EXPORTER_SECRET c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 7d98f9fd1428b086818e097be57c5338c826df8e4d9a1eca4e91acd1fd1bedff
SERVER_TRAFFIC_SECRET_0 c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 6d2cc100cd21a635f7b1a463f43afa1bb2da8c600b7b0c3a37d16ee026a24c7b
CLIENT_HANDSHAKE_TRAFFIC_SECRET c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 dfb5f2d9547eb731dc128a65269e2c85bee9d9ad3d43a87d38816f862c6ed4f8
CLIENT_TRAFFIC_SECRET_0 c1d973f1704c1abc8f2e3882aa95efc9a6e08984aee09986b8b99ec8b7aec521 70a7eb38ee2ab6a73c26e06c8cebc6ae07c6e84bb48a32fab3ed43e55d5a4eab
SERVER_HANDSHAKE_TRAFFIC_SECRET b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 3bf20eb40f65c7e342237e74469ede02d570b6234d8523f06997dd71aebdd12e
EXPORTER_SECRET b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 a19eabfe17e238f603604b24b2aab5c13af703eeda45579482de7c094e170a16
SERVER_TRAFFIC_SECRET_0 b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 9adfe1afc7aef9e3bf2e052c8462865d20bd802580ac8ce5766177d24391e671
CLIENT_HANDSHAKE_TRAFFIC_SECRET b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 7e8e518f00dd299d4ab77b58166ff4416eeee7e3bd2aa0938f7092bd774c16e9
CLIENT_TRAFFIC_SECRET_0 b0e69372d35855a67aa3cfaec78a70aa5dc5a591170d8bbb68c00fa7ef073aa1 3468bdb73a51a0fcc1b455d8fc85b52a99e3882e44ad1626905a6cb6e43f2274
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
