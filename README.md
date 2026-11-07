# Dotfiles

## 管理工具

- Managed with [GNU Stow](https://www.gnu.org/software/stow/)

## 常见情况处理（所有处理都是在`~/dotfiles`下）

- stow目录有文件，target目录无文件，创建symlink至target目录

  `stow --no-folding $PACKAGE`

- stow目录有文件，target目录有文件，覆盖target目录

  `rm /path/to/target/file && stow $PACKAGE`

- 不管stow目录有无文件，target目录有真实文件，覆盖stow目录

  `mkdir -p /dir/to/stow/file && touch $STOW_FILE # 如果还没有源stow文件，创建一个空白同名文件` 
  `stow --adopt $PACKAGE`

- 卸载软件后，移除target目录相关的symlink

  `stow -D $PACKAGE`

## 私密文件处理

- **！！！一定要把私密文件添加到`.gitignore`！！！**

- 加密： `openssl enc -aes-256-cbc -salt -pbkdf2 -iter 1000000 -in /path/of/decrypt/file -out /path/of/encrypt/file`

- 解密： `openssl enc -d -aes-256-cbc -pbkdf2 -iter 1000000 -in /path/of/encrypt/file -out /path/of/decrypt/file`

## 注意事项

- 每个分支代表不同的机器配置，但它们都应该始终`rebase`到`default`分支进行修改

  ```bash
  # default分支有提交，同步到当前分支
  $ git switch <BRANCH>
  $ git rebase <DEFAULT_BRANCH>
  $ git push --force-with-lease
  ```

  ```bash
  # 在其它机器上拉取同步分支
  $ git switch <BRANCH>
  $ git fetch
  $ git reset --hard origin/<BRANCH>
  ```

- linux系统考虑设置selinux为`disabled`或`permissive`

- 如果target目录不是`~`，需要用`-t`选项指定。如系统级的`.service`文件指定`stow -t ~/.config/systemd/user`

- 如果是给flatpak应用同步配置，要先开放`$HOME`目录权限

  `sudo flatpak override --system $APPID --filesystem=home`

- 有一些系统服务配置，如`kanata-service`，由于系统启动读取service文件是home目录还没挂载，所以symlink无法读取，要把文件直接复制到目标目录

- fusuma需要把用户添加到`input`组，在atomic desktop中需要特殊处理：

  ```bash
  $ grep -E '^input:' /usr/lib/group | sudo tee -a /etc/group
  $ sudo usermod -aG input $USER
  ```

- WPS365不支持从软件内设置界面为中文，可以用flatseal添加环境变量`LANG=zh_CN.UTF-8`

## DSH Web 插件配置

web profile 的 `package.json`、`pnpm-lock.yaml`、`pnpm-workspace.yaml`、`cordis.patch.yml`
已由本仓库管理（stow 到 `~/.dsh/profiles/web/`）。新机器上按锁文件装回插件：

```bash
# 先装一次同版本 DSH 生成 profile 目录，然后再执行
$ cd ~/.dsh/profiles/web && pnpm install --frozen-lockfile
```

- `cordis.patch.yml` 里 anysearch MCP 的 token 在运行时从 `~/.secrets/anysearch` 读取，不进仓库
- `node_modules/`、`.plugin-manager/`、`cordis.yml`（内容为 `[]`，缺失会自动重建）不提交
- 装完可用 `dsh --profile web --dump-config | grep -E 'better-sidebar|mcp-anysearch'` 验证

## DSH Desktop 插件配置

desktop profile 的 `package.json`、`pnpm-lock.yaml`、`pnpm-workspace.yaml`、`cordis.patch.yml`
已由本仓库管理（stow 到 `~/.dsh/profiles/desktop/`）。桌面版 profile 被 Electron 独占，
`dsh --profile desktop` / `dsh plugin --profile desktop` 都会被拒绝，只能用 pnpm 直接装：

```bash
# 先装一次同版本 DSH Desktop 并让它生成 profile 目录，然后再执行
$ rm ~/.dsh/profiles/desktop/{package.json,pnpm-lock.yaml,pnpm-workspace.yaml,cordis.patch.yml}
$ cd ~/dotfiles && stow --no-folding dsh --ignore='^\.dsh/profiles/(web|dsh-tui)'
$ cd ~/.dsh/profiles/desktop && pnpm install --frozen-lockfile
```

- `~/.dsh/.credentials.yaml` 与 `~/.secrets/anysearch` 不进仓库，新机器重新登录、重建 token 文件
- 设置界面会原地写 `cordis.patch.yml`，调完 `git diff` 可见；`dsh plugin add` 后要复查 symlink 是否还在
