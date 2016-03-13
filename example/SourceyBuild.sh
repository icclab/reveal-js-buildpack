# if you want to see what happens in more detail
#SOURCEY_VERBOSE=1

# if you want to force sourcey to rebuild everything
#SOURCEY_REBUILD=1

#echo "Node version: `node --version`"
#echo "OS: $os"
#echo "CPU: $cpu"
echo "Environment "
env
echo "----------------------------------------"
echo "=tree WORKD_DIR"
ls -R $WORK_DIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/' 
echo "=tree STAGE_DIR"
ls -R $STAGE_DIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'  
#echo "=tree CACHE_DIR"
#ls -R $CACHE_DIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
echo "=tree ENV_DIR"
ls -R $ENV_DIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'

#echo "=ls /sbin"
#ls -al /sbin
#echo "=ls /usr/bin"
#ls -al /usr/bin
#echo "=ls /usr/sbin"
#ls -al /usr/sbin


#echo "=tree tmp"
#ls -R /tmp | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
#echo "=tree var"
#ls -R /var | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
echo "END list"

# create a copy of perl
buildPerl 5.20.2

# and this one is entirely unrelated, and just here
# to show how to build a library. we do not actually need
# it for the example code in app-simple.pl to work
#buildAuto https://ftp.postgresql.org/pub/source/v9.4.1/postgresql-9.4.1.tar.bz2

# build the Mojolicious perl module
# this calles cpanm internally ... 
buildPerlModule Mojolicious Mojo::Pg

echo "=ls WORK_DIR=$WORK_DIR"
ls -al $WORK_DIR

echo "=ls WORK_DIR=$STAGE_DIR"
ls -al $STAGE_DIR
echo "=ls WORK_DIR=$STAGE_DIR/app"
ls -al $STAGE_DIR/app
echo "=ls WORK_DIR=$STAGE_DIR/logs"
ls -al $STAGE_DIR/logs
echo "=ls WORK_DIR=$STAGE_DIR/tmp"
ls -al $STAGE_DIR/tmp

#echo "=tree PREFIX_DIR"
#ls -R $PREFIX | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'  
#echo "=ls PREFIX=$PREFIX"
#ls -al $PREFIX

echo "=ls WORK_DIR=$CACHE_DIR"
ls -al $CACHE_DIR



