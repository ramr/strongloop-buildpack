StrongLoop Node BuildPack
=========================

This repository is a StrongLoop Node buildpack to enable users to run
StrongLoop Node as a runtime "service" on a few different PaaS
environments. Currently run's on SalesForce's Heroku and Red Hat's
OpenShift PaaS.
VMWare's CloudFoundry support is *work-in-progress*  ... stay tuned


Copy StrongLoop Node configuration files [OPTIONAL]
---------------------------------------------------
This step is strictly optional - you don't need to copy over StrongLoop
Node configuration files. However if you wish to control which StrongLoop
version you want to install + what deployment mode to run in you will need
to provide StrongLoop specific configuration files, so in such as case
using the sample configuration is a good start.

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

Clone this sample application or create your application:

     git clone git://github.com/ramr/strongloop-paas-quickstart.git dynode
     # or cp -r ~/myapp/*  dynode

Change directory to your application and optionally copy over the
StrongLoop sample configuration

    cd dynode
    cp -r $buildpackdir/samples/strongloop .
    git add strongloop
    git commit . -m 'Added StrongLoop config files'

For best portability reasons, it is highly recommended that you use a
combination of StrongLoop variables and platform specific variables so that
you may easily migrate your app between different PaaS platforms.

Example: For an express app, use

    expressapp.listen(process.env.STRONGLOOP_PORT ||  \
                      process.env.VCAP_PORT || process.env.PORT || 3000,
                      process.env.STRONGLOOP_HOST ||  \
                      process.env.VCAP_HOST || '0.0.0.0',
                      function() { } );

Install the required packages and optionally lock 'em down:

    npm install
    npm shrinkwrap

You can optionally run the application locally by just running:

    npm start

And when you are satisfied that all's ok, just push your app to Heroku:

    #  Create an app with this buildpack and push to it.
    heroku apps:create -b git://github.com/ramr/strongloop-buildpack.git
    git push heroku master

This will now download and configure StrongLoop Node on CloudFoundry,
install the dependencies as specified in the sample application's
package.json file (or npm-shrinkwrap.json if one exists).

That's it, you can now checkout your StrongLoop Node application at the
app url/domain returned from the heroku apps:create command.

    Example:  http://whispering-coast-1234.herokuapp.com/


Deploying on OpenShift:
-----------------------
On OpenShift, the easiest method is to create an app using the sample PaaS
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
On CloudFoundry, this buildpack is still *work-in-progress* and untested,
so you may run into issues. See: http://xkcd.com/1084/ for details!!
Kidding aside, the procedure should be the same as the others - first copy
the config files and then push to your CloudFoundry app.

Create an account on http://cloudfoundry.com/

Install the vmc command line tools

     See: http://docs.cloudfoundry.com/tools/vmc/installing-vmc.html

Target the CloudFoundry PaaS:

     vmc target https://api.cloudfoundry.com

Login into the CloudFoundry PaaS:

     vmc login

Clone or create your application:

     git clone git://github.com/ramr/strongloop-paas-quickstart.git dynode
     # or cp -r ~/myapp/*  dynode

Change directory to your application and optionally copy over the
StrongLoop sample configuration

    cd dynode
    cp -r $buildpackdir/samples/strongloop .

For best portability reasons, it is highly recommended that you use a
combination of StrongLoop variables and platform specific variables so that
you may easily migrate your app between different PaaS platforms.

Example: For an express app, use

    expressapp.listen(process.env.STRONGLOOP_PORT ||  \
                      process.env.VCAP_PORT || process.env.PORT || 3000,
                      process.env.STRONGLOOP_HOST ||  \
                      process.env.VCAP_HOST || '0.0.0.0',
                      function() { } );

Install the required packages and optionally lock 'em down:

    npm install
    npm shrinkwrap

You can optionally run the application locally by just running:

    npm start

And when you are satisfied or then since this is a PaaS specific
quickstart, just push to CloudFoundry:

    vmc push dynode
      --buildpack=git://github.com/ramr/strongloop-buildpack.git
      --no-create-services --instances 1 --memory 128M --framework node

Note:  The first time you run vmc push, you will need to specify all the
       parameters - this will create a new application at CloudFoundry
       and you will need to specify the runtime `node08` (yeah bit klunky
       as the PaaS environments have older versions),
       domain `example: slnode-app.cloudfoundry.com`.
       And save the configuration `example: y`.

Subsequent pushes just need the `vmc push` command - you only need to
specify all those options the first time you create the app (push).

This will now download and configure StrongLoop Node on CloudFoundry,
install the dependencies as specified in the sample application's
package.json file (or npm-shrinkwrap.json if one exists).

That's it, you can now checkout your StrongLoop Node application at the
app url/domain you set for your CloudFoundry app.

    Example:  http://dynode.cloudfoundry.com/

