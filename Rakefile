ENV['NODOT'] = 'true' # no dot means no class diagrams in RDoc
require 'config/requirements'
require 'config/hoe'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['rspec/*.rb'] 
end

task :default  => [:clean, :spec, :install_gem]

Dir['tasks/**/*.rake'].each { |rake| load rake }