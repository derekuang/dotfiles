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
