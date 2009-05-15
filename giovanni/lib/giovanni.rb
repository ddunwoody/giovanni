require 'capistrano'
require 'capitate'
require 'rexml/document'
require 'net/http'

# add this path to ruby load path unless it's already there
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Giovanni
  module Plugins
  end
end


Dir[File.dirname(__FILE__) + '/giovanni/plugins/**/*.rb'].each do |plugin|
  require plugin[/giovanni\/plugins.*/][0..-4]
end

require 'giovanni/scm/nexus'
