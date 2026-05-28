#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

VIM_RUNTIME_DIR="${VIM_RUNTIME_DIR:-$HOME/opt/vimrc.runtime}"

# renovate: datasource=git-refs packageName=https://github.com/amix/vimrc currentValue=master
vim_runtime="master|46294d589d15d2e7308cf76c58f2df49bbec31e8|https://github.com/amix/vimrc.git"

plugins=(
  # renovate: datasource=git-refs packageName=https://github.com/mattn/emmet-vim currentValue=master
  "master|92ef2f74f4093edc99db5e9e4cf7e40116a85bd6|https://github.com/mattn/emmet-vim.git"
  # renovate: datasource=github-tags depName=preservim/tagbar versioning=semver-coerced
  "v3.1.1|6c3e15ea4a1ef9619c248c2b1eced56a47b61a9e|https://github.com/preservim/tagbar.git"
  # renovate: datasource=github-tags depName=preservim/nerdtree versioning=semver-coerced
  "7.1.3|9b465acb2745beb988eff3c1e4aa75f349738230|https://github.com/preservim/nerdtree.git"
  # renovate: datasource=github-tags depName=preservim/nerdcommenter versioning=semver-coerced
  "2.7.0|f575c18d05bb237ac6c62d972f10784b34be9bbe|https://github.com/preservim/nerdcommenter.git"
  # renovate: datasource=github-tags depName=vim-airline/vim-airline versioning=semver-coerced
  "v0.12|1586662296c9dc946083e17cb6a4ef0b3e7c0d68|https://github.com/vim-airline/vim-airline.git"
  # renovate: datasource=git-refs packageName=https://github.com/vim-airline/vim-airline-themes currentValue=master
  "master|77aab8c6cf7179ddb8a05741da7e358a86b2c3ab|https://github.com/vim-airline/vim-airline-themes.git"
  # renovate: datasource=github-tags depName=morhetz/gruvbox versioning=semver-coerced
  "v2.0.0|7fde9c10ceff684529c1646bf759af3a25bb576c|https://github.com/morhetz/gruvbox.git"
  # renovate: datasource=github-tags depName=psf/black versioning=semver-coerced
  "26.5.1|87928e6d6761a4a6d22250e1fee5601b3998086e|https://github.com/psf/black.git"
  # renovate: datasource=github-tags depName=vim-syntastic/syntastic versioning=semver-coerced
  "3.10.0|767b4f3b3ed9567c13568b9eff1b302638abedd9|https://github.com/vim-syntastic/syntastic.git"
  # renovate: datasource=github-tags depName=tpope/vim-fugitive versioning=semver-coerced
  "v3.7|96c1009fcf8ce60161cc938d149dd5a66d570756|https://github.com/tpope/vim-fugitive.git"
  # renovate: datasource=github-tags depName=xolox/vim-misc versioning=semver-coerced
  "1.17.6|3e6b8fb6f03f13434543ce1f5d24f6a5d3f34f0b|https://github.com/xolox/vim-misc.git"
  # renovate: datasource=github-tags depName=xolox/vim-session versioning=semver-coerced
  "2.13.1|9e9a6088f0554f6940c19889d0b2a8f39d13f2bb|https://github.com/xolox/vim-session.git"
  # renovate: datasource=github-tags depName=phpactor/phpactor versioning=semver-coerced
  "2025.12.21.1|dbad0a9aad7be178b914f430b573d970f271b455|https://github.com/phpactor/phpactor.git"
  # renovate: datasource=github-tags depName=tpope/vim-commentary versioning=semver-coerced
  "v1.3|34976d96b61d49cafce624cdd947317111c43bd8|https://github.com/tpope/vim-commentary.git"
  # renovate: datasource=github-tags depName=tpope/vim-surround versioning=semver-coerced
  "v2.2|aeb933272e72617f7c4d35e1f003be16836b948d|https://github.com/tpope/vim-surround.git"
  # renovate: datasource=github-tags depName=tpope/vim-repeat versioning=semver-coerced
  "v1.2|8106e142dfdc278ff3eaaadd7b362ad7949d4357|https://github.com/tpope/vim-repeat.git"
  # renovate: datasource=github-tags depName=github/copilot.vim versioning=semver-coerced
  "v1.59.0|a12fd5672110c8aa7e3c8419e28c96943ca179be|https://github.com/github/copilot.vim.git"
  # renovate: datasource=github-tags depName=ryanoasis/vim-devicons versioning=semver-coerced
  "v0.11.0|4db2a6ddaf66afa16105b7d2a13f81a9bb5ff9fc|https://github.com/ryanoasis/vim-devicons.git"
  # renovate: datasource=git-refs packageName=https://github.com/vwxyutarooo/nerdtree-devicons-syntax currentValue=master
  "master|1beb45a702d707ca258e1af181e5d1ec836392f2|https://github.com/vwxyutarooo/nerdtree-devicons-syntax.git"
)

