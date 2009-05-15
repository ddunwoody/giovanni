module Giovanni::Plugins::Permissions
  def normalise path, options = {}
    script.run_all <<-CMDS
      bash -c 'find #{path} -type d | xargs -r chmod 770'
      bash -c 'find #{path} -type f | xargs -r chmod 660'
      bash -c 'find #{path} -type f -name \'*.sh\' | xargs -r chmod 770'
    CMDS

    sudo "chown -R #{options[:owner]} #{path}" if options.has_key? :owner
    sudo "chgrp -R #{options[:group]} #{path}" if options.has_key? :group
  end
end

Capistrano.plugin :permissions, Giovanni::Plugins::Permissions
