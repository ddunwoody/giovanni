= Giovanni

Giovanni is a Gem that provides helper methods for installing Tomcat on RedHat Linux, and subsequently
deploying WAR files from a Nexus repository onto the installed Tomcat instance.

It consists of three main parts:

1. set of Capistrano recipes (such as tomcat:install, and new behaviour for the default Capistrano deploy tasks)
1. A new SCM module for Capistrano that downloads the release from a Nexus repository
1. A shell script _giovannify_ which can be used in preference to _capify_

Further documentation is available in the RDocs, as well as in the DSO wiki at https://collaborate.bt.com/wiki/display/DSO/Giovanni.

Giovanni is named after {Giovanni da Capistrano}[http://en.wikipedia.org/wiki/Giovanni_da_Capistrano].

See {this page}[http://wiki.capify.org/index.php/Default_Execution_Path] on the Capify wiki for an overview of how Capistrano works by default.

== Usage

=== Install Ruby and RubyGems

Giovanni is tested with Ruby 1.8.7-p72 and RubyGems 1.3.3 on Linux.  It probably works on Mac OS X and probably doesn't work on Windows.

=== Download and install Giovanni RubyGem

Go to Bamboo[https://spangler.intra.btexact.com/bamboo/browse/DEPLOYMENT-GIOVANNI/latest] > Artifacts > Gem.

Type <tt>sudo gem install -l giovanni-<i>version</i>.gem</tt>.  You will be prompted to install any dependent gems you don't already have (for example Capistrano).

=== Giovannify your project

Change into the directory that contains the pom.xml file of the artifact you wish to deploy.  This
*must* be a WAR arfifact (<tt><packaging>war</packaging></tt> in Maven terminology), as Giovanni
only supports deploying WARs.

It is possible to deploy without a POM file being present, please see <i>Advanced Usage</i> below for details.

Type <tt>giovannify</tt>.  This will parse the POM file and generate a <tt>Capfile</tt> as well as a <tt>config</tt> directory.  Some editing of these deployment scripts is required in order to be able to deploy.  Impatient types can go immediately to the <i>Examples</i> section, but first let us explore the newly-generated deployment scripts.

=== Configure the deployment scripts for your application

The main entry point for Capistrano is the <tt>Capfile</tt>.  You shouldn't normally need to edit this file, as it loads code from other files.

==== config/deploy.rb

The first of these files is <tt>config/deploy.rb</tt>, which defines deployment values that are specific to the application being deployed, but independent of the environment into which it is being deployed.

The most important line in this file is the <tt>set :application, 'foo'</tt> line.  If a POM file was present during giovannification, then <tt>application</tt> will be set to the value of <tt>artifactId</tt> from the build.

The _tomcat_ lines are optional.  The default values are shown as comments, but these can be overridden by uncommenting and changing these lines.

By convention, DSO Tomcat deployments are running in the range 30xxx for the <i>http_port</i> and 31xxx for the <i>shutdown_port</i>.

The <tt>tomcat_java_opts</tt> are the parameters passed to _java_ when Tomcat is started (specifically by using Tomcat's <tt>setenv.sh</tt>).  <tt>-Djava.awt.headless=true</tt> is automatically passed to Tomcat and cannot be changed.

==== config/deploy/stages/<i>stage.rb</i>

This directory defines your deployment <i>stages</i>.  A <i>stage</i> defines all the deployment values that change depending on the target environment.  By default, four stages are created:

* <i>development</i>: for deploying to your local machine or VM
* <i>integration</i>: for deploying to the integration/CI/nightly environment
* <i>staging</i>: for deploying to a replica of production
* <i>production</i>: for making things live

Any stages that are not required can be removed by deleting the corresponding <tt><i>stage</i>.rb</tt> file.

The only required line in a <i>stage</i> is the <tt>role :app, 'foo'</tt> line, which defines the hostname(s) or IP address(es) of the machine(s) to deploy to.  This line will determine the target for all operations carried out during a deployment.

In this file you will also find an example stanza for defining a datasource, if your application requires one.  This datasource will be made available in JNDI as <tt>jdbc/<i>Application</i>DS</tt>, for example <tt>jdbc/FooDS</tt> for an <tt>application</tt> called <i>foo</i>.

An additional custom environment-specific configuration required for your deployment should also be specified here.  You may wish to look at both the Variables[http://wiki.capify.org/index.php/Variables] page on the Capistrano wiki and in Giovanni's <tt>lib/recipe/settings.rb</tt> for variables that may be of help to you.

==== config/deploy/recipes/*.rb

Any files you place in this directory are run as part of the deployment.  This can be very useful for defining custom behaviour during your deployment, for example computing a version number, or generating and uploading additional files during deployment.

Creating a deployment that requires this sort of customisation is discouraged - deployments should be defined by convention rather than by application-specific rules.

=== Run your deployment

Once you have configured your application, you are ready to deploy!

==== Installing tomcat

If the target machine (as defined in a <i>stage</i>) does not already have Tomcat installed, you can install it with <tt>cap <i>stage</i> tomcat:install</tt>.

Similarly, Tomcat can be removed from a machine with <tt>cap <i>stage</i> tomcat:uninstall</tt>.

The Tomcat uninstall will be unable to remove the <i>tomcat</i> group if any applications have been set up on that machine with <tt>deploy:setup</tt>.

==== Setting up the machine for deployment

Before deploying for the first time, you need to run <tt>cap <i>stage</i> deploy:setup</tt>.  This creates all of the required directories on the target server.

Once setup is complete, it is a good idea to run <tt>cap <i>stage</i> deploy:check</tt> and fix any problems found.  <b>Note:</b> there is a bug where it will say that it cannot find <tt>`'</tt>.  This problem (only) can be safely ignored.

==== Deploying

If you are deploying for the first time, run <tt>cap <i>stage</i> deploy:cold</tt>.  Subsequent deployments should be executed using <tt>cap <i>stage</i> deploy</tt>.

There are a number of tasks available in the deploy namespace:

* <tt>deploy</tt>: Uploads release, symlinks it as current, and restarts Tomcat
* <tt>deploy:status</tt>: Shows whether the application is running, and the version currently in use
* <tt>deploy:cold</tt>: As <tt>deploy</tt>, but starts Tomcat instead of restarting it
* <tt>deploy:update</tt>: Uploads release and symlinks it as current, but does not restart Tomcat
* <tt>deploy:{start,stop,restart}</tt>: Starts, stops or restarts Tomcat
* <tt>deploy:cleanup</tt>: Removes old releases (keeps most recent 5)

The final commonly-useful task in is <tt>deploy:teardown</tt>.  This is the nuclear option, which removes all traces of the application from the target server.  The application's Tomcat instance should be stopped before running this.

More information on the deployment tasks can be found in the RDocs[file:lib/recipes/deploy_rb.html].

== Existing deployments using Giovanni

The simplest example of a deployment can be found in ACF[https://collaborate.bt.com/svn/bt-dso/acf/trunk/webapp/].

Provisioning[https://collaborate.bt.com/svn/bt-dso/provisioning/trunk/provisioning-client/] demonstrates the usage of a recipe to {compute a version number}[https://collaborate.bt.com/svn/bt-dso/provisioning/trunk/provisioning-client/config/deploy/recipes/fix_version.rb].

Storm[https://collaborate.bt.com/svn/bt-dso/storm/trunk/] (<b>note</b> not tested to production) demonstrates {overriding the values from the POM file}[https://collaborate.bt.com/svn/bt-dso/storm/trunk/config/deploy/recipes/fix_version.rb].

Nexus[https://collaborate.bt.com/svn/bt-dso/nexus/trunk/] demonstrates {rendering configuration at deployment time}[https://collaborate.bt.com/svn/bt-dso/nexus/trunk/config/deploy/recipes/upload_nexus_config.rb].

Bamboo[https://collaborate.bt.com/svn/bt-dso/nexus/trunk/] (<b>note</b> work in progress) will demonstrate how to deploy a third-party application without a POM file, as described immediately below.

=== Deploying without a POM file

If you do not have a pom.xml file, for example if you are deploying a third-party app without customisation, you need to specify <tt>group_id</tt>, <tt>artifact_id</tt> and <i>version</i> in <tt>config/deploy.rb</tt>.

* <tt>set :group_id, 'your_group_id_here'</tt>
* <tt>set :artifact_id, 'your_artifact_id_here'</tt>
* <tt>set :version, 'your_version_here'</tt>

This mechanism can also be used to override the values for these read from the POM file, if necessary.



== Revision History

Please see History[file:History_txt.html]
