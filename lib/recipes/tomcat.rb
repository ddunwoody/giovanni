# Defines the <tt>tomcat:install</tt> and <tt>tomcat:uninstall</tt> tasks
#
# === tomcat:install
#
# Downloads Tomcat 6 from Nexus repository and installs it to
# <tt>/opt/apache-tomcat-_version_</tt>
#
# <tt>/opt/tomcat</tt> is symlinked to this location
#
# A _tomcat_ user and group are created, and the contents of
# the installation directory are set to be owned by the _tomcat_
# group.
#
# === tomcat:uninstall
#
# Removes <tt>/opt/tomcat</tt> and <tt>/opt/apache-tomcat-_version_</tt>
#
# Removes _tomcat_ group
#
# Note that removal of the _tomcat_ group will fail if any
# applications have been deployed, as their user(s) primary
# group will be the _tomcat_ group.
#
# These applications should be uninstalled with <tt>deploy:teardown</tt>
# before running <tt>tomcat:uninstall</tt>
namespace :tomcat do
  desc 'Install shared Tomcat instance'
  task :install, :roles => :app do
    on_rollback { uninstall }

    sudo '/usr/sbin/groupadd tomcat'
    sudo "/usr/sbin/usermod -a -G tomcat #{user}"

    build.install('tomcat', :url => "#{repository}/thirdparty/com/bt/collaborate/apache-tomcat/6.0.18/apache-tomcat-6.0.18.tar.gz") do |dir|
      script.run_all <<-CMDS
        mkdir -p /opt/apache-tomcat-6.0.18
        mv #{dir}/* /opt/apache-tomcat-6.0.18
        ln -nfs /opt/apache-tomcat-6.0.18 /opt/tomcat
      CMDS
      permissions.normalise '/opt/apache-tomcat-6.0.18', :group => 'tomcat'
    end
  end

  desc 'Uninstall shared Tomcat instance'
  task :uninstall, :roles => :app, :on_error => :continue do
    script.run_all <<-CMDS
      rm -f /opt/tomcat
      rm -rf /opt/apache-tomcat-6.0.18
      /usr/sbin/groupdel tomcat
    CMDS
  end
end
