" Entry point for the pinned amix/vimrc runtime installed by the dotfiles setup.
let s:dotfiles_vim_runtime = expand('$HOME/opt/vimrc.runtime')

execute 'set runtimepath+=' . fnameescape(s:dotfiles_vim_runtime)
execute 'source ' . fnameescape(s:dotfiles_vim_runtime . '/vimrcs/basic.vim')
execute 'source ' . fnameescape(s:dotfiles_vim_runtime . '/vimrcs/filetypes.vim')
execute 'source ' . fnameescape(s:dotfiles_vim_runtime . '/vimrcs/plugins_config.vim')
execute 'source ' . fnameescape(s:dotfiles_vim_runtime . '/vimrcs/extended.vim')

try
  execute 'source ' . fnameescape(s:dotfiles_vim_runtime . '/my_configs.vim')
catch
endtry
