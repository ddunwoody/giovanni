ENV['NODOT'] = 'true' # no dot means no class diagrams in RDoc
require 'config/requirements'
require 'config/hoe'
require 'spec/rake/spectask'
gem 'ci_reporter'
require 'ci/reporter/rake/rspec'

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/*.rb'] 
end

task :default  => [:clean, :spec, :install_gem]

Dir['tasks/**/*.rake'].each { |rake| load rake }