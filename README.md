# My dotfiles - Managed by [chezmoi](https://chezmoi.io/)

## 国内前置网络环境准备

- 下载FlClash网络代理工具，国内下载地址：https://dl.p6p.net/FlClash/

- 代理工具配置，本人使用坚果云同步FlClash配置

- macos额外操作
  
  - 安装`homebrew`

## 日常操作

1. 在新的机器拉取安装chezmoi和个人仓库的dotfiles

  - `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME`
  
2. 在机器中拉取更新并直接应用更新（背后是git autostash rebase，可以放心拉取）

  - `chezmoi update`

3. 在本地添加、修改配置文件并应用（以`.gitconfig`为例）

  - 添加要管理的目标文件到仓库
  
    `chezmoi add ~/.gitconfig`
  
  - 调用编辑器打开文件（会在编辑器中打开保存在仓库中的`dot_gitconfig`）
  
    `chezmoi edit ~/.gitconfig`
  
  - 编辑完成后，在编辑器中关闭目标文件，应用刚刚做的修改
  
    `chezmoi apply`
  
  - 一些小技巧
  
    `chezmoi edit --apply ~/.gitconfig` - 关闭目标文件后自动应用修改
    
    `chezmoi edit --watch ~/.gitconfig` - 在修改文件时保存实时应用修改

## 各类文件管理方案

- todo

## 自动化脚本

- todo
