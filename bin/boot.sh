export NODE_HOME="$HOMR/vendor/node"
export PATH="$NODE_HOME/bin:$PATH:$HOME/bin:$HOME/node_modules/.bin"
export NODE_ENV=${NODE_ENV:-production}

exec grunt serve --hostname 0.0.0.0 --port $PORT 