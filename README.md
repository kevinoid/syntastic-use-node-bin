Use Node Bin for Syntastic
==========================

A [Vim](https://www.vim.org/) plugin which extends
[Syntastic](https://github.com/vim-syntastic/syntastic) to use checker
executables installed in per-project `node_modules/.bin` directories.  This is
necessary for some checkers (such as ESLint with local configuration or
plugins - see
[eslint/eslint#1238](https://github.com/eslint/eslint/issues/1238)) and for
systems where not all checkers are installed globally.


## Installation

After installing Syntastic, this plugin can be installed in the usual ways:

### Using [Vim Packages](https://vimhelp.org/repeat.txt.html#packages)

```sh
git checkout https://github.com/kevinoid/syntastic-use-node-bin.git ~/.vim/pack/whatever/start/syntastic-use-node-bin
```

### Using [Pathogen](https://github.com/tpope/vim-pathogen)

```sh
git checkout https://github.com/kevinoid/syntastic-use-node-bin.git ~/.vim/bundles/syntastic-use-node-bin
```

### Using [Vundle](https://github.com/VundleVim/Vundle.vim)

Add the following to `.vimrc`:
```vim
Plugin 'kevinoid/syntastic-use-node-bin'
```
Then run `:PluginInstall`.

### Using [vim-plug](https://github.com/junegunn/vim-plug)

Add the following to `.vimrc` between `plug#begin()` and `plug#end()`:
```vim
Plug 'kevinoid/syntastic-use-node-bin'
```


## Implementation

This plugin is currently implemented using the following algorithm:

    In FileType autocmd:
      For each checker of the buffer filetype:
        Search for checker executable in node_modules/.bin above buffer path
        If executable is found:
          Set b:syntastic_{lang}_{checker}_exec to path of executable

To debug the plugin, [`set g:syntastic_debug =
33`](https://github.com/vim-syntastic/syntastic/blob/0d25f4fb/doc/syntastic.txt)
in `.vimrc` and look for lines starting with `SyntasticUseNodeBin: ` in
[`:messages`](https://vimhelp.org/message.txt.html#%3Amessages).

To customize the behavior of this plugin, users can `set
g:syntastic_use_node_bin = 0` to disable `autocmd` registration, then call
`SyntasticUseNodeBin` with the desired filetype, checkers, and path to set.


## Alternative Approaches

Before implementing this plugin, I had investigated several approaches that
others may find preferable:

* **ESLint Only:** Install the
  [`eslint-cli`](https://www.npmjs.com/package/eslint-cli) package globally so
  that the `eslint` command runs project-local `eslint` when available.
* Add [`npx`](https://www.npmjs.com/package/npx) to the start of
  `g:syntastic_<language>_<checker>_exe`.  This requires `npx` to be installed
  globally.  It also requires setting `g:syntastic_<language>_<checker>_exec`
  to a globally installed version of the checker, so that both `IsAvailable()`
  and `GetVersion()` are satisfied.  This may also cause problems with version
  mismatches between the global and per-project checker versions.
* Set `g:syntastic_<language>_<checker>_exe` to `npm run <checker> --`.
  However, this requires/assumes `package.json` defines a script with the
  checker name, which is probably not a safe assumption for most checkers.
  Also, As with `npx` above, it requires setting
  `g:syntastic_<language>_<checker>_exec` to a globally installed version of
  the checker, so that both `IsAvailable()` and `GetVersion()` are satisfied.
  This may also cause problems with version mismatches between the global and
  per-project checker versions.
* Include `node_modules/.bin` in `$PATH` globally (e.g. using
  [`node_modules.vim`](https://github.com/rliang/node_modules.vim) or [in your
  shell](https://coderwall.com/p/i5z1cg/automatically-update-path-with-proper-node_modules-bin)).
  Adding `node_modules/.bin` to `$PATH` is inadvisable, since it can lead to
  [unpleasant
  surprises](https://github.com/npm/npm/issues/957#issuecomment-237064313) and
  security issues when POSIX commands run `npm`-installed executables instead
  of system binaries.  Also, implementations which add `node_modules/.bin` to
  `$PATH` once doesn't correctly handle editing files from different projects
  (either serially or simultaneously) or paths outside the current project.
  In theory this could be worked around by managing `$PATH` per-buffer,
  although I am not aware of a current implementation which does this.
* Set `g:syntastic_shell` to a script which adds `node_modules/.bin` to `$PATH`
  before invoking the command.  If the script located `node_modules/.bin` based
  on `$PWD` it would not work correctly for files opened from outside their
  project.  If not, it would have to extract the file location from the command
  string, which could be difficult.  This approach would also interfere with
  other uses of `g:syntastic_shell` (either user use or if other plugins also
  modified `g:syntastic_shell`) unless the original `g:syntastic_shell` were
  be passed to the modified `g:syntastic_shell` and invoked after changing
  `$PATH`.


## Collaboration

I would appreciate constructive feedback and suggestions.  I am also willing to
collaborate with any Syntastic developers who might be interested in
incorporating this functionality into Syntastic so that it doesn't require a
separate plugin.


## See Also

If you have read this far, you may also be interested in these other plugins:

- [syntastic-detect-checkers](https://github.com/kevinoid/syntastic-detect-checkers)
  \- Detect checkers to use based on the file being edited.
- [vim-node](https://github.com/moll/vim-node) - Vim enhancements for Node.js.
