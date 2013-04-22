StrongLoop Node BuildPack
=========================

This repository is a StrongLoop Node buildpack to allow you to run
StrongLoop Node as a runtime "service" on a few different PaaS
environments. Currently supported PaaS environments are:

    SalesForce's Heroku
    Red Hat's OpenShift
    VMWare's CloudFoundry


Okay, now onto how to use this buildpack.


Copy StrongLoop Node configuration files [OPTIONAL]
---------------------------------------------------
This step is strictly optional - you don't need to copy over StrongLoop
Node configuration files. However if you wish to control which StrongLoop
version you want to install + what deployment mode to run in you will need
to provide StrongLoop specific configuration files, so in such as case
using the sample configuration is a good start.

    #  Copy the config files to your app in a strongloop/ directory.
    cd myapp
    cp -r $local_path_to_this_buildpack/samples/strongloop .


Selecting a StrongLoop Node version to use/install
--------------------------------------------------
If you add a strongloop directory (with the configuration marker
files) to your application, then that configuration is automatically used
by the StrongLoop installer specific to the type of PaaS you are
deploying on. 

    Example: To install StrongLoop Node version 1.0.0-0.2.beta
    echo -e "1.0.0-0.2.beta\n" >> strongloop/VERSION

The platform specific installers in this buildpack will use that VERSION
file to download and extract the specific StrongLoop Node version if it
is available and automatically setup the paths to use the node/npm
binaries from the specific install directory.


Selecting the application's Deployment Mode
-------------------------------------------
To select the deployment mode, just edit or add the environment to your
application in a file named strongloop/NODE_ENV

    Example: To run in production mode
    echo -e "production\n" >> strongloop/NODE_ENV

The platform specific installers in this buildpack will use that NODE_ENV
file and set the environment for npm to install and run your application.

Okay, now onto how you can get a StrongLoop supported Node.js version
running on the different PaaS environments.


Deploying on Heroku:
--------------------
On Heroku, first optionally copy and edit the config files as shown above,
then create an app using this buildpack and finally push to your Heroku app.
That's the tl;dr version - detailed steps below.


Create an account on http://heroku.com/

Install the Heroku toolbelt

     See: https://toolbelt.heroku.com/ for instructions

Login into the Heroku:

     heroku login

Clone the sample application or create your application:

     git clone git://github.com/ramr/strongloop-paas-quickstart.git dynode
     # OR  git clone ${path_to_your_awesome_app}.git dynode
     # OR  cp -r ~/myapp/*  dynode

Change directory to your application and optionally copy over the
StrongLoop sample configuration

    cd dynode
    cp -r $buildpackdir/samples/strongloop .
    git add strongloop
    git commit . -m 'Added StrongLoop config files'

For portability reasons, it is highly recommended that you use StrongLoop
variables or alternatively a combination of the platform specific variables
so that you may easily migrate your app between the different PaaS
enviroments.

Example: For an express app, use

    zapp.listen(process.env.STRONGLOOP_PORT, process.env.STRONGLOOP_HOST,
                function() { } );
    #  OR
    zapp.listen(process.env.STRONGLOOP_PORT ||  \
                  process.env.VCAP_PORT || process.env.PORT || 3000,
                process.env.STRONGLOOP_HOST ||  \
                  process.env.VCAP_HOST || '0.0.0.0',
                function() { } );

Install the required packages and optionally lock 'em down (set 'in-stone'
the versions of the dependent packages you want to use):

    npm install
    npm shrinkwrap

You can also run the application locally via:

    npm start

And when you are satisfied that all's ok, just push your app to Heroku:

    #  Create an app with this buildpack and push to it.
    heroku apps:create -b git://github.com/ramr/strongloop-buildpack.git
    git push heroku master

This will download and configure StrongLoop Node on Heroku, install the
dependencies as specified in the sample application's package.json file
(or npm-shrinkwrap.json if one exists).

That's it, you can now checkout your StrongLoop Node application at the
app url/domain returned from the heroku apps:create command.

    Example:  http://whispering-coast-1234.herokuapp.com/


