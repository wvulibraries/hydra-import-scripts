require 'yaml'
require 'fileutils'
require 'net/smtp'

# Don't allow multiple instances of this script to run at the same time
f = File.open($PROGRAM_NAME, 'r')
if (not f.flock(File::LOCK_EX | File::LOCK_NB))
    exit
end

def send_notifications(emailAddr, msgstr)
  msgstr = "From: libsys@mail.wvu.edu\nSubject: Importing Update\n\n #{msgstr}"
  Net::SMTP.start('smtp.wvu.edu', 25) do |smtp|
    smtp.send_message msgstr, 'libsys@mail.wvu.edu', emailAddr
  end
end

def send_env_notifications(env_var)
  # TODO: This should notify slack as well
  send_notifications("mrbond@mail.wvu.edu", "ENV error: #{env_var}")
  abort "Missing ENV variable, '#{env_var}'"
end

send_env_notifications("HYDRA_PROJECT_NAME") if !ENV.include? 'HYDRA_PROJECT_NAME'
send_env_notifications("SECRET_KEY_BASE") if !ENV.include? 'SECRET_KEY_BASE'
send_env_notifications("FEDORA_PASSWORD") if !ENV.include? 'FEDORA_PASSWORD'

in_process_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/in-progress"
error_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/error"
success_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/finished"

# check if there is a control file
# There should never be more than 3 entries (only 1 file in processing at a
# time)
exit if Dir.entries(in_process_dir).length != 3

config=YAML.load_file("#{in_process_dir}/control_file.yaml")

abort "Project name in control file does not match ENV HYDRA_PROJECT_NAME" if config['project_name'] != ENV['HYDRA_PROJECT_NAME']

Dir.chdir("/home/#{ENV['HYDRA_PROJECT_NAME']}.lib.wvu.edu/hydra/") do
  |dir_name|

  export_locations = "/mnt/nfs-exports/mfcs-exports/#{config['project_name']}/export/#{config['time_stamp']}"
  result = `/usr/local/bin/rails runner import/import.rb #{export_locations}`
  if (!$?.success?) then
    FileUtils.mv("#{in_process_dir}/control_file.yaml","#{error_dir}/#{config['time_stamp']}.yaml")
    send_notifications(config['contact_emails'], "Import of #{config['project_name']} failed! '#{Process.pid}' '#{$?.success?}'")
    abort "Error processing. Moved to error control directory. {#{result}}"
  else
    send_notifications(config['contact_emails'], "Import of #{config['project_name']} succeeded. '#{Process.pid}' '#{$?.success?}'")
    FileUtils.mv("#{in_process_dir}/control_file.yaml","#{success_dir}/#{config['time_stamp']}.yaml")
  end
end
