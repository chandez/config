# oh-my-posh
eval "$(oh-my-posh init zsh --config $HOME/.config/non-terminal-minimal.omp.toml)"

# plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Bindkey  
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Alias
alias sso='aws sso login && aws codeartifact login --tool npm --repository ui --domain trustarc-ci --namespace "@trustarc"'
alias cls="clear && printf '\e[3J'"
alias update="brew update && brew upgrade"
alias ht="herdr"
alias clog="git clog 5"
alias ..="cd .."
alias ...="cd ../.."

# Functions
# ───────────── Branches ─────────────
# Switch branch; no argument goes to develop: gsw | gsw feature/x | gsw -c new-branch
gsw() {
  if [ $# -eq 0 ]; then
    git switch develop
  else
    git switch "$@"
  fi
}
gb()    { git branch "$@" }                    # gb | gb -d feat | gb -D feat
gba()   { git branch -a "$@" }                 # local + remote branches
gbd()   { git branch -d "$@" }                 # safe delete (merged only)
gbD()   { git branch -D "$@" }                 # force delete
gbc()   { git switch -c "$@" }                 # create + switch: gbc feature/x
gbm()   { git branch -m "$@" }                 # rename current: gbm new-name
gcur()  { git branch --show-current }          # print current branch
gbr()   { git branch --sort=-committerdate --format='%(committerdate:relative)%09%(refname:short)' | head -${1:-10} }  # recent branches

# Delete local branches already merged into develop (or the branch you pass)
gbclean() {
  local base=${1:-develop}
  local cur=$(git branch --show-current)
  git fetch --prune
  git branch --merged "$base" --format='%(refname:short)' \
    | grep -vxE "main|master|develop|$base|$cur" \
    | while read -r b; do git branch -d "$b"; done
}

# Fuzzy-pick a branch to switch to (needs fzf: brew install fzf)
gfb() {
  local b
  b=$(git branch --sort=-committerdate --format='%(refname:short)' | fzf --height 40% --reverse) || return
  git switch "$b"
}

# ───────────── Status / diff / log ─────────────
gst()   { git status }                         # show working tree status
gl()    { git log -${1:-5} }                   # full log, last N commits (default 5): gl 10
gcl()   { git clog ${1:-5} }                   # your custom 'clog' git alias, last N (default 5)
gd()    { git diff "$@" }
gds()   { git diff --staged "$@" }
glg()   { git log --oneline --graph --decorate -${1:-20} }
gla()   { git log --oneline --graph --decorate --all -${1:-20} }
gshow() { git show ${1:-HEAD} }

# ───────────── Add / commit ─────────────
ga()    { git add "${@:-.}" }                  # ga = add all, or ga file1 file2
gap()   { git add -p "$@" }                    # stage hunk by hunk
gc()    { git commit -m "$*" }                 # gc "fix login bug"
gca()   { git commit --amend --no-edit }       # add staged changes to last commit
gcam()  { git commit --amend -m "$*" }         # reword last commit
gac()   { git add -A && git commit -m "$*" }   # add everything + commit

# ───────────── Push / pull / fetch ─────────────
# Push; sets upstream automatically on a branch's first push
gpu() {
  if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    git push "$@"
  else
    git push -u origin "$(git branch --show-current)" "$@"
  fi
}
gp()    { git pull }                           # pull latest for current branch
gpf()   { git push --force-with-lease "$@" }   # safer force push
gf()    { git fetch --all --prune }
gpr()   { git pull --rebase "$@" }

# ───────────── Rebase / merge ─────────────
grb()   { git fetch origin && git rebase "origin/${1:-develop}" }  # rebase on latest develop
grbi()  { git rebase -i HEAD~${1:-5} }         # interactive, last N commits
grbc()  { git rebase --continue }
grba()  { git rebase --abort }
gm()    { git merge "$@" }
gma()   { git merge --abort }
gcp()   { git cherry-pick "$@" }

# ───────────── Stash ─────────────
gsh()   { git stash push -u -m "${*:-wip}" }   # stash incl. untracked, with message
gshp()  { git stash pop "$@" }
gshl()  { git stash list }
gsha()  { git stash apply "${1:-stash@{0}}" }

# ───────────── Undo ─────────────
gundo()    { git reset --soft HEAD~${1:-1} }   # undo last commit, keep changes staged
gunstage() { git restore --staged "${@:-.}" }
gdiscard() { git restore "${@:-.}" }           # discard unstaged changes (careful)
gnuke() {                                      # reset hard to remote; asks first
  local b=$(git branch --show-current)
  read -q "?Reset '$b' to origin/$b and lose local changes? [y/N] " || { echo; return 1 }
  echo; git fetch origin && git reset --hard "origin/$b"
}

# ───────────── Navigation ─────────────
groot() { cd "$(git rev-parse --show-toplevel)" }  # jump to repo root

# ───────────── General utilities ─────────────
mkcd()    { mkdir -p "$1" && cd "$1" }
up()      { cd $(printf '../%.0s' {1..${1:-1}}) }  # up 3 = cd ../../..
port()    { lsof -i tcp:"$1" }                     # what's using a port
killport() {
  local pids=$(lsof -ti tcp:"$1")
  [[ -n $pids ]] && echo "$pids" | xargs kill -9 && echo "Killed process on :$1" || echo "Nothing on :$1"
}
serve()   { python3 -m http.server ${1:-8000} }
reload()  { source ~/.zshrc && echo "zshrc reloaded" }
path()    { echo "$PATH" | tr ':' '\n' }

# Cheat sheet: list every function in this file with its comment
ghelp() { grep -E '^[a-zA-Z]+\(\)' ~/.zsh/git-functions.zsh | sed 's/() *{.*}//; s/ *#/  →/' }