Deploying on OpenShift:
-----------------------
On OpenShift, the fastest method is to create an app using the sample PaaS
app quickstart (which already contains a copy of the StrongLoop config
markers), edit the config files as per your need and then just git push to
your OpenShift application.

    rhc app create -a dynode -t nodejs-0.6
    #  See also: --from-code $git_url

    #  Add the quickstart upstream repo
    cd nodez
    git remote add upstream git://github.com/ramr/strongloop-paas-quickstart.git
    git pull -s recursive -X theirs upstream master

    cp -r $buildpackdir/samples/strongloop .
    git add strongloop
    git commit . -m 'Added StrongLoop config files'

    git push


See https://github.com/ramr/strongloop-paas-quickstart/blob/master/README.md
for more details.


Deploying on CloudFoundry:
--------------------------
On CloudFoundry, support for buildpacks is not yet released to prod, so as
of now, you will need access to a test/beta environment to run this.
The overall procedure is sorta similar to the others - first optionally
copy the config files and then push to your CloudFoundry app.


Create an account on http://cloudfoundry.com/

For now, you will also need to register for the test/beta env @

    http://console.a1.cf-app.com/register 


Install the cf command line tools

     sudo gem install cf --pre

     #  If you run into issues w/ dependencies if you have the older vmc
     #  tools installed, then try uninstalling the vmc tools + other
     #  gems and run something like:
     #  sudo gem uninstall vmc cf
     #  sudo gem uninstall tunnel-cf-plugin cf-uaa-lib manifests-cf-plugin
     #  sudo gem uninstall caldecott-client cfoundry
     #
     #  sudo gem install cfoundry
     #  sudo gem install cf --pre
     #  sudo gem install cfoundry --pre
     #  sudo gem install manifests-cf-plugin --pre

     See: http://docs.cloudfoundry.com/tools/vmc/installing-vmc.html

Login into the CloudFoundry PaaS:

     cf login

Target the CloudFoundry PaaS:

     #  Normally, this would just be:
     #  cf target https://api.cloudfoundry.com

     #  But for the buildpack support, you will need to target the
     #  test/beta environment instead.
     cf target api.a1.cf-app.com

Clone or create your application:

     git clone git://github.com/ramr/strongloop-paas-quickstart.git dynode
     # OR  git clone ${path_to_your_awesome_app}.git dynode
     # OR  cp -r ~/myapp/*  dynode

Change directory to your application and optionally copy over the
StrongLoop sample configuration.

    cd dynode
    cp -r $buildpackdir/samples/strongloop .

For portability reasons, it is highly recommended that you use StrongLoop
variables or alternatively a combination of the platform specific variables
so that you may easily migrate your app between the different PaaS
enviroments.

Example: For an express app, use

    zapp.listen(process.env.STRONGLOOP_PORT, process.env.STRONGLOOP_HOST,
                function() { } );
    #  OR
    zapp.listen(process.env.STRONGLOOP_PORT ||  \
                  process.env.VCAP_PORT || process.env.PORT || 3000,
                process.env.STRONGLOOP_HOST ||  \
                  process.env.VCAP_HOST || '0.0.0.0',
                function() { } );

Install the required packages and optionally lock 'em down (set 'in-stone'
the versions of the dependent packages you want to use):

    npm install
    npm shrinkwrap

You can also run the application locally via:

    npm start

And when you are satisfied that all's ok, push your app to CloudFoundry.

    cf push dynode
      --buildpack=git://github.com/ramr/strongloop-buildpack.git
      --no-create-services --instances 1 --memory 128M

Note:  The first time you run vmc push, you will need to specify all the
       parameters - this will create a new application at CloudFoundry.
       domain `example: slnode-app.cloudfoundry.com`.
       And save the configuration `example: y`.

Subsequent pushes just need the `cf push` command - you only need to
specify all those options the first time you create the app (push).

This will now download and configure StrongLoop Node on CloudFoundry,
install the dependencies as specified in the sample application's
package.json file (or npm-shrinkwrap.json if one exists).

That's it, you can now checkout your StrongLoop Node application at the
app url/domain you set for your CloudFoundry app.

    Example:  http://dynode.cloudfoundry.com/

