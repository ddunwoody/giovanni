# Holds code to "normalise" permissions
module Giovanni::Plugins::Permissions
  # Sets permissions and ownerships recursively to "normal" values
  #
  # Normal values are defined as
  # ==== Files
  # * read and write for owner and group, no access for others
  # * additionally, the execute flag is set on files ending with .sh
  # ==== Directories
  # * read, write, execute for owner and group, no access for others
  #
  # ==== Options
  # +owner+: change file and directory ownership to this user
  # +group+: change file and directory group owner to this group
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
