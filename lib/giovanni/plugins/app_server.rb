# This plugin is called AppServer as we already have a tomcat namespace we want to expose
module Giovanni::Plugins::AppServer
  [:start, :stop, :restart].each do |method|
    define_method method do
      sudo "/etc/init.d/#{application} #{method}"
    end
  end
end

Capistrano.plugin :app_server, Giovanni::Plugins::AppServer
