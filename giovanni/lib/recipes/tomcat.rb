namespace :tomcat do
  desc 'Install shared Tomcat instance'
  task :install, :roles => :app do
    on_rollback { uninstall }

    sudo '/usr/sbin/groupadd tomcat'
    sudo "/usr/sbin/usermod -a -G tomcat #{user}"

    build.install('tomcat', :url => 'http://spangler.intra.btexact.com:8081/nexus/content/repositories/thirdparty/com/bt/collaborate/apache-tomcat/6.0.18/apache-tomcat-6.0.18.tar.gz') do |dir|
      script.run_all <<-CMDS
        mkdir -p /opt/apache-tomcat-6.0.18
        mv #{dir}/* /opt/apache-tomcat-6.0.18
        ln -s /opt/apache-tomcat-6.0.18 /opt/tomcat
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
