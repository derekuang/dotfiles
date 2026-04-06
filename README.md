# My dotfiles

## 管理工具

- [GNU Stow](https://www.gnu.org/software/stow/)

## 加密文件处理

- 加密： `openssl enc -aes-256-cbc -salt -pbkdf2 -iter 1000000 -in /path/of/decrypt/file -out /path/of/encrypt/file`

- 解密： `openssl enc -d -aes-256-cbc -pbkdf2 -iter 1000000 -in /path/of/encrypt/file -out /path/of/decrypt/file`

## 常见情况处理（所有处理都是在`~/dotfiles`下）

1. stow目录有文件，target目录无文件，同步文件至target目录

`mkdir -p $DIR && stow $PACKAGE`


2. stow目录有文件，target目录有文件，覆盖target目录

`rm /path/to/target/file && stow $PACKAGE`

3. 不管stow目录有无文件，target目录有真实文件，更新stow目录

`./grab.sh`

## 注意事项

1. 如果target目录不是`~`，需要用`-t`选项指定。如`*-service`相关的配置文件，系统级service则`-t /etc/systemd/system`，用户级则`-t ~/.config/systemd/user`

2. 如果是给flatpak应用同步配置，要先开放`$HOME`目录权限

`sudo flatpak override --system $APPID --filesystem=home`
