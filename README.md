# A Generic Buildpack for Cloud Foundry

Isn't it simply amazing to see these demos, where they throw a bunch of php,
ruby, java or python code at a Cloud Foundry site and it gets magically
turned into a running web applications.  Alas for me, life is often a wee
bit more complicated than that.  My projects always seem to required a few
extra libraries or they are even written in an dead scripting language like
Perl.

That's where `sourcey-buildpack` comes in. It allows you to easily compile
any libraries and binaries from source.  It takes care of putting everyting
into the right spot so that the end result happily lives in
`/home/vcap/sourcey` and it even knows that it does, and therefore does not
require any `LD_LIBRARY_PATH` or other special magic to make it work.

The sourcey-buildpack expects to find three special files in your application directory:

`SourceyBuild.sh` (optional) to compile all the binaries you need.

`SourceyBuildApp.sh` (optional) to prepare the actual application if this needs any prepping.

`SourceyStart.sh` (mandatory) to launch the application at runtime.

## `SourceyBuild.sh`

In this script you build your thirdparty software. At the most basic level, you just have
to make sure to install the result into `$PREFIX`.

You may want to use `$WORK_DIR` to unpack your source. And if you need other files from your application
you can find them in `$BUILD_DIR`.

For a classic autotools packaged application, your setup instructions might
look like this:

```shell
cd $WORK_DIR
wget http://cool-site.com/tool.tar.gz
tar xf tool.tar.gz
cd tool
./configure --prefix=$PREFIX
make install
cd ..
rm -r tool
```

When your script has run through, Sourcey goes to work.

1. It moves the content `$PREFIX` into `$STAGE_DIR/sourcey`, ready for packaging.

2. It creates a copy of `$STAGE_DIR/sourcey` in `$CACHE_DIR` and tags it
   with the md5 sum of your `SourceyBuild.sh`.  If you re-deploy the same
   app again, without changing `SourceyBuild.sh` the content of the
   `$CACHE_DIR` will be used in stead of rebuilding everything.

To make life a bit simpler still, Sourcey provides a few of helper functions:

### `buildAuto <url> [options]`

Does essentially the same build proces as described in the example above. If you
want to specify extra configure options, just add them as extra arguments at
the end of the function call:

```shell
buildAuto http://mysite/tool.tar.gz --default-answer=42 --switch-off
```

### `buildPerl <version>`

Is the most important function of them all. It creates the perl of your
choice.  How to write a decent web application without Perl.  Since most
Cloud Foundry setups are on Ubuntu lucid (10.04) stacks, perl is at version 5.10.1
which is about 100 years out of date. 

```sh
buildPerl 5.20.2
```

### `buildPerlModule [any cpanm option]`

This is a wrapper for `cpanm` which you can use to install extra perl modules.
The new modules will get installed into your freshly installed perl,
or if you have not done so, the system perl will be used and the modules
will go to `/home/vcap/sourcey/lib/perl5`.  Sourcey will take care of
setting the `PERL5LIB` variable accordingly.

## `SourceyBuildApp.sh`

This script can do whatever you deem necessary to get your actual
application into shape for execution.  Nothing will be cached.  If you push
an update for your application, this script will run again.


## `SourceyStart.sh`

This one gets executed when your application should be started. Sourcey will
take care of setting the `$PATH` variable so that all these shiny new 3rd party
tools get found automatically.  At the end of your `SourceyStart.sh` someone
should be listening port `$PORT` for incoming web requests.

In order for your application to integrate with the cloudfoundry
infrastructure, you want to json decode the content of the environment
variables `$VCAP_SERVICES` and `$VCAP_APPLICATION`.

## Debugging

If things are not going according to plan. You can put the folling variables
into your `SourceyBuild.sh` file.

`SOURCEY_VERBOSE=1` will cause all output generated at build time to be sent
to STDOUT.  Note that this does look like an environment variable, but
in fact the compile script runs `grep` on your `SourceyBuild.sh` to detect it.

`SOURCEY_REBUILD=1` will ignore any cached copy of your binaries and rebuild the lot.

## Example

The code in the example directory demonstrates how to setup a simple
Mojolicious Perl app.

The following instructions assume you have already setup a cloudfoundry
account and you have logged yourself in with `cf login`

```sh
cd example
cf push $USER-sourcey-demo -b https://github.com/oetiker/sourcey-buildpack
```


