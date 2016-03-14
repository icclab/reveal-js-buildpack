# A simple buildpack to run reveal.js presentations

This is a simple buildpack to push a reveal.js project to heroku or cloud foundry.

The directory layout at build time:

```
/home
   /vcap (aka $HOME)

/tmp
   /cache (aka $CACHE_DIR)
/tmp
   /buildpacks/
      /reveal-js-buildpack (aka $BUILDPACK_DIR)
/tmp
   /staged (aka $STAGE_DIR)
      /app (aka $BUILD_DIR) will be packaged as a dropplet
         /vendor
            /node (aka $NODE_HOME)
      /reveal (aka $REVEAL_DIR) used to temporary clone reveal.js repo
      /content (aka $BACKUP_DIR) used to temporary backup presentation content
      
```

The `/home/vcap` directory is where your application will reside at runtime. By compiling your binaries into that location, their world view will be intact at runtime as well.

The `/tmp/staged` directory gets packaged up and transfered to the run-time
environment.  At first only your application will be sitting there (in the
`/tmp/staged/app` directory).

The content of the `/tmp/cache` directory will made available whenever you
push your application again.  You can use this location to cache fetched resources or compiled binaries and restore them when you push an update without changing the dependent files (e.g. the `package.json` of the reveal.js directory)

Node will be installed by the helper scripts in `lib/installnode.sh` to `/tmp/staged/app/vendor/node`.

### Helpers

To make life a bit simpler still, the buildpack provides a few of helper functions:

#### `lib/common.sh`

contains a lot of functions used during the buildpack compile phase.
e.g. printing headers, errors or reading json files.

#### `lib/installnode.sh`

contains all the functions require to install node and rebuild dependencies (node modules), based on package.json of the reveal.js project.

#### `lib/cache.sh`

Helper functions to cache and restore dependent files, like the node_modules.


## The `boot.sh` script

This gets executed when your application should be started. 
Will be used to startup the grunt server at runtime. Has to be copied to `$BUILD_DIR` at compile time from `bin/boot.sh`.

At the end of your `boot.sh` the webserver will be listening on port
`$PORT` for incoming web requests.

In order for your application to integrate with the Cloud Foundry
infrastructure, you want to JSON decode the content of the environment
variables `$VCAP_SERVICES` and `$VCAP_APPLICATION`.

The directory layout at runtime.

```
/home
   /vcap
      /app  (aka $HOME !!!)
         boot.sh
         index.html (your presentation)
         (... content of reveal.js repository)
         node_modules (generated at compile time)
         vendor/
            node/ (node.js installation)
```

## Example

The index.html in the example directory demonstrates how to deploy a simple.

The following instructions assume you have already setup a Cloud Foundry
account and you have logged yourself in with `cf login`

```sh
cd example
cf push team<X>-revealjs-demo -b https://github.com/<yourorg>/reveal-js-buildpack
```
