# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"


plugins=(git zoxide 1password pnpm)

source $ZSH/oh-my-zsh.sh


alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

export PATH="$HOME/.local/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/benno/.lmstudio/bin"
# End of LM Studio CLI section

export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
source ~/completion-for-pnpm.bash


#####################
## SHELL FUNCTIONS ##
#####################

odysseus() (
    set -euo pipefail
    cd "${ODYSSEUS_DIR:-$HOME/.local/share/odysseus}"

    # replace the existing venv check with this
    if ! venv/bin/python3 -c "" 2>/dev/null; then
    rm -rf venv
    python3 -m venv venv
    fi

    # reinstall deps only when requirements.txt changed
    stamp="venv/.requirements.sha256"
    if ! sha256sum --check --status "$stamp" 2>/dev/null; then
    venv/bin/pip install -r requirements.txt
    sha256sum requirements.txt > "$stamp"
    fi

    venv/bin/python setup.py

    venv/bin/python -m uvicorn app:app --host 127.0.0.1 --port 7000 "$@" &>/dev/null & disown
)
