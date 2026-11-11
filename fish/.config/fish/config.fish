if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Prefer a real Node over the DeepSeek Harness desktop launcher in ~/.local/bin,
# whose hardcoded AppImage mount (/tmp/.mount_*) goes stale on every restart.
if test -d /home/linuxbrew/.linuxbrew/bin
    fish_add_path --path --move --prepend /home/linuxbrew/.linuxbrew/bin
end

starship init fish | source
