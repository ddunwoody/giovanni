require 'fileutils'
include FileUtils
require 'yaml'
 
require 'rubygems'
{'hoe' => 'hoe' , 
  'capistrano' => 'capistrano', 
  'capitate' => 'capitate', 
  'capistrano-ext' => 'capistrano/ext/version', 
  'active_support' =>'activesupport', 
  'rspec' => 'spec', 
  'ci_reporter' => 'ci/reporter/version'}.each_pair do |gem_name, requirement|
  begin
    require requirement
  rescue LoadError
    puts "This Rakefile requires the '#{gem_name}' RubyGem."
    puts "Installation: (sudo) gem install #{gem_name} -y"
    exit
  end
end
 
$:.unshift(File.join(File.dirname(__FILE__), %w[.. lib]))

require 'giovanni'