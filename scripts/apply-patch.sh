
# Nginx SSL Keylog 补丁应用脚本
# 用法: ./apply-patch.sh <nginx-version>
# 示例: ./apply-patch.sh 1.28.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "Nginx SSL Keylog 补丁应用脚本"
    echo
    echo "用法: $0 <nginx-version>"
    echo "示例: $0 1.28.0"
    echo
    echo "支持的版本:"
    ls -1 patches/ | grep nginx- | sed 's/nginx-//' | sed 's/-sslkeylog.patch//' | sort
    echo
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -v, --version  显示脚本版本"
    echo
    echo "注意事项:"
    echo "  - 确保在 Nginx 源码目录中运行此脚本"
    echo "  - 确保 Nginx 源码版本与补丁版本匹配"
    echo "  - 建议在应用补丁前备份源码"
}

# 显示版本信息
show_version() {
    echo "Nginx SSL Keylog 补丁应用脚本 v1.0.0"
    echo "支持 Nginx 1.28.0+"
}

# 检查参数
if [ $# -eq 0 ]; then
    print_error "请指定 Nginx 版本"
    echo
    show_help
    exit 1
fi

# 处理命令行参数
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        show_version
        exit 0
        ;;
    *)
        VERSION="$1"
        ;;
esac

# 验证版本格式
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "无效的版本格式: $VERSION"
    print_error "请使用格式: x.y.z (例如: 1.28.0)"
    exit 1
fi

# 构建补丁文件路径
PATCH_FILE="patches/nginx-${VERSION}-sslkeylog.patch"

# 检查补丁文件是否存在
if [ ! -f "$PATCH_FILE" ]; then
    print_error "补丁文件不存在: $PATCH_FILE"
    echo
    print_info "可用版本:"
    ls -1 patches/ | grep nginx- | sed 's/nginx-//' | sed 's/-sslkeylog.patch//' | sort
    exit 1
fi

# 检查是否在 Nginx 源码目录中
if [ ! -f "configure" ] || [ ! -f "src/core/nginx.h" ]; then
    print_error "当前目录不是 Nginx 源码目录"
    print_error "请切换到 Nginx 源码目录后重试"
    exit 1
fi

# 检查 Nginx 版本
NGINX_VERSION=$(grep "NGINX_VERSION" src/core/nginx.h | sed 's/.*"\(.*\)".*/\1/')
print_info "检测到 Nginx 版本: $NGINX_VERSION"

if [ "$NGINX_VERSION" != "$VERSION" ]; then
    print_warning "Nginx 版本 ($NGINX_VERSION) 与补丁版本 ($VERSION) 不匹配"
    read -p "是否继续应用补丁? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "操作已取消"
        exit 0
    fi
fi

# 检查是否有未提交的修改
if [ -d ".git" ]; then
    if ! git diff --quiet; then
        print_warning "检测到未提交的修改"
        print_info "建议在应用补丁前提交或暂存当前修改"
        read -p "是否继续应用补丁? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "操作已取消"
            exit 0
        fi
    fi
fi

# 备份当前状态
print_info "创建备份..."
BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 备份修改的文件
if [ -f "src/http/modules/ngx_http_proxy_module.c" ]; then
    cp src/http/modules/ngx_http_proxy_module.c "$BACKUP_DIR/"
fi
if [ -f "src/http/modules/ngx_http_grpc_module.c" ]; then
    cp src/http/modules/ngx_http_grpc_module.c "$BACKUP_DIR/"
fi

print_success "备份已创建: $BACKUP_DIR"

# 应用补丁
print_info "应用补丁: $PATCH_FILE"
if patch -p1 < "$PATCH_FILE"; then
    print_success "补丁应用成功！"
else
    print_error "补丁应用失败"
    print_info "正在恢复备份..."
    if [ -f "$BACKUP_DIR/ngx_http_proxy_module.c" ]; then
        cp "$BACKUP_DIR/ngx_http_proxy_module.c" src/http/modules/
    fi
    if [ -f "$BACKUP_DIR/ngx_http_grpc_module.c" ]; then
        cp "$BACKUP_DIR/ngx_http_grpc_module.c" src/http/modules/
    fi
    print_info "备份已恢复"
    exit 1
fi

# 验证补丁应用
print_info "验证补丁应用..."
if grep -q "proxy_ssl_keylog" src/http/modules/ngx_http_proxy_module.c; then
    print_success "HTTP 代理模块补丁验证通过"
else
    print_error "HTTP 代理模块补丁验证失败"
    exit 1
fi

if grep -q "grpc_ssl_keylog" src/http/modules/ngx_http_grpc_module.c; then
    print_success "gRPC 模块补丁验证通过"
else
    print_error "gRPC 模块补丁验证失败"
    exit 1
fi

# 显示后续步骤
echo
print_success "补丁应用完成！"
echo
print_info "后续步骤:"
echo "1. 配置编译选项:"
echo "   ./configure --with-http_ssl_module --with-http_v2_module"
echo
echo "2. 编译 Nginx:"
echo "   make"
echo
echo "3. 安装 Nginx:"
echo "   make install"
echo
echo "4. 配置 SSL Keylog 功能:"
echo "   在 nginx.conf 中添加:"
echo "   proxy_ssl_keylog on;"
echo "   proxy_ssl_keylog_file /var/log/nginx/ssl_keys.log;"
echo
print_info "更多信息请查看: docs/configuration.md" 