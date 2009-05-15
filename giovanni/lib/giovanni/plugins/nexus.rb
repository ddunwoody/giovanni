module Giovanni::Plugins::Nexus
  include REXML

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

  # TODO: sha1sum
  def download_command(destination)
    "mkdir -p #{destination} && wget #{verbose} #{url} -P #{destination}"
  end

  def url
    "#{folder}/#{filename}"
  end

  def folder
    "#{repository}/#{division}/#{group_path}/#{artifact_id}/#{version}"
  end

  def division
    is_snapshot? ? 'snapshots' : 'releases'
  end

  def is_snapshot?
    version.end_with?('SNAPSHOT')
  end

  [:repository, :group_id, :artifact_id, :version].each do |var|
    define_method var do
      # we can be called as a plugin, but we are also included in the Nexus SCM class
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
