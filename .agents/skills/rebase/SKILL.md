---
name: rebase
description: Use when editing tracked config/dotfiles in this repo, where the platform branch currently checked out (`linux-atomic` on the Linux box, `macos` on the Mac) sits on top of `linux` and the change must land on `linux` first and then be rebased back. Covers edit → stash → commit on linux → rebase → force-with-lease, plus conflicts and rollback.
disable-model-invocation: true
---

> 手动技能：只能由人显式调用（`/rebase` 或点名），不要自动触发。

# dotfiles：改动先落到 linux，再 rebase 回当前平台分支

## 仓库布局（用变量，不要写死分支名）

- `linux`：稳定的基础分支，检出在另一个 worktree（本机是 `~/Projects/dotfiles-linux`）。
- **平台分支**：`linux-atomic`（Linux 机器）、`macos`（Mac）。当前检出的那个就是工作分支，
  全文用 `$WORK` 指代。
- 同一仓库的多个 worktree 共享 stash；但 git 不允许同一分支被两个 worktree 同时检出，
  所以在平台分支的 worktree 里 `git checkout linux` 会报 `already checked out at ...`。
  linux 侧操作统一用 `git -C "$LINUX_WT"`，平台分支侧就用当前目录的 `git`。

一句话：在 `$WORK` 上验证 → 把 diff 搬到 `linux` 提交并推送 → `$WORK` rebase 到新
`linux` → 带 lease 强推 `$WORK`。

## 0. 定位分支与 worktree（每次先跑）

```bash
BASE=linux
WORK=$(git branch --show-current)      # 例：linux-atomic 或 macos
[ -n "$WORK" ] && [ "$WORK" != "$BASE" ] || { echo "当前不是平台分支（detached HEAD 或就在 $BASE 上）"; }

LINUX_WT=$(git worktree list --porcelain \
  | awk -v b="refs/heads/$BASE" '/^worktree /{w=$2} $0=="branch "b{print w}')
```

`$LINUX_WT` 为空说明 `linux` 没有单独 worktree，改用文末的「单检出变体」。

## 1. 先看清 rebase 会重放什么

```bash
git merge-base --is-ancestor "$BASE" "$WORK" \
  && echo "已包含最新 linux" \
  || echo "基点落后：rebase 会把下面这些提交重放到新 linux 上"
git log --oneline "$BASE..$WORK"
```

`macos` 可能落后 `linux` 好几个提交，重放时冲突会明显更多——先看清楚再动手。

## 2. 在平台分支上改并验证

正常编辑、跑校验（配置生效、`dsh` 重载、语法检查等）。**验证通过再往下走**，
后面的步骤只是把一份已确认正确的 diff 搬过去。

## 3. 预检

```bash
git status --short                    # 确认只有本次要搬的文件
git diff --stat
git -C "$LINUX_WT" status --short     # 必须为空；有杂项先处理，别 pop 上去
```

linux worktree 不干净就停下来问清楚——`stash pop` 会把它和自己的改动混在一起。

## 4. 暂存（必须带 `-u`）

```bash
git stash push -u -m "promote: <一句话说明>"
```

| 情况 | 处理 |
| --- | --- |
| 新增文件（untracked） | **必须** `-u`，否则 pop 到 linux 上根本不会出现 |
| 工作区本来就干净（改动已在 `$WORK` 上提交） | 跳过本步和第 5 步的 pop，改用 `cherry-pick` 备选 |
| 只想搬一部分文件 | `git stash push -u -m "..." -- path/a path/b` |

## 5. 在 linux worktree 落地并提交

```bash
git -C "$LINUX_WT" stash pop
git -C "$LINUX_WT" status --short
git -C "$LINUX_WT" add -A
git -C "$LINUX_WT" commit -m "feat(<scope>): <说明>"
git -C "$LINUX_WT" push origin "$BASE"
```

提交信息沿用仓库现有风格：`feat(zed): ...`、`fix(fcitx5): ...`、`refactor: ...`。
一次只提一个逻辑改动；要多提交就分批 `git add`，别用一个 `add -A` 混进去。

> 备选：如果改动已经在 `$WORK` 上提交了，直接
> `git -C "$LINUX_WT" cherry-pick <sha>` 更省事，效果相同。

