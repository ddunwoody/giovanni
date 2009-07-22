require 'capistrano/recipes/deploy/scm/base'

module Giovanni
  module SCM # :nodoc:

    # A custom SCM module for Capistrano that downloads a WAR file
    # from our Nexus repository (as defined in Giovanni::Plugins::Nexus)
    class Nexus < Capistrano::Deploy::SCM::Base
      include Giovanni::Plugins::Nexus

      # Returns +version+ as set by the user or read from +pom.xml+
      def head
	version
      end

      # query_revision is the same as revision (no pseudo-versions in Nexus)
      def query_revision(revision)
        revision
      end

      # returns a command to download the file from Nexus into the
      # +dest_dir+ directory of the latest release (which defaults to the
      # +webapps_dir+)
      def checkout(revision, destination)
	download_command(File.join(destination, variable(:artifact_dest_dir)))
      end
    end
  end
end
