# halostatue/fish-fzf

A quick plugin for [fish shell][] that provides some useful default
configuration options for [fzf][] over and above [jethrokuan/fzf][].

[![Version][]][]

## Installation

Install with [Fisher][] (recommended):

```fish
fisher add halostatue/fish-fzf
```

<details>
<summary>Not using a package manager?</summary>

---

Copy `conf.d/*.fish` to your fish configuration directory preserving the
directory structure.
</details>

### System Requirements

- [fish][] 3.0+
- [jethrokuan/fzf][] (handled by [Fisher][])
- [fzf][]

## System Configuration (conf.d)

- If `fzf` is installed in `$HOME/.fzf`, adds `$HOME/.fzf/bin` to
  `$fish_user_paths` and updates `$MANPATH` appropriately.

- Sets a useful universal value for `$FZF_FIND_FILE_COMMAND` if one of
  [pt (the platinum searcher)][], [rg (ripgrep)][], or [ag (the silver
  searcher)][] are installed.

- Sets a useful universal value for `$FZF_FIND_FILE_OPTS` that will take
  advantage of [bat][], [highlight][], rougify, coderay, `cat`, or `tree`.

- Sets a useful universal value for `$FZF_CD_OPTS` using `tree`.

- Sets a useful universal value for `$FZF_REVERSE_ISEARCH_OPTS` offering a
  hidden preview activated with `?`.

### Completion Widgets

None of the included completion widgets are bound by default.

#### _halostatue_fish_fzf_bcd_widget

Use fzf to select a parent directory from the current directory.

#### _halostatue_fish_fzf_cdhist_widget

Use fzf to choose a directory that has previously been visited.

#### _halostatue_fish_fzf_select_widget

Run the current command-line which produces output piped through fzf. Replace
the command-line with the unescaped selection.

## Functions

Most of these functions are translated to fish from zsh implementations from
the fzf wiki [examples][]. Many of the completion widgets in
`conf.d/halostatue_fish_fzf.fish` are from the fzf wiki [Fish examples][].

### fbr

Checkout a git branch (including remote branches), sorted by the most recent
commit, limit of the last 30 branches.

```shell
fbr
```

### fco

Checkout a git branch or tag. If `-p` or `--preview` is provided, displays a
preview showing the commits between the tag/branch and HEAD.

```shell
fco [-p|--preview]
```

### fe

Open the selected file with the default editor, bypassing the fuzzy finder if
there’s only one match and exiting if there’s no match.

```shell
fe [PATTERN]
```

### fo

Open the selected file with `open` (when `Ctrl-O` is pressed in the finder) or
the default editor (when `Ctrl-E` or `Enter` are pressed in the finder).

```shell
fo [PATTERN]
```

### fkill

Shows processes that your user can kill and kills the selected process.

```shell
fkill
```

### fshow

Browse commits. With `-p` or `--preview`, shows a preview.

```shell
fshow
fshow -p
```

## fstash

A git stash browser. `Enter` shows the contents of the stash; `Ctrl-D` shows a
diff of the stash against your current HEAD; `Ctrl-B` checks the stash out as
a branch, for easier merging.

## License

[MIT](LICENCE.md)

[fish shell]: https://fishshell.com "friendly interactive shell"
[fzf]: https://github.com/junegunn/fzf
[jethrokuan/fzf]: https://github.com/jethrokuan/fzf
[Version]: https://img.shields.io/github/tag/halostatue/fish-fzf.svg?label=Version
[![Version][]]: https://github.com/halostatue/fish-fzf/releases
[Fisher]: https://github.com/jorgebucaran/fisher
[fish]: https://github.com/fish-shell/fish-shell
[pt (the platinum searchr)]: https://github.com/monochromegane/the_platinum_searcher
[rg (ripgrep)]: https://github.com/BurntSushi/ripgrep
[ag (the silver searcher)]: https://github.com/ggreer/the_silver_searcher
[highlight]: http://www.andre-simon.de/doku/highlight/en/highlight.php
[bat]: https://github.com/sharkdp/bat
[examples]: https://github.com/junegunn/fzf/wiki/Examples
[Fish examples]: https://github.com/junegunn/fzf/wiki/Examples-(fish)
