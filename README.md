# My dotfiles - Managed by [chezmoi](https://chezmoi.io/)

## 国内前置网络环境准备

- 下载FlClash网络代理工具，国内下载地址：https://dl.p6p.net/FlClash/

- 代理工具配置，本人使用坚果云同步FlClash配置

- macos额外操作
  
  - 安装`homebrew`

## 日常操作

1. 在新的机器拉取安装chezmoi和个人仓库的dotfiles

  - `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME`
  
  - `git remote set-url origin git@github.com:$GITHUB_USERNAME/dotfiles.git` - 拉取后设置git仓库url让后续正常push推送
  
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

1. 普通配置文件

  - 说明：最普通的配置文件同步方案，基于从dotfiles源仓库中复制/覆盖到对应的目标目录。如`.gitconfig`, `.tmux.config`。
  
  - 入库操作：
  
    `chezmoi add $FILE`
  
2. 基于软链接的文件

  - 说明：适用于一些本来就有ui来直接修改配置的软件，或内部有方法直接修改配置，这时候就把软件的配置文件保存到我们的源仓库中，在原本放配置文件的地方创建软链接指向源仓库。如`vscode`, `zed`编辑器的配置文件等。
  
  - 入库操作（以`zed`编辑器的配置文件`settings.json`为例）：
  
    - `mv ~/.config/zed/settings.json $(chezmoi source-path)/zed` - 将文件移动到源仓库路径下的zed文件夹下
    
    - `echo zed >> $(chezmoi source-path)/.chezmoiignore` - 告诉chezmoi忽略掉zed目录（以防止在apply时在$HOME下创建一个zed目录）
    
    - `mkdir -p $(chezmoi source-path)/dot_config/zed` - 在源仓库中创建映射的zed目录
    
    - `echo -n "{{ .chezmoi.sourceDir }}/zed/settings.json" > $(chezmoi source-path)/dot_config/zed/symlink_settings.json.tmpl` - 创建一个源仓库文件加入`symlink`前缀状态，内容是真实配置文件的路径，意思是在目标目录中创建一个指向该配置文件的软链接

3. 外部引用文件

  - 说明：适用于来自于网络上的一些预配置的软件框架、插件等的文档文件。如`neovim`的`lazyvim`框架，`zsh`的插件，`rime`输入法的雾凇拼音方案等。
  
  - 入库操作：
  
    在`.chezmoiexternal.toml`中添加相关的配置，支持打包压缩的文档、git仓库等，详细的配置项见`https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/`
  
4. 加密文件

  - 说明：适用于不宜公开的私密文件。如ssh的私钥文件等。
  
  - 入库操作：
  
    - 配置加密文件所用到的内容`https://www.chezmoi.io/user-guide/frequently-asked-questions/encryption/`
    
    - `chezmoi add --encrypt $FILE`
  
5. 系统文件（非home目录下）

  - 说明：使用于不属于用户home目录的文件，一般来说都是些系统文件或需要root权限的配置文件。如`google-chrome`的yum仓库结构配置、`kanata`的系统服务文件等。
  
  - 入库操作：
  
    一般是处理成在软件安装脚本后的运行脚本`run_xxx_after_xxx.sh.tmpl`中，直接把文件用sudo权限复制到目标位置
  
## 自动化脚本

- todo
