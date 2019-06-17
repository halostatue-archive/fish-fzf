function fo -d 'Open or Edit a File'
    set -l out (fzf-tmux -l30 -- --query=$argv[1] --exit-0 --expect=ctrl-o,ctrl-e)

    set -l key $out[1]
    set -l file $out[2]

    if not test -z $file
        if test $key = ctrl-o
            open $file
        else
            set -l editor $EDITOR
            test -z $editor
            and set -l editor vim

            $editor $file
        end
    end
end
