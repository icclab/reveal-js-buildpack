export NODE_HOME="$HOME/vendor/node"
export PATH="$NODE_HOME/bin:$PATH:$HOME/bin:$HOME/node_modules/.bin"
export NODE_ENV=${NODE_ENV:-production}

echo "Starting Server on port $PORT"
grunt serve --hostname 0.0.0.0 --port $PORT 