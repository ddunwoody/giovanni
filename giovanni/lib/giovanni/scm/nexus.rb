require 'capistrano/recipes/deploy/scm/base'

module Giovanni
  module SCM
    class Nexus < Capistrano::Deploy::SCM::Base
      include Giovanni::Plugins::Nexus

      def head
	version
      end

      def query_revision(revision)
        revision
      end

      def checkout(revision, destination)
	download_command(File.join(destination, variable(:webapps_dir)))
      end
    end
  end
end
