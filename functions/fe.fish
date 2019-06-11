function fe -d 'fzf: edit files selected by tmux'
    set -l files (fzf-tmux -l30 -- --query=$argv[1] --multi --select-1 --exit-0)

    set -l editor $EDITOR
    test -z $editor
    and set -l editor vim

    test -z $files
    or $editor $files
end
