export NODE_HOME="$HOME/vendor/node"
export PATH="$NODE_HOME/bin:$PATH:$HOME/bin:$HOME/node_modules/.bin"
export NODE_ENV=${NODE_ENV:-production}
export GRUNT_PORT=${PORT:-8080}	
export GRUNT_BROWSER=false
echo "Starting Server on port $GRUNT_PORT"
npm start
#grunt serve --hostname='0.0.0.0' --port=$PORT 