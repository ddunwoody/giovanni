namespace :deploy do
  desc 'Prepares one or more servers for deployment'
  task :setup do
    script.run_all <<-CMDS
      /usr/sbin/useradd -m -g tomcat #{application}
      mkdir -p #{dirs}
      chmod g+w #{dirs}
      chown -R #{application}:tomcat #{dirs}
      ln -nfs #{current_path} /home/#{application}
    CMDS

    utils.install_template('init.d/tomcat.erb', "/etc/init.d/#{application}")
    script.run_all <<-CMDS
      /sbin/chkconfig --add #{application}
      /sbin/chkconfig #{application} on
    CMDS
  end

  desc 'Removes a deployment setup from one or more servers'
  task :clean, :on_error => :continue do
    script.run_all <<-CMDS
      rm -rf #{dirs}
      /usr/sbin/userdel -rf #{application}
      /sbin/chkconfig --del #{application}
      rm /etc/init.d/#{application}
    CMDS
  end

  task :finalize_update do
    set :run_method, :run
    script.run_all <<-CMDS
      ln -nfs #{log_path} #{latest_release}/logs
      ln -nfs #{tmp_path} #{latest_release}/temp
      mkdir #{['bin', 'conf', 'lib', 'work'].map { |d| File.join(latest_release, d) }.join(' ')}
      cp /opt/tomcat/conf/* #{latest_release}/conf
      unzip -q #{File.join(latest_release, webapps_dir, nexus.filename)} -d #{File.join(latest_release, webapps_dir, application)}
      rm #{File.join(latest_release, webapps_dir, nexus.filename)}
    CMDS

    # render Tomcat templates into current Tomcat dir
    Dir[File.dirname(__FILE__) + '/../templates/tomcat/**/*.*'].each do |file|
       template = file[/tomcat.*/]
       destination = File.join(latest_release, template.gsub(/\.erb$/, '')[7..-1])

       # render all templates except context.xml, which is
       # only rendered if tomcat_ds has been set
       if File.basename(file) == 'context.xml.erb'
	 if exists?(:tomcat_ds)
           utils.install_template(template, destination, :user => user)
           # TODO: factor out downloading from maven repo (also for tomcat:install task)
           run "wget -nv http://spangler.intra.btexact.com:8081/nexus/content/repositories/thirdparty/oracle/oracle-jdbc/10.1.0.2.0/oracle-jdbc-10.1.0.2.0.jar -P #{File.join(latest_release, 'lib')}"
	 end
       else
         utils.install_template(template, destination, :user => user)
       end
    end

    permissions.normalise latest_release, :owner => application, :group => 'tomcat'
  end

  [:start, :stop, :restart].each do |task_name|
    desc "#{task_name.to_s.capitalize}s your application"
    task task_name, :roles => :app do
      app_server.send task_name
    end
  end

  # Migrate is a no-op for non-rails apps
  task :migrate do
  end

  def dirs
    [deploy_to, releases_path, log_path, tmp_path].join(' ')
  end

  dirs.split.each do |dir|
    depend :remote, :directory, dir
  end

  depend :remote, :directory, '/opt/tomcat'
  depend :remote, :command, 'java'
  depend :remote, :command, 'unzip'
  depend :remote, :command, "/etc/init.d/#{application}"
end
