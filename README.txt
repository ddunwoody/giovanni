= Giovanni

Giovanni is a Gem that provides helper methods for deploying Tomcat-based applications on RedHat Linux.

It consists of three main parts:

1. set of Capistrano recipes (such as tomcat:install, and new behaviour for the default Capistrano deploy tasks)
1. A new SCM module for Capistrano that downloads the release from a Nexus repository
1. A shell script _giovannify_ which can be used in preference to _capify_

Further documentation is available in the RDocs, as well as in the DSO wiki at https://collaborate.bt.com/wiki/display/DSO/Giovanni.

Giovanni is named after {Giovanni da Capistrano}[http://en.wikipedia.org/wiki/Giovanni_da_Capistrano].

= Revision History

== 0.0.3 - In development

* Rename +deploy:clean+ to +deploy:teardown+ to make it more explicit it's the opposite of +deploy:setup+

== 0.0.2 - 20th May 2009

* Support generating a TNSnames-style Oracle DS
* Tested with ACF 1.1 and 1.2, and Provisioning 2.2
* Merged some changes from Chida's Confluence deployment

== 0.0.1 - 15th May 2009

* Tested with ACF 1.1
