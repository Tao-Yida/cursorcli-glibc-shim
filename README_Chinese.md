中文版本 | [English](README.md)

# 在 CentOS 7 上使用自定义 glibc 2.28 运行 CursorCLI Agent

## 概述

本项目提供了一个启动脚本，用于在 CentOS 7 系统上使用自定义 glibc 2.28 运行 CursorCLI Agent，而无需修改原有的 agent 脚本。CursorCLI Agent 需要 glibc 2.28 或更高版本，而 CentOS 7 的默认系统 glibc 为 2.17。

## 前置条件

本脚本假设您已经完成以下操作：

1. 在用户目录下编译并安装了 **glibc 2.28** 和 **GCC 9.5.0**
2. 自定义 glibc 安装在 `$HOME/opt/glibc-2.28`
3. GCC 9.5.0 安装在 `$HOME/opt/gcc-9.5.0`

关于编译和安装 glibc 2.28、GCC 9.5.0 和 Make 4.2 的详细说明，请参考 [opencode-on-centos7 项目](https://github.com/Tao-Yida/opencode-on-centos7)，该项目提供了设置所需环境的完整文档。

## 快速开始

### 1. 验证前置条件

检查所需工具是否已安装：

```bash
# 检查 glibc 2.28
$HOME/opt/glibc-2.28/lib/ld-linux-x86-64.so.2 --version

# 检查 GCC 9.5.0
$HOME/opt/gcc-9.5.0/bin/gcc --version

# 检查 Agent 是否已安装
which agent
# 通常位于 ~/.local/bin/agent
```

### 2. 使用脚本

主脚本位于 `scripts/agent_with_custom_glibc.sh`。您可以直接运行：

```bash
cd /home/taoyida/cursorcli-glibc-shim
./scripts/agent_with_custom_glibc.sh [参数]
```

或者在 shell 配置中创建别名：

```bash
# 添加到 ~/.bashrc
cursor-cli() {
    /home/taoyida/cursorcli-glibc-shim/scripts/agent_with_custom_glibc.sh "$@"
}
```

然后重新加载配置：

```bash
source ~/.bashrc
```

现在可以使用：

```bash
cursor-cli [参数]
```

## 工作原理

脚本的工作流程如下：

1. **定位 Agent 脚本**：在 `~/.local/bin/agent` 处找到 agent 二进制文件
2. **设置环境**：配置使用自定义 glibc 运行的环境变量：
   - 设置 `LANG` 和 `LC_ALL` 为 `en_US.UTF-8` 以保证正确的编码
   - 将 GCC 9.5.0 的 lib64 路径添加到 `LD_LIBRARY_PATH` 以提供 `libgcc_s.so.1` 支持
   - **不**将 glibc-2.28 添加到 `LD_LIBRARY_PATH` 以避免冲突
3. **使用自定义 glibc 运行**：使用自定义 glibc 链接器 `$HOME/opt/glibc-2.28/lib/ld-linux-x86-64.so.2` 启动 node
4. **恢复环境**：agent 退出后恢复原始环境变量

## 主要特性

- **非侵入式**：不修改原始 agent 脚本
- **环境隔离**：只影响 agent 进程，不影响其他系统程序
- **自动环境恢复**：确保退出后不影响外部 shell
- **错误处理**：全面的错误检查和清晰的错误提示

## 重要说明

1. **LD_LIBRARY_PATH 处理**：脚本只将 GCC lib64 路径添加到 `LD_LIBRARY_PATH`，**不添加** glibc 路径。这是有意为之，以防止系统 bash 子进程因 glibc 版本不匹配而崩溃。

2. **Libgcc_s.so.1 依赖**：脚本设置 `LD_LIBRARY_PATH` 包含 GCC 9.5.0 的 lib64 路径，以提供 `libgcc_s.so.1` 支持 `pthread_cancel` 功能。这是 agent 执行文件搜索等复杂任务所必需的。

3. **用户目录安装**：所有软件应安装在用户目录中（如 `$HOME/opt/`），无需 root 权限。

## 文件结构

```
cursorcli-glibc-shim/
├── assets/
│   └── album.png
├── scripts/
│   └── agent_with_custom_glibc.sh
├── README.md           # 英文版本
└── README_Chinese.md   # 本文件
```

## 故障排除

### 错误：找不到可执行的 node

**原因**：agent 二进制文件未安装或未在预期位置。

**解决方案**：先安装 CursorCLI Agent。它应安装在 `~/.local/bin/agent`。

### 错误：找不到自定义 glibc 链接器

**原因**：自定义 glibc 2.28 未安装在预期位置。

**解决方案**：确保 glibc 2.28 安装在 `$HOME/opt/glibc-2.28/lib/ld-linux-x86-64.so.2`。请参考 [opencode-on-centos7 项目](https://github.com/Tao-Yida/opencode-on-centos7) 获取安装说明。

### 错误：libgcc_s.so.1 must be installed for pthread_cancel to work

**原因**：GCC 9.5.0 的 lib 路径未在 `LD_LIBRARY_PATH` 中。

**解决方案**：脚本会自动处理此问题。如果仍然遇到此问题，请验证 GCC 9.5.0 是否安装在 `$HOME/opt/gcc-9.5.0`。

## 相关项目

关于编译和安装前置条件（glibc 2.28、GCC 9.5.0、Make 4.2）的信息，请参考 [opencode-on-centos7 项目](https://github.com/Tao-Yida/opencode-on-centos7)。

## 许可证

本项目采用 MIT 许可证，可自由使用和修改。

---

**最后更新**：2026年1月28日

**作者**：Yida Tao
