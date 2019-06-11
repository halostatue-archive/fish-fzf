function fstash -d 'Deal with git stashes with fzf'
    # fstash - easier way to deal with stashes
    # type fstash to get a list of your stashes
    # enter shows you the contents of the stash
    # ctrl-d shows a diff of the stash against your current HEAD
    # ctrl-b checks the stash out as a branch, for easier merging
    set -l q ''

    while set -l out (
      git stash list --pretty="%gd %C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
      fzf --ansi --no-sort --query $q --print-query --expect=ctrl-d,ctrl-b \
        --header 'enter to view, ctrl-d to diff, ctrl-b to branch')
        set q $out[1]
        set -l k $out[2]
        set -l sha (string replace '^sha' '' (string split -n ' ' (string split ':' $out[3])[2])[1])

        test -z $sha
        and continue

        switch $k
            case ctrl-d
                git diff $sha
            case ctrl-b
                git stash branch 'stash-'$sha $sha
                break
            case '*'
                git stash show (string split -n ' ' $out[3])[1]
        end
    end
end
