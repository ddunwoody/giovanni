# Defines the set of default options for Giovanni-enhanced Capistrano deployments
#
# The Variables[http://wiki.capify.org/index.php/Variables] wiki page at capify.org comes as recommended reading
default_run_options[:pty] = true

set :stage_dir, 'config/deploy/stages'
set :templates_dirs, [ File.expand_path(File.join(File.dirname(__FILE__), '..', 'templates')) ]

set :deploy_to, "/var/lib/#{application}"
set :log_path, "/var/log/#{application}"
set :tmp_path, "/var/tmp/#{application}"
set :webapps_dir, 'webapps'

set :source, Giovanni::SCM::Nexus.new(self)
set :repository, 'http://collaborate.bt.com/nexus/content/repositories'
set :releases_repo, 'bt-dso-releases'
set :snapshots_repo, 'bt-dso-snapshots'

set :user, ENV['USER'] unless exists?(:user)

[:group_id, :artifact_id, :version].each do |var|
  if exists?(var)
    puts "Using explicitly-set #{var} of '#{fetch(var)}'"
  elsif File.exist?('pom.xml')
    pom = REXML::Document.new(File.open('pom.xml'))
    element = REXML::XPath.first(pom, "/project/#{var.to_s.gsub('_i', 'I')}")
    element ||= REXML::XPath.first(pom, "/project/parent/#{var.to_s.gsub('_i', 'I')}")
    set var, element.text
    puts "Using #{var} of '#{element.text}' read from pom.xml"
  else
    raise Capistrano::Error, 'Either pom.xml must exist in the current directory, or group_id, artifact_id and version must be explicitly set'
  end
end
