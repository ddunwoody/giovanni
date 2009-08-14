# Load internal recipes from the recipes directory

# Load settings first
settings = File.expand_path(File.dirname(__FILE__) + '/../recipes/settings.rb')
Capistrano::Configuration.instance.load settings

# Load everything except settings
recipes = Dir[File.dirname(__FILE__) + '/../recipes/**/*.rb'].collect { |recipe| File.expand_path(recipe) }.select { |recipe| recipe != settings }
recipes.each do |recipe|
  Capistrano::Configuration.instance.load recipe
end