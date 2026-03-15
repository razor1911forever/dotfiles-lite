set -gx EDITOR /usr/local/bin/nvim
set -gx VISUAL /usr/local/bin/nvim
set -gx DOTNET_ROOT /home/jtye/.dotnet
if test (hostname) = DSLD1337
    set -gx WAYLAND_DISPLAY wayland-0
end

set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_hide_untrackedfiles 1

set -g __fish_git_prompt_color_branch --bold magenta
set -g __fish_git_prompt_showupstream informative
set -g __fish_git_prompt_describe_style branch
set -g __fish_git_prompt_char_upstream_ahead "↑"
set -g __fish_git_prompt_char_upstream_behind "↓"
set -g __fish_git_prompt_char_upstream_prefix ""

set -g __fish_git_prompt_char_stagedstate "●"
set -g __fish_git_prompt_char_dirtystate "✚"
set -g __fish_git_prompt_char_untrackedfiles "…"
set -g __fish_git_prompt_char_conflictedstate "✖"
set -g __fish_git_prompt_char_cleanstate "✔"

set -g __fish_git_prompt_color_dirtystate cyan
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
set -g __fish_git_prompt_color_cleanstate green

set -g __fish_custom_nodejs_prompt_color --italics green
set -g __fish_custom_nodejs_prompt_symbol ""
source ~/.config/fish/dotnet.fish

# https://github.com/fish-shell/fish-shell/issues/11082#issuecomment-2609043821
bind -M insert ctrl-n down-or-search
