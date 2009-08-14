# Handles stopping, starting and restarting Tomcat.
#
# This module is called AppServer because we wish to expose
# a namespace called _tomcat_.
#
# Methods in this module should be called exclusively from
# the _deploy_ namespace; they are not public (and therefore
# not publically documented)
module Giovanni::Plugins::AppServer
  [:start, :stop, :restart, :status].each do |method|
    define_method method do
      sudo "/etc/init.d/#{application} #{method}"
    end
  end
end

Capistrano.plugin :app_server, Giovanni::Plugins::AppServer