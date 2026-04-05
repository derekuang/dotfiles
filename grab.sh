#!/bin/bash

# 设置严格模式：-e 命令失败立即退出，-u 未定义变量报错，-o pipefail 管道失败返回失败状态
set -euo pipefail

# 默认 dotfiles 目录为脚本所在目录，如果没有则使用 ~/dotfiles
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "$(basename "$DOTFILES_DIR")" != "dotfiles" ]; then
    DOTFILES_DIR="$HOME/dotfiles"
fi

echo "========================================"
echo "   📦 Stow 配置文件导入向导"
echo "   仓库位置: $DOTFILES_DIR"
echo "========================================"
echo ""

# --- 第一步：获取包名 ---
read -rp "1️⃣  请输入要归类的包名 (例如: git, zed-flatpak): " PACKAGE_NAME
if [ -z "$PACKAGE_NAME" ]; then
    echo "❌ 包名不能为空，退出。"
    exit 1
fi

# --- 第二步：获取源文件路径 ---
echo ""
echo "2️⃣  请输入本机配置文件的路径。"
echo "    提示: 可以直接把文件拖进终端，或使用 Tab 键补全。"
read -rp "    路径: " SOURCE_FILE

# 处理引号（防止从文件管理器拖拽进来时自带单引号或双引号）
SOURCE_FILE="${SOURCE_FILE#\'}"
SOURCE_FILE="${SOURCE_FILE%\'}"
SOURCE_FILE="${SOURCE_FILE#\"}"
SOURCE_FILE="${SOURCE_FILE%\"}"

# 处理 ~ 符号扩展
SOURCE_FILE="${SOURCE_FILE/#\~/$HOME}"

# 检查文件是否存在
if [ ! -e "$SOURCE_FILE" ]; then
    echo "❌ 错误: 路径 '$SOURCE_FILE' 不存在！"
    exit 1
fi

# 转换为绝对路径并解析可能存在的符号链接
SOURCE_FILE=$(realpath "$SOURCE_FILE")

# 检查源文件是否已经在 dotfiles 目录里了（防止误操作把仓库里的文件移走）
if [[ "$SOURCE_FILE" == "$DOTFILES_DIR"* ]]; then
    echo "❌ 错误: 该文件已经在 dotfiles 仓库里了，无需迁移。"
    exit 1
fi

# --- 核心逻辑：计算目标路径 ---
# 剥离 $HOME 前缀，获取相对路径 (例如把 /home/user/.config/zed 变成 .config/zed)
RELATIVE_PATH="${SOURCE_FILE#$HOME/}"

DEST_DIR="$DOTFILES_DIR/$PACKAGE_NAME/$(dirname "$RELATIVE_PATH")"
DEST_FILE="$DEST_DIR/$(basename "$RELATIVE_PATH")"

# --- 第三步：执行前确认 ---
echo ""
echo "----------------------------------------"
echo "   即将执行以下操作："
echo "   [移动] $SOURCE_FILE"
echo "   [到]   $DEST_FILE"
echo "   [链接] stow --dotfiles $PACKAGE_NAME"
echo "----------------------------------------"
read -rp "   确认执行吗？: " CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo ""
    echo "⏳ 正在处理..."

    # 1. 创建必要的父目录
    mkdir -p "$DEST_DIR"

    # 2. 移动文件 (如果目标已存在则备份)
    if [ -e "$DEST_FILE" ]; then
        echo "⚠️  目标位置已存在文件，已自动备份为 ${DEST_FILE}.bak"
        mv "$DEST_FILE" "${DEST_FILE}.bak"
    fi

    mv "$SOURCE_FILE" "$DEST_FILE"

    # 3. 执行 Stow 链接
    cd "$DOTFILES_DIR"
    stow --dotfiles "$PACKAGE_NAME"

    echo ""
    echo "🎉 迁移并链接成功！"
else
    echo ""
    echo "🚫 已取消操作。"
fi
