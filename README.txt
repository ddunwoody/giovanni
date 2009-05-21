= Giovanni

Giovanni is a Gem that provides helper methods for deploying Tomcat-based applications on RedHat Linux.

It consists of three main parts:

1. set of Capistrano recipes (such as tomcat:install, and new behaviour for the default Capistrano deploy tasks)
1. A new SCM module for Capistrano that downloads the release from a Nexus repository
1. A shell script _giovannify_ which can be used in preference to _capify_

Further documentation is available in the RDocs, as well as in the DSO wiki at https://collaborate.bt.com/wiki/display/DSO/Giovanni.

Giovanni is named after {Giovanni da Capistrano}[http://en.wikipedia.org/wiki/Giovanni_da_Capistrano].

See {this page}[http://wiki.capify.org/index.php/Default_Execution_Path] on the Capify wiki for an overview of how Capistrano works by default.

== Usage

=== Giovannify your project

Change into the directory that contains the pom.xml file of the artifact you wish to deploy.  This
*must* be a WAR arfifact (<tt><packaging>war</packaging></tt> in Maven terminology), as Giovanni
only supports deploying WARs.

It is possible to deploy without a POM file being present, please see <i>Advanced Usage</i> below for details.

Type <tt>giovannify</tt>.  This will parse the POM file and generate a <tt>Capfile</tt> as well as a <tt>config</tt> directory.  Some editing of these deployment scripts is required in order to be able to deploy.  Impatient types can go immediately to the <i>Examples</i> section, but first let us explore the newly-generated deployment scripts.

=== Deployment script layout

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

An additional custom environment-specific configuration required for your deployment should also be specified here.

==== config/deploy/recipes/*.rb

Any files you place in this directory are run as part of the deployment.  This can be very useful for defining custom behaviour during your deployment, for example computing a version number, or generating and uploading additional files during deployment.

Creating a deployment that requires this sort of customisation is discouraged - deployments should be defined by convention rather than by application-specific rules.

=== Examples

=== Advanced Usage

==== Deploying without a POM file

If you do not have a pom.xml file, for example if you are deploying a third-party app without customisation, you need to specify <tt>group_id</tt>, <tt>artifact_id</tt> and <i>version</i> in <tt>config/deploy.rb</tt>.

* <tt>set :group_id, 'your_group_id_here'</tt>
* <tt>set :artifact_id, 'your_artifact_id_here'</tt>
* <tt>set :version, 'your_version_here'</tt>

This mechanism can also be used to override the values for these read from the POM file, if necessary.

==== Computing a version number

==== Rendering configuration at deployment time


== Revision History

Please see History[file:History_txt.html]
