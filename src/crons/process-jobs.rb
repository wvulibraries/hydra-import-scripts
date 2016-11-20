require 'yaml'
require 'fileutils'
require 'net/smtp'

def send_notifications(emailAddr, msgstr)
  msgstr = "From: libsys@mail.wvu.edu\nSubject: Importing Update\n #{msgstr}"
  Net::SMTP.start('smtp.wvu.edu', 25) do |smtp|
    smtp.send_message msgstr, 'libsys@mail.wvu.edu', emailAddr
  end
end

if (!ENV.include? 'HYDRA_PROJECT_NAME') then
  abort "Missing ENV variable, 'HYDRA_PROJECT_NAME'"
end

in_process_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/in-progress"
error_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/error"
success_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/finished"

# check if there is a control file
# There should never be more than 3 entries (only 1 file in processing at a
# time)
exit if Dir.entries(in_process_dir).length != 3

config=YAML.load_file("#{in_process_dir}/control_file.yaml")

if (config['project_name'] != ENV['HYDRA_PROJECT_NAME']) then
  abort "Project name in control file does not match ENV HYDRA_PROJECT_NAME"
end

Dir.chdir("/home/#{ENV['HYDRA_PROJECT_NAME']}.lib.wvu.edu/#{ENV['HYDRA_PROJECT_NAME']}/") do
  |dir_name|

  export_locations = "/mnt/nfs-exports/mfcs-exports/#{config['project_name']}/export/#{config['time_stamp']}"
  `rails runner import/import.rb #{export_locations}`
  if (!$?.success?) then
    FileUtils.mv("#{in_process_dir}/control_file.yaml","#{error_dir}/#{config['time_stamp']}.yaml")
    send_notifications(config['contact_emails'], "Import of #{config['project_name']} failed.")
    abort "Error processing. Moved to error control directory."
  else
    send_notifications(config['contact_emails'], "Import of #{config['project_name']} succeeded.")
    FileUtils.mv("#{in_process_dir}/control_file.yaml","#{success_dir}/#{config['time_stamp']}.yaml")
  end
end
