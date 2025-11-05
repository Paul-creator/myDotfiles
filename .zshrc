# zmodload zsh/zprof
# terminal style
export ZSH="/Users/paulkronegger/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z sudo)
source $ZSH/oh-my-zsh.sh

LANG="en_US.UTF-8"
# LANG="en_AT.UTF-8" // this makes errors for kitty so äüö won't work

# used for /opt/bin/gtkwave (for vhdl)
export PATH=/opt/bin:$PATH

alias eda="sh /Users/paulkronegger/iic-osic-tools/start_x.sh"
alias iic-osic-tools="eda"

# homebrew
export PATH=/opt/homebrew/bin:$PATH
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit -C
fi

# matlab
matlab ()
{
  appname=$(ls /Applications | grep -i matlab)
  "/Applications/$appname/bin/matlab" -nodisplay -nosplash $0
}

# andorid
export ANDROID_SDK_ROOT=/Users/paulkronegger/Library/Android/sdk
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID_SDK_ROOT/platform-tools:$PATH

# python
# alias python=python3
alias python_venv_create="python -m venv venv"
alias python_venv_activate="source venv/bin/activate"
export CLOUDSDK_PYTHON_SITEPACKAGES=1

# c
# To use the bundled libc++ please add the following LDFLAGS:
# export LDFLAGS="-L/opt/homebrew/opt/llvm/lib/c++ -Wl,-rpath,/opt/homebrew/opt/llvm/lib/c++"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"


# terraform
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

alias python="/opt/homebrew/bin/python3"
pip() {
    if [ "$1" = "i" ]; then
        shift
        /opt/homebrew/bin/pip3 install "$@"
    elif [ "$1" = "ls" ]; then
        shift
        /opt/homebrew/bin/pip3 list "$@"
    else
        /opt/homebrew/bin/pip3 "$@"
    fi
}


condainit() {
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  export CONDA_PREFIX="/Users/paulkronegger/miniconda3"
  __conda_setup="$('/Users/paulkronegger/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "/Users/paulkronegger/miniconda3/etc/profile.d/conda.sh" ]; then
          . "/Users/paulkronegger/miniconda3/etc/profile.d/conda.sh"
      else
          export PATH="/Users/paulkronegger/miniconda3/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<
}

# Google Cloud
if [ -f '/Users/paulkronegger/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/paulkronegger/google-cloud-sdk/completion.zsh.inc'; fi

# this line is nessesary till kubernets version 26
# https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Load Angular CLI autocompletion.
# Lazy Angular CLI completion
_ng_completion_lazy_loaded=0
_ng_completion_lazy_load() {
  if [ $_ng_completion_lazy_loaded -eq 0 ]; then
    _ng_completion_lazy_loaded=1
    source <(ng completion script)
  fi
}

ng() {
  _ng_completion_lazy_load
  command ng "$@"
}

# nerdctl
if type nerdctl &> /dev/null ; then
  source <(nerdctl completion zsh) >/dev/null 2>&1
fi
alias nerdctl-prune="nerdctl kill \$(nerdctl ps -q)"
alias nerdctl-rm-all="nerdctl-prune ; nerdctl rm \$(nerdctl ps -q -a)"
alias nerdctl-rm-vols="nerdctl-rm-all ; nerdctl volume rm \$(nerdctl volume ls -q)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/paulkronegger/Applications/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/paulkronegger/Applications/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/paulkronegger/Applications/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/paulkronegger/Applications/google-cloud-sdk/completion.zsh.inc'; fi

# flutter
export PATH="$PATH:/Users/paulkronegger/Applications/flutter/bin"

# ruby
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

# tmuxinator
export EDITOR='nvim'
alias mux=tmuxinator

# zoxide
eval "$(zoxide init zsh)"

# emacs
export PATH=$HOME/.config/emacs/bin:$PATH

# make tmux plugins available in terminal
export PATH=$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin:$PATH

#############
# functions #
#############
startOlama () {
  # Check if the container 'open-webui' already exists
  if [ "$(nerdctl ps -a -q -f name=open-webui)" ]; then
    # Start the existing container
    nerdctl start open-webui
  else
    # Create and run the container if it doesn't exist
    nerdctl run -d -p 3000:8080 --add-host=host.nerdctl.internal:host-gateway \
      -v open-webui:/app/backend/data \
      -e PDF_EXTRACT_IMAGES=true \
      --name open-webui --restart always ghcr.io/open-webui/open-webui:main
  fi
}
stopOlama () {
  nerdctl stop open-webui
}
updateOlama () {
  docker pull ghcr.io/open-webui/open-webui:main
  docker stop open-webui
  docker rm open-webui
  startOlama
}


function launch_k9s() {
  while true; do
    kubectl cluster-info > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      k9s
      break
    else
      sleep 5
    fi
  done
}

function port_forward_to_kubernetes_pod() {
    podLabel=$1 # eg.: "app=adminer"
    podNamespace=$2 # eg.: "default"
    PORT_LOCALHOST=$3 # eg.: 8080
    PORT_POD=$4 # eg.: 8080


    # Function to kill the process running on the specified port
    function kill_port_process() {
        if lsof -Pi :$PORT_LOCALHOST -sTCP:LISTEN -t >/dev/null; then
            echo "Killing process on port $PORT_LOCALHOST..."
            lsof -Pi :$PORT_LOCALHOST -sTCP:LISTEN -t | xargs kill -9
        else
          echo "Nothing to kill on port $PORT_LOCALHOST"
        fi
    }

    # Trap to catch termination signals and call kill_port_process
    trap kill_port_process SIGTERM SIGINT

    kill_port_process

    echo "Port-forwarding pod \"$podLabel\" in namespace \"$podNamespace\" on port $PORT_LOCALHOST:$PORT_POD"
    kubectl -n "$podNamespace" port-forward $(kubectl get pods -n "$podNamespace" -l "$podLabel" -o jsonpath="{.items[0].metadata.name}") $PORT_LOCALHOST:$PORT_POD &
    wait
}

function port_forward_bauabaua() {
    # Function to kill all child processes
    function kill_child_processes() {
        echo "Stopping all port-forwarding processes..."
        pkill -P $$
    }

    # Trap to catch termination signals and call kill_port_process (eg.: Ctrl+C)
    trap kill_port_process SIGTERM SIGINT

    port_forward_to_kubernetes_pod "app=adminer-app" "default" 8080 8080  &
    port_forward_to_kubernetes_pod "app=my-sql-app" "default" 3306 3306  &
    port_forward_to_kubernetes_pod  "statefulset.kubernetes.io/pod-name=elastic-search-cluster-es-default-0" "elastic" 9200 9200 &
    port_forward_to_kubernetes_pod "kibana.k8s.elastic.co/name=kibana-cluster" "elastic" 5601 5601  &
    
    # Wait for all background processes to finish
    wait
}

function port_forward_bauabaua_customer() {
    function kill_child_processes() {
        echo "Stopping all port-forwarding processes..."
        pkill -P $$
    }
    trap kill_port_process SIGTERM SIGINT
    port_forward_to_kubernetes_pod "app=marketplace-api-gate-way-customer-app" "default" 5050 5050 &
    port_forward_to_kubernetes_pod "app=marketplace-frontend-customer-app" "default" 4200 80
    wait
}


function port_forward_bauabaua_seller() {
    function kill_child_processes() {
        echo "Stopping all port-forwarding processes..."
        pkill -P $$
    }
    trap kill_port_process SIGTERM SIGINT
    port_forward_to_kubernetes_pod "app=marketplace-api-gate-way-seller-app" "default" 5051 5051 &
    port_forward_to_kubernetes_pod "app=marketplace-frontend-seller-app" "default" 4400 80
    wait
}


function port_forward_bauabaua_admin() {
    function kill_child_processes() {
        echo "Stopping all port-forwarding processes..."
        pkill -P $$
    }
    trap kill_port_process SIGTERM SIGINT
    port_forward_to_kubernetes_pod "app=marketplace-frontend-admin-app" "default" 5020 5020 &
    port_forward_to_kubernetes_pod "app=marketplace-frontend-seller-app" "default" 4300 80
    wait
}


function port_forward_bauabaua_webhooks() {
    function kill_child_processes() {
        echo "Stopping all port-forwarding processes..."
        pkill -P $$
    }
    trap kill_port_process SIGTERM SIGINT
    sh /Users/paulkronegger/Development/MarketPlace-Gitlab/MarketPlace-Backend/projects/apps/ApiGateWayWebhooks.WebApi/scripts/startNgrok.sh &
    port_forward_to_kubernetes_pod "app=marketplace-api-gate-way-webhooks-app" "default" 5052 5052 &
    sleep 2
    sh /Users/paulkronegger/Development/MarketPlace-Gitlab/MarketPlace-Backend/projects/apps/ApiGateWayWebhooks.WebApi/scripts/ngrokAndConnectWebhooks_dev.sh &
    wait
}


function delete_folders_named_bin() {
    find . -type d -name "bin" -exec rm -rf {} \;
}
function delete_folders_named_obj() {
    find . -type d -name "obj" -exec rm -rf {} \;
}

function tmuxs() {
    # Get a list of tmux sessions
    sessions=("${(@f)$(tmux list-sessions | awk '{print $1}')}")

    # Display a list of sessions with associated numbers
    echo "Select a tmux session to attach to:"
    for i in {1..$#sessions}; do
        echo "$i. ${sessions[i]}"
    done

    # Prompt the user for a session number
    echo -n "Enter the session number: "
    read session_number

    # Check if the user canceled the selection
    if [[ $session_number =~ ^[0-9]+$ && $session_number -le $#sessions ]]; then
        # Attach to the selected session
        tmux attach-session -t "${(@s: :)sessions[session_number]}"
    else
        echo "Invalid session number or selection canceled."
    fi
}

# search file within dic
search_dic() {
  maxdepth=2
  if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Error: Use this command with parameter. Eg.: \"search_dic pathToFolder optionalMaxFolderDepth\""
    return
  fi
  if [ $# -eq 2 ]; then
    maxdepth=$2
  fi

  folderPath=$1
  # "/Users/paulkronegger/Library/Application Support"

  find "$folderPath" -type d -not -path "*/node_modules/*" -not -path "*/.*/*" -maxdepth $maxdepth | fz
}

# tmux
fzf_open_tmux() {
    tmux new-session -c $(find ~/Development -type d -not -path "*/node_modules/*" -not -path "*/.*/*" -maxdepth 5 | fzf)
}
alias ft=fzf_open_tmux

function killport() {
  # Check if the required argument (port number) is provided
  if [ $# -ne 1 ]; then
    echo "Usage: $0 <port>"
    return
  fi

  # Get the port number from the command line argument
  port=$1

  # Find the process using the specified port
  pid=$(lsof -ti :$port)

  # Check if a process is using the specified port
  if [ -z "$pid" ]; then
    echo "No process found using port $port"
    return
  fi

  # Kill the process using the specified port
  kill $pid

  echo "Process with PID $pid killed"
}

export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm "$@"
}
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/paulkronegger/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# kubernetes
alias add_kubectl_completion="source <(kubectl completion zsh)"
if command -v helm > /dev/null 2>&1; then
    source <(helm completion zsh)
fi

# bun completions
[ -s "/Users/paulkronegger/.bun/_bun" ] && source "/Users/paulkronegger/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# dotnet-tools
export PATH="$PATH:/Users/paulkronegger/.dotnet/tools"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/paulkronegger/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# fzf completion
source <(fzf --zsh)

# wakeonlan completion
source `wakeonlan --autocomplete-source`

# ngrok completion
if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi
 
if [[ "$PWD" == "$HOME" ]]; then
  cd ~/Downloads/
fi

# for vhdl
export PATH=/opt/ghdl-macos-11-mcode/bin:$PATH

PATH="/Users/paulkronegger/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/paulkronegger/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/paulkronegger/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/paulkronegger/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/paulkronegger/perl5"; export PERL_MM_OPT;

alias youtube-transcript-en="yt-dlp --write-auto-sub --sub-lang en --convert-subs srt --skip-download"
alias youtube-transcript-de="yt-dlp --write-auto-sub --sub-lang de --convert-subs srt --skip-download"

if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
    exec tmux 
fi

# dotfiles
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# zprof
