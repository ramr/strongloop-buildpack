StrongLoop Node Example App Configuration
=========================================

This directory contains an example app configuration to control
which version of StrongLoop Node gets installed and what the application's
deployment mode is. 

If you add a strongloop directory (with the configuration marker
files) to your application, then that configuration is automatically used
by the StrongLoop installer specific to the type of PaaS you are
deploying on.

    cd myapp
    cp -r $buildpackdir/samples/strongloop .

    #  And depending on the PaaS, you are using you would then add, create
    #  an app stack and push these config files.
    #  See specific PaaS instructions below.

Note:  The use of the configuration files is purely optional. If no 
       StrongLoop specific config is passed, the installer will use the
       defaults.


Deploying on Heroku:
--------------------
On Heroku, first copy the config files as we did above, then create an app
using this buildpack and finally push to your Heroku app.

    cd dynode
    cp -r $buildpackdir/samples/strongloop .
    git add strongloop
    git commit . -m 'Added StrongLoop config files'
    #  Create an app with this buildpack and push to it.
    heroku apps:create -b git://github.com/ramr/strongloop-buildpack.git
    git push heroku master


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
    git remote add upstream git://github.com/ramr/strongloop-quickstart-app.git
    git pull -s recursive -X theirs upstream master
    cp -r $buildpackdir/samples/strongloop .
    git add strongloop
    git commit . -m 'Added StrongLoop config files'
    git push


Deploying on CloudFoundry:
--------------------------
On CloudFoundry, this buildpack is still *work-in-progress* and untested,
so you may run into issues. See: http://xkcd.com/1084/ for details!!
Kidding aside, the procedure should be the same as the others - first copy
the config files and then push to your CloudFoundry app.

    cd dynode
    cp -r $buildpackdir/samples/strongloop .
    vmc push

