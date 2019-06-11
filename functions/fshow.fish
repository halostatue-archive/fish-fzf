function fshow -d 'Git Commit Browser with fzf'
    argparse -n (status function) 'p/preview' -- $argv

    set -l _log_hash "echo '{}' | grep -o '[a-f0-9]\{7\}' | head -1"
    set -l _view_log {$_log_hash}" | xargs -I % sh -c 'git show --color=always %'"

    if test -z $_flag_preview
        git log --graph --color=always \
            --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" $argv |
        fzf --ansi --no-sort --reverse --tiebreak=index \
            --header 'enter to view, ctrl-s to toggle sort' \
            --bind 'ctrl-s:toggle-sort' \
            --bind 'enter:execute:'{$_view_log}' | less -R'
    else
        command -sq diff-so-fancy
        and set _view_log {$_log_hash}" | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

        git log --color=always \
            --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" $argv |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview={$_view_log} \
            --header 'enter to view, ctrl-y to copy hash' \
            --bind 'enter:execute:'{$_view_log}' | less -R' \
            --bind 'ctrl-y:execute:'{$_log_hash}' | pbcopy'
    end
end