## 6. 让平台分支重新落到新 linux 上

```bash
OLD=$(git rev-parse --verify --quiet "origin/$WORK")   # 必须在 fetch 之前取；远端没这分支则空
git fetch origin
git rebase "$BASE"
```

`OLD` 要在 `fetch` **之前**取：万一远端被别人推过，`fetch` 会更新 `origin/$WORK`，
但显式 lease 仍按旧 SHA 校验，强推会被拒绝——这正是我们要的。

## 7. 校验（推之前，别省）

```bash
git log --oneline "$BASE..$WORK"        # 应只剩本平台自己的提交
git diff --stat "$BASE"                 # 只剩本平台独有的改动
git diff "$BASE" -- <改过的文件>        # 与预期一致（本平台无额外改动时应为空）
```

## 8. 带 lease 强推平台分支

```bash
if [ -n "$OLD" ]; then
  git push --force-with-lease="$WORK:$OLD" origin "$WORK"
else
  git push -u origin "$WORK"            # 远端还没有这个分支
fi
```

**永远不要**用裸 `git push --force`。被 lease 拒绝时：先 `git fetch`，看
`git log --oneline HEAD..origin/$WORK` 弄清远端多出了什么，再决定 rebase 还是找人确认，
不要改成强制覆盖。

## 9. 收尾

```bash
git stash list                 # 应为空（pop 成功会自动 drop）
git status --short
git -C "$LINUX_WT" status --short
git fetch origin && git status -sb
```

## 单检出变体（`linux` 没有独立 worktree）

上面的第 5、9 步改成切分支，其余不变：

```bash
git switch "$BASE"
git stash pop
git add -A && git commit -m "feat(<scope>): <说明>" && git push origin "$BASE"
git switch "$WORK"             # 提交后工作区已干净，切回是安全的
```

中途某步失败就先解决再继续，别在半途 `switch` 回 `$WORK` 把改动带过去。

## 冲突处理

| 场景 | 做法 |
| --- | --- |
| `stash pop` 冲突 | 手工解决 → `git add` → `git -C "$LINUX_WT" stash drop`（冲突时 pop 不会自动 drop） |
| `rebase` 冲突 | 手工解决 → `git add` → `git rebase --continue` |
| rebase 想放弃 | `git rebase --abort` |
| 只想看会冲突什么 | `git rebase --stat "$BASE"` 或先 `git diff "$BASE"` |

同一文件在 `$WORK` 上本来就有改动时，第 6 步**必然冲突**：两边都要保留，合并后确认
linux 侧是新提交的内容、`$WORK` 侧是「新提交 + 自己的差异」。

## 回滚

```bash
git reflog                       # 找到 rebase 前的 HEAD
git reset --hard ORIG_HEAD       # rebase 会设置 ORIG_HEAD；先确认没有未保存改动
git rebase --abort               # rebase 进行中时用这个
git stash list                   # 确认没有卡在 stash 里的改动
```

已经强推错了：用 `git reflog` 找回旧 SHA，再用
`git push --force-with-lease="$WORK:<当前远端SHA>" origin <旧SHA>:"$WORK"`
推回去，别直接 reset 远端。

## 不该走这个流程的情况

- 改动**只属于本平台**（平台特有的路径、包、硬件差异）：留在 `$WORK` 上提交，
  不要提升到 linux。
- 改动其实与分支无关、只是本地临时调试：不要提交，用完还原即可。
- linux worktree 有别人/别的任务的未提交改动：先停下确认，别 pop 上去。

## 完成标准

- [ ] linux 上提交已推送，远端 `linux` 与本地一致
- [ ] `git log --oneline "$BASE..$WORK"` 只剩本平台自己的提交
- [ ] 两个 worktree 的 `status` 都干净
- [ ] `git stash list` 为空
- [ ] 远端 `$WORK` 的 SHA 与本地 `HEAD` 一致

## 备注

- 本文件自身就是在 `$WORK` 上的 untracked 新文件。要纳入仓库，同样走一遍本流程：
  stash（带 `-u`）→ 在 linux 上提交 → 回 `$WORK` rebase。
- 新加的 skill 通常要重开会话（或刷新 skill 列表）才会出现在可用技能里。
