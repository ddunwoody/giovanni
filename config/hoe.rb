require 'giovanni/version'

AUTHOR = 'David Dunwoody'
EMAIL = 'david.dunwoody@bt.com'
SUMMARY = 'Assists with deploying BT DSO applications using Capistrano'
DESCRIPTION = 'Add on modules for Capistrano for the BT DSO deployments'
GEM_NAME = 'giovanni'
HOMEPATH = 'https://collaborate.bt.com/wiki/display/DSO/Tomcat+migration'
#capitate doesn't list activesupport as a dependency even though it requires it
EXTRA_DEPS = [ ['capistrano', '>=2.5.5'], ['capistrano-ext', '>=1.2.1'], ['capitate', '>=0.3.6'], ['activesupport', '>=2.3.2'] ]

REV = YAML.load(`svn info`) ? YAML.load(`svn info`)['Revision'] : nil

VERS = Giovanni::VERSION::STRING + (REV ? ".#{REV}" : "")

Hoe.new(GEM_NAME, VERS) do |p|
  p.developer(AUTHOR, EMAIL)
  p.summary = SUMMARY
  p.description = DESCRIPTION
  p.url = HOMEPATH
  p.extra_deps |= EXTRA_DEPS
end