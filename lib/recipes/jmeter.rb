namespace :jmeter do
   set :tmp_dir, "/var/tmp"
   set :test_loc, "#{tmp_dir}/jmeter_test.jmx"
   set :jmeter_log, "#{tmp_dir}/jmeter_log.log"

   desc 'Downloads the user configured jmeter test'
   task :download_test, :roles => :jmeter do
     raise Capistrano::Error, "No test download url (test_download_url) property set!" unless exists?(:test_url)
     run "wget -nv #{test_url} -O #{test_loc}"
   end

   desc 'Executes a jmeter test. Any configuration of the test before execution can be done by implementing an after jmeter:download_test method'
   task :run_test, :roles => :jmeter do
     on_rollback {
        sudo "rm -f #{test_loc}"
     }
     download_test
     raise Capistrano::Error, 'No jmeter installation location specified (jmeter_install)!' unless exists?(:jmeter_install)
     raise Capistrano::Error, "The jmeter installation #{jmeter_install} does not appear to be a valid installation of jmeter" unless File.exist?("#{jmeter_install}/bin/jmeter")
     puts "Now running all tests..."
     run "rm -f #{jmeter_log}"
     run "#{jmeter_install}/bin/jmeter -n -t #{test_loc} -l #{jmeter_log}"
     sudo "rm -f #{test_loc}"
     puts "--- All tests complete. The output logs can be found at #{jmeter_log} ---"
   end
end

