# Handle the case of fzf being installed directly.
command -sq fzf
or if test -d $HOME/.fzf/bin
    contains -- $HOME/.fzf/bin $fish_user_paths
    or set fish_user_paths $fish_user_paths $HOME/.fzf/bin
else
    exit
end

function _halostatue:fish:fzf:upgrade
    # Rename variables from old to new, and ensure that the old variable is no
    # longer present even in universal variables. Also, ensure that the new
    # variable is no longer present in universal variables before exporting to
    # a global variable.
    function _halostatue:fish:fzf:upgrade:vars -a old new
        set -l tmp

        set -q $old; and begin
            # record tmp as the most shadwed version of old
            set tmp $$old

            while set -q $old
                set -e $old
            end
        end

        set -q $new; and begin
            # record tmp as the most shadowed version of new
            set tmp $$new

            while set -q $new
                set -e $new
            end
        end

        test -z $tmp; or set -gx $new $tmp
    end

    _halostatue:fish:fzf:upgrade:vars FZF_CTRL_T_OPTS FZF_FIND_FILE_OPTS
    _halostatue:fish:fzf:upgrade:vars FZF_ALT_C_OPTS FZF_CD_OPTS
    _halostatue:fish:fzf:upgrade:vars FZF_CTRL_R_OPTS FZF_REVERSE_ISEARCH_OPTS
    _halostatue:fish:fzf:upgrade:vars __fzf_ctrl_t_default_command __fzf_find_file_command
    _halostatue:fish:fzf:upgrade:vars FZF_CTRL_T_DEFAULT_COMMAND FZF_FIND_FILE_COMMAND

    functions -e _halostatue:fish:fzf:upgrade:vars (status function)
end

_halostatue:fish:fzf:upgrade

function _halostatue:fish:fzf:cmd:var -a var program args
    argparse -N1 'c-clear' -- $argv

    set -l var $argv[1]
    set -l lower __(string lower $var)

    test -z $_flag_clear; or begin
        set -ge $lower
        set -ge $var
        return 0
    end

    test -z $lower; or begin
        command -sq $$lower; and return 0
    end

    set -l program $argv[2]
    set -l args $argv[3]

    command -sq $program; and begin
        set -g $lower $program
        set -gx $var $program' '$args
        return 0
    end
end

function _halostatue:fish:fzf:configure:find_file
    _halostatue:fish:fzf:cmd:var FZF_FIND_FILE_COMMAND -- fd '--type f'
    or _halostatue:fish:fzf:cmd:var FZF_FIND_FILE_COMMAND -- pt '-g "" --hidden --ignore .git'
    or _halostatue:fish:fzf:cmd:var FZF_FIND_FILE_COMMAND -- rg '--files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2>/dev/null'
    or _halostatue:fish:fzf:cmd:var FZF_FIND_FILE_COMMAND -- ag '-g "" --hidden --ignore .git'
    or _halostatue:fish:fzf:cmd:var --clear FZF_FIND_FILE_COMMAND

    if not set -gq FZF_FIND_FILE_OPTS
        set -l preview \
            'string match -qe binary (file --mime {}) && echo {} is a binary file' \

        if command -sq bat
            set preview $preview 'bat --style=numbers --color=always {}'
        else if command -sq highlight
            set preview $preview 'highlight -O ansi -l {}'
        else if command -sq coderay
            set preview $preview 'coderay {}'
        else if command -sq rougify
            set preview $preview 'rougify {}'
        end

        set preview $preview 'cat {}' 'tree -C {}'
        set preview (string join ' 2>&1 || ' $preview)' | head -200'
        # set preview (string join ' 2>/dev/null || ' $preview)' | head -200'
        set -gx FZF_FIND_FILE_OPTS "--preview='"$preview"' --select-1 --exit-0"
    end
end

function _halostatue:fish:fzf:configure:chdir
    _halostatue:fish:fzf:cmd:var FZF_CD_COMMAND -- fd '--type d'
    or _halostatue:fish:fzf:cmd:var --clear FZF_CD_COMMAND

    _halostatue:fish:fzf:cmd:var FZF_CD_WITH_HIDDEN_COMMAND -- fd '--type d --hidden --follow --exclude ".git"'
    or _halostatue:fish:fzf:cmd:var --clear FZF_CD_WITH_HIDDEN_COMMAND

    set -gq FZF_CD_OPTS
    and set -gx FZF_CD_OPTS "--preview='tree -C {} | head -200' --header-lines=1 --select-1 --exit-0"
end

function _halostatue:fish:fzf:configure:reverse_isearch
    set -gq FZF_REVERSE_ISEARCH_OPTS
    or set -gx FZF_REVERSE_ISEARCH_OPTS "--preview='echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
end

_halostatue:fish:fzf:configure:chdir
_halostatue:fish:fzf:configure:find_file
_halostatue:fish:fzf:configure:reverse_isearch

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
        while set -q $var
            set -e $var
        end

        set var __(string lower $var)

        while set -q $var
            set -e $var
        end
    end

    functions -e fbr fco fkill fe fo fshow fstash (functions -a | command awk '/_halostatue:fish:fzf:/')
end
