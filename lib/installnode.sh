install_nodejs() {
  local version="${1:-}"
  local install_dir="${2:-./vendor/node}"

  echo "Downloading and installing node $version..."
  local download_url="https://s3pository.heroku.com/node/v$version/node-v$version-$os-$cpu.tar.gz"
  curl $download_url --silent --fail --retry 5 --retry-max-time 15 -o /tmp/node.tar.gz 
  echo "Downloaded [$download_url]"
  tar xzf /tmp/node.tar.gz -C /tmp
  rm -rf $install_dir/*
  mv /tmp/node-v$version-$os-$cpu/* $install_dir
  chmod +x $install_dir/bin/*
}

install_node_modules() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir
    echo "Pruning any extraneous modules"
    npm prune --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing node modules (package.json + shrinkwrap)"
    else
      echo "Installing node modules (package.json)"
    fi
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}

rebuild_node_modules() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir
    echo "Rebuilding any native modules"
    npm rebuild 2>&1
    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing any new modules (package.json + shrinkwrap)"
    else
      echo "Installing any new modules (package.json)"
    fi
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}

build_dependencies() {
  local build_dir=${1:-}

  ## check if prebuild modules are available
  [ -e "$build_dir/node_modules" ] && PREBUILD=true || PREBUILD=false

  if $PREBUILD; then
    echo "Prebuild detected (node_modules already exists)"
    rebuild_node_modules "$build_dir"
  else
    install_node_modules "$build_dir"
  fi
}

fail_invalid_package_json() {
  if ! cat ${1:-}/package.json | $JQ "." 1>/dev/null; then
    error "Unable to parse package.json"
    return 1
  fi
}

warnings=$(mktemp -t revealjs-buildpack-XXXX)

warning() {
  local tip=${1:-}
  local url=${2:-http://docs.cloudfoundry.org/buildpacks/node/node-tips.html}
  echo "- $tip" >> $warnings
  echo "  $url" >> $warnings
  echo "" >> $warnings
}

warn_node_engine() {
  local node_engine=${1:-}
  if [ "$node_engine" == "" ]; then
    warning "Node version not specified in package.json" 
  elif [ "$node_engine" == "*" ]; then
    warning "Dangerous semver range (*) in engines.node" 
  elif [ ${node_engine:0:1} == ">" ]; then
    warning "Dangerous semver range (>) in engines.node" 
  fi
}

warn_prebuilt_modules() {
  local build_dir=${1:-}
  if [ -e "$build_dir/node_modules" ]; then
    warning "node_modules checked into source control" "https://docs.npmjs.com/misc/faq#should-i-check-my-node-modules-folder-into-git"
  fi
}

warn_missing_package_json() {
  local build_dir=${1:-}
  if ! [ -e "$build_dir/package.json" ]; then
    warning "No package.json found"
  fi
}

warn_old_npm() {
  local npm_version="$(npm --version)"
  if [ "${npm_version:0:1}" -lt "2" ]; then
    local latest_npm="$(curl --silent --get --retry 5 --retry-max-time 15 https://semver.herokuapp.com/npm/stable)"
    warning "This version of npm ($npm_version) has several known issues - consider upgrading to the latest release ($latest_npm)" "https://devcenter.heroku.com/articles/nodejs-support#specifying-an-npm-version"
  fi
}

warn_untracked_dependencies() {
  local log_file="$1"
  if grep -qi 'gulp: not found' "$log_file"; then
    warning "Gulp may not be tracked in package.json" "https://devcenter.heroku.com/articles/troubleshooting-node-deploys#ensure-you-aren-t-relying-on-untracked-dependencies"
  fi
  if grep -qi 'grunt: not found' "$log_file"; then
    warning "Grunt may not be tracked in package.json" "https://devcenter.heroku.com/articles/troubleshooting-node-deploys#ensure-you-aren-t-relying-on-untracked-dependencies"
  fi
  if grep -qi 'bower: not found' "$log_file"; then
    warning "Bower may not be tracked in package.json" "https://devcenter.heroku.com/articles/troubleshooting-node-deploys#ensure-you-aren-t-relying-on-untracked-dependencies"
  fi
}

install_node() {
  local build_dir=${1:-}
  local install_dir=${2:-$build_dir/vendor/node}

  
  mkdir -p $install_dir
  
  ## Failures that should be caught immediately
  fail_invalid_package_json "$build_dir"
  warn_prebuilt_modules "$build_dir"
  warn_missing_package_json "$build_dir"
  ## read requested node version
  local node_engine=$(read_json "$build_dir/package.json" ".engines.node")
  echo "engines.node (package.json):  ${node_engine:-unspecified}"
  # Resolve node version using semver.io
  local node_version=$(curl --silent --get --data-urlencode "range=${node_engine}" https://semver.io/node/resolve)
  echo "node version (semver.io):  ${node_version:-unspecified}"

  warn_node_engine "$node_version"
  install_nodejs "$node_version" "$install_dir"


}