clone_or_checkout_ref() {
  local ref="$1"
  local digest="$2"
  local repository="$3"
  local destination="$4"
  local checkout_ref="$ref"

  if [ -n "$digest" ]; then
    checkout_ref="$digest"
  fi

  if [ -d "$destination/.git" ]; then
    if [ -n "$digest" ]; then
      retry 3 git -C "$destination" fetch --depth 1 origin "$digest" || retry 3 git -C "$destination" fetch origin "$ref"
    else
      retry 3 git -C "$destination" fetch --depth 1 origin "$ref"
    fi
    retry 3 git -C "$destination" checkout --detach "$checkout_ref"
    retry 3 git -C "$destination" submodule update --init --recursive
    success "checked out $(basename "$destination") at $checkout_ref"
    return 0
  fi

  if [ -n "$digest" ]; then
    retry 3 git clone --no-checkout "$repository" "$destination"
    retry 3 git -C "$destination" fetch --depth 1 origin "$digest" || retry 3 git -C "$destination" fetch origin "$ref"
    retry 3 git -C "$destination" checkout --detach "$digest"
    retry 3 git -C "$destination" submodule update --init --recursive
  else
    retry 3 git clone --depth 1 --branch "$ref" --recurse-submodules "$repository" "$destination"
  fi
}

main() {
  if ! has git; then
    if [ "$DOTFILES_DRY_RUN" = "1" ]; then
      info "dry-run: git is not required for vim preview"
    else
      error "git is required to install vim runtime"
      return 1
    fi
  fi

  info "installing vim runtime under $VIM_RUNTIME_DIR"

  local runtime_ref runtime_digest runtime_repository
  IFS="|" read -r runtime_ref runtime_digest runtime_repository <<<"$vim_runtime"
  clone_or_checkout_ref "$runtime_ref" "$runtime_digest" "$runtime_repository" "$VIM_RUNTIME_DIR"

  if [ "$DOTFILES_DRY_RUN" = "1" ]; then
    info "dry-run: mkdir -p $VIM_RUNTIME_DIR/my_plugins"
  else
    mkdir -p "$VIM_RUNTIME_DIR/my_plugins"
  fi

  local plugin ref digest repository name destination
  for plugin in "${plugins[@]}"; do
    IFS="|" read -r ref digest repository <<<"$plugin"
    name="$(basename "$repository" .git)"
    destination="$VIM_RUNTIME_DIR/my_plugins/$name"
    clone_or_checkout_ref "$ref" "$digest" "$repository" "$destination" || warn "failed to install vim plugin $name"
  done

  safe_symlink "$DOTFILES_REPO_ROOT/dotfiles/vim/.config/dotfiles/vim/my_configs.vim" "$VIM_RUNTIME_DIR/my_configs.vim"

  if [ "$DOTFILES_DRY_RUN" = "1" ]; then
    info "dry-run: bash $VIM_RUNTIME_DIR/install_awesome_parameterized.sh $VIM_RUNTIME_DIR $USER"
    info "dry-run: link generated ~/.myvimrc to ~/.vimrc"
  elif [ -x "$VIM_RUNTIME_DIR/install_awesome_parameterized.sh" ]; then
    retry 3 bash "$VIM_RUNTIME_DIR/install_awesome_parameterized.sh" "$VIM_RUNTIME_DIR" "$USER" || warn "amix vim installer failed"
  else
    warn "amix vim installer not found; skipping generated ~/.vimrc"
  fi

  if [ "$DOTFILES_DRY_RUN" = "1" ]; then
    :
  elif [ -f "$HOME/.myvimrc" ]; then
    safe_symlink "$HOME/.myvimrc" "$HOME/.vimrc"
  else
    warn "$HOME/.myvimrc not found after vim install"
  fi

  success "vim setup complete"
}

main "$@"
