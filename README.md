# Dotfiles

## 管理工具

- Managed with [GNU Stow](https://www.gnu.org/software/stow/)

## 常见情况处理（所有处理都是在`~/dotfiles`下）

1. stow目录有文件，target目录无文件，创建symlink至target目录

`stow --no-folding $PACKAGE`

2. stow目录有文件，target目录有文件，覆盖target目录

`rm /path/to/target/file && stow $PACKAGE`

3. 不管stow目录有无文件，target目录有真实文件，覆盖stow目录

`mkdir -p /dir/to/stow/file && touch $STOW_FILE # 如果还没有源stow文件，创建一个空白同名文件` 
`stow --adopt $PACKAGE`

4. 卸载软件后，移除target目录相关的symlink

`stow -D $PACKAGE`

## 私密文件处理

- **！！！一定要把私密文件添加到`.gitignore`！！！**

- 加密： `openssl enc -aes-256-cbc -salt -pbkdf2 -iter 1000000 -in /path/of/decrypt/file -out /path/of/encrypt/file`

- 解密： `openssl enc -d -aes-256-cbc -pbkdf2 -iter 1000000 -in /path/of/encrypt/file -out /path/of/decrypt/file`

## 注意事项

0. linux系统考虑关闭selinux

1. 如果target目录不是`~`，需要用`-t`选项指定。如系统级的`.service`文件指定`-t /etc/systemd/system`

2. 如果是给flatpak应用同步配置，要先开放`$HOME`目录权限

`sudo flatpak override --system $APPID --filesystem=home`
