require 'fileutils'
include FileUtils
require 'yaml'
 
require 'rubygems'
%w[rake hoe capistrano capitate].each do |req_gem|
  begin
    require req_gem
  rescue LoadError
    puts "This Rakefile requires the '#{req_gem}' RubyGem."
    puts "Installation: (sudo) gem install #{req_gem} -y"
    exit
  end
end
 
$:.unshift(File.join(File.dirname(__FILE__), %w[.. lib]))

require 'giovanni'
