# Handle the case of fzf being installed directly.
command -sq fzf
or if test -d $HOME/.fzf/bin
    contains -- $HOME/.fzf/bin $fish_user_paths
    or set fish_user_paths $fish_user_paths $HOME/.fzf/bin

    contains -- $HOME/.fzf/man $MANPATH
    or set MANPATH $MANPATH $HOME/.fzf/man
else
    exit
end

function __fzf_rename_vars -a old new
    if set -Uq $old
        set -Uq $new
        and set -Ux $new $$old

        set -Ue $old
    end
end

__fzf_rename_vars FZF_CTRL_T_OPTS FZF_FIND_FILE_OPTS
__fzf_rename_vars FZF_ALT_C_OPTS FZF_CD_OPTS
__fzf_rename_vars FZF_CTRL_R_OPTS FZF_REVERSE_ISEARCH_OPTS
__fzf_rename_vars __fzf_ctrl_t_default_command __fzf_find_file_command
__fzf_rename_vars FZF_CTRL_T_DEFAULT_COMMAND FZF_FIND_FILE_COMMAND

functions -e __fzf_rename_vars

function __fzf_command_var -a var program args
    argparse -N1 'c-clear' -- $argv
    set -l var $argv[1]
    set -l lower __(string lower $var)

    set -q _flag_clear
    and set -Ue $lower
    and set -Ue $var
    and return 0

    set -q $lower
    and command -sq $$lower
    and return 0

    set -l program $argv[2]
    set -l args $argv[3]

    command -sq $program
    and set -U $lower $program
    and set -Ux $var $program' '$args
    and return 0
end

__fzf_command_var FZF_FIND_FILE_COMMAND -- fd '--type f'
or __fzf_command_var FZF_FIND_FILE_COMMAND -- pt '-g "" --hidden --ignore .git'
or __fzf_command_var FZF_FIND_FILE_COMMAND -- rg '--files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2>/dev/null'
or __fzf_command_var FZF_FIND_FILE_COMMAND -- ag '-g "" --hidden --ignore .git'
or __fzf_command_var --clear FZF_FIND_FILE_COMMAND

if not set -Uq FZF_FIND_FILE_OPTS
    set -l preview \
        'test -d {}; and tree -C {}' \
        'string match -qe binary (file --mime {}); and echo {} is a binary file' \
        'bat --style=numbers --color=always {}' \
        'highlight -O ansi -l {}' \
        'coderay {}' \
        'rougify {}' \
        'cat {}'
    set -l preview '('(string join '; or ' $preview)') | head -200'
    set -Ux FZF_FIND_FILE_OPTS '--preview='$preview' --select -1 --exit 0'
end

__fzf_command_var FZF_CD_COMMAND -- fd '--type d'
or __fzf_command_var --clear FZF_CD_COMMAND

__fzf_command_var FZF_CD_WITH_HIDDEN_COMMAND -- fd '--type d'
or __fzf_command_var --clear FZF_CD_WITH_HIDDEN_COMMAND

set -Uq FZF_CD_OPTS
and set -Ux FZF_CD_OPTS "--preview='tree -C {} | head -200' --header-lines=1 --select-1 --exit-0"

set -Uq FZF_REVERSE_ISEARCH_OPTS
or set -Ux FZF_REVERSE_ISEARCH_OPTS "--preview='echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

function _halostatue_fish_fzf_bcd_widget -d 'cd backwards'
    pwd | \
        awk -v RS=/ '/\n/ {exit} {p=p $0 "/"; print p}' | \
        tail -r | \
        eval (__fzfcmd) +m --select-1 --exit-0 $FZF_BCD_OPTS | \
        read -l result

    test -z $result
    or cd $result

    commandline -f repaint
end

function _halostatue_fish_fzf_cdhist_widget -d 'cd to one of the previously visited locations'
    # Clear non-existent folders from cdhist.
    set -l buf
    for i in (seq 1 (count $dirprev))
        set -l dir $dirprev[$i]
        if test -d $dir
            set buf $buf $dir
        end
    end

    set dirprev $buf
    string join \n $dirprev | \
        tail -r | \
        sed 1d | \
        eval (__fzfcmd) +m --tiebreak=index --toggle-sort=ctrl-r $FZF_CDHIST_OPTS | \
        read -l result

    test -z $result
    or cd $result

    commandline -f repaint
end

function _halostatue_fish_fzf_select_widget -d 'fzf commandline job and print unescaped selection back to commandline'
    set -l cmd (commandline -j)
    test -z $cmd
    and return

    eval $cmd | \
        eval (__fzfcmd) -m --tiebreak=index --select-1 --exit-0 | \
        string join ' ' | \
        read -l result

    test -z $result
    or commandline -j -- $result

    commandline -f repaint
end

function _halostatue_fish_fzf_uninstall -e halostatue_fish_fzf_uninstall
    for var in FZF_CTRL_T_OPTS FZF_ALT_C_OPTS FZF_CTRL_R_OPTS \
        FZF_FIND_FILE_OPTS FZF_REVERSE_ISEARCH_OPTS \
        FZF_CTRL_T_DEFAULT_COMMAND FZF_FIND_FILE_COMMAND \
        FZF_CD_COMMAND FZF_CD_WITH_HIDDEN_COMMAND
        set -Uq $var
        and set -Ue $var

        set -Uq __(string lower $var)
        and set -Ue __(string lower $var)
    end

    functions -e fbr fco fkill fe fo fshow fstash (functions -a | command awk '/_halostatue_fish_fzf_/')
end
