require 'yaml'

if (!ENV.include? 'HYDRA_PROJECT_NAME') then
  puts "Missing ENV variable, 'HYDRA_PROJECT_NAME'"
  exit;
end

in_process_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/in-progress/"

# check if there is a control file
# There should never be more than 3 entries (only 1 file in processing at a
# time)
exit if Dir.entries(in_process_dir).length != 3

config=YAML.load_file("#{in_process_dir}/control_file.yaml")

if (config['project_name'] != ENV['HYDRA_PROJECT_NAME']) then
  puts "Project name in control file does not match ENV HYDRA_PROJECT_NAME"
  exit;
end

# call rake command with required arguments
import_return = Dir.chdir("/home/#{ENV['HYDRA_PROJECT_NAME']}.lib.wvu.edu/#{ENV['HYDRA_PROJECT_NAME']}/") do
  |dir_name|

  `rails runner import/import_test.rb #{data_file_location} #{export_locations}`
end

# move control file as needed.
puts import_return
