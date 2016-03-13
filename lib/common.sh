# Helper functions
# generate output
info() {
  echo "       $*"
}

# format output and send a copy to the log
output() {
  local logfile="$1"

  while read LINE;
  do
    echo "       $LINE"
    echo "$LINE" >> "$logfile"
  done
}

header() {
  echo ""
  echo "-----> $*"
}

error() {
  echo " !     $*" >&2
  echo ""
}

# get system info
get_os() {
  uname | tr A-Z a-z
}

get_cpu() {
  if [[ "$(uname -p)" = "i686" ]]; then
    echo "x86"
  else
    echo "x64"
  fi
}

os=$(get_os)
cpu=$(get_cpu)

# JSON tooling
export JQ="$BP_DIR/vendor/jq-$os"

read_json() {
  local file=$1
  local key=$2
  if test -f $file; then
    cat $file | $JQ --raw-output "$key // \"\"" || return 1
  else
    echo ""
  fi
}

export_env_dir() {
  local env_dir=$1
  if [ -d "$env_dir" ]; then
    local whitelist_regex=${2:-''}
    local blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
    if [ -d "$env_dir" ]; then
      for e in $(ls $env_dir); do
        echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
        export "$e=$(cat $env_dir/$e)"
        :
      done
    fi
  fi
}

