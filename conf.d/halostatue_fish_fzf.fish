if test -z $__fzf_ctrl_t_default_command
    or not test -x $__fzf_ctrl_t_default_command
    if command -sq pt
        set -U __fzf_ctrl_t_default_command pt
        set -Ux FZF_CTRL_T_DEFAULT_COMMAND 'pt -g "" --hidden --ignore .git'
    else if command -sq rg
        set -U __fzf_ctrl_t_default_command rg
        set -Ux FZF_CTRL_T_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2>/dev/null'
    else if command -sq ag
        set -U __fzf_ctrl_t_default_command ag
        set -Ux FZF_CTRL_T_DEFAULT_COMMAND 'ag -g "" --hidden --ignore .git'
    else
        set -e __fzf_ctrl_t_default_command
        set -e FZF_CTRL_T_DEFAULT_COMMAND
    end
end

set -Uq FZF_CTRL_T_OPTS
or begin
    set -l preview \
        'highlight -O xterm256 -l {} 2> /dev/null' \
        'bat --color=always {}' \
        'cat {}' \
        'tree -C {}'
    set -l preview '('(string join '||' $preview)') | head -200'
    set -Ux FZF_CTRL_T_OPTS '--preview='$preview' --select -1 --exit 0'
end

set -Uq FZF_ALT_C_OPTS
or set -Ux FZF_ALT_C_OPTS "--preview='tree -C {} | head -200' --header-lines=1 --select-1 --exit-0"

set -Uq FZF_CTRL_R_OPTS
or set -Ux FZF_CTRL_R_OPTS "--preview='echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# Handle the case of fzf being installed directly.
if not command -sq fzf
    and test -d $HOME/.fzf/bin
    contains -- $HOME/.fzf/bin $fish_user_paths
    or set fish_user_paths $fish_user_paths $HOME/.fzf/bin

    contains -- $HOME/.fzf/man $MANPATH
    or set MANPATH $MANPATH:$HOME/.fzf/man
end

function _halostatue_fish_fzf_uninstall -e halostatue_fish_fzf_uninstall
    set -Uq FZF_CTRL_T_OPTS
    and set -e FZF_CTRL_T_OPTS

    set -Uq FZF_ALT_C_OPTS
    and set -e FZF_ALT_C_OPTS

    set -Uq FZF_CTRL_R_OPTS
    and set -e FZF_CTRL_R_OPTS

    set -Uq __fzf_ctrl_t_default_command
    and set -e __fzf_ctrl_t_default_command

    functions -e fbr fco fkill
end
