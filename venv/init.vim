let $PYTHONWARNINGS="ignore::DeprecationWarning"
set runtimepath^=~/.vim runtimepath+=~/opt/vimrc.runtime
let &packpath=&runtimepath
source ~/.vimrc