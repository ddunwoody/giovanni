# This module provides helper methods for Giovanni::SCM::Nexus.
#
# This existence of this module may be a mistake in it's current
# form; we need to expose a download method to users of Giovanni,
# but this is not the right way to do it.
module Giovanni::Plugins::Nexus
  include REXML

  # Returns the filename of a WAR file, handling SNAPSHOT versions
  def filename
    if is_snapshot?
      metadata_url = folder + '/maven-metadata.xml'
      response = Net::HTTP.get_response(URI.parse(metadata_url))
      raise Capistrano::Error, "Unable to get snapshot metadata from #{metadata_url}: #{response.inspect}" unless response.code == '200'
      metadata = Document.new(response.body)
      timestamp = XPath.first(metadata, '//timestamp').text
      build_number = XPath.first(metadata, '//buildNumber').text
      "#{artifact_id}-#{version.gsub(/-SNAPSHOT$/, '')}-#{timestamp}-#{build_number}.war"
    else
      "#{artifact_id}-#{version}.war"
    end
  end

  private

  def download(destination)
    run download_command(destination)
  end

  # Called by Giovanni::SCM::Nexus to get the command to do the download
  def download_command(destination)
    # TODO: sha1sum
    "mkdir -p #{destination} && wget #{verbose} #{url} -P #{destination}"
  end

  def url
    "#{folder}/#{filename}"
  end

  def folder
    "#{repository}/#{division}/#{group_path}/#{artifact_id}/#{version}"
  end

  # figure out which repository in Nexus to look at
  def division
    if is_snapshot?
      var = :snapshots_repo
    else
      var = :releases_repo
    end
    if respond_to? :configuration
      variable(var)
    else
      fetch(var)
    end
  end

  def is_snapshot?
    version.end_with?('SNAPSHOT')
  end

  [:repository, :group_id, :artifact_id, :version].each do |var|
    define_method var do
      # we can be called as a plugin, but we are also included in the Nexus SCM class
      # FIXME: this is hideously ugly and needs to be refactored.
      if respond_to? :configuration
        raise Capistrano::Error, "you must set a #{var} with :set #{var}, foo" unless variable(var)
        variable(var)
      else
	fetch(var)
      end
    end
  end

  def group_path
    group_id.gsub('.', '/')
  end

  def verbose
    configuration[:scm_verbose] ? nil : '--quiet'
  end
end

Capistrano.plugin :nexus, Giovanni::Plugins::Nexus
