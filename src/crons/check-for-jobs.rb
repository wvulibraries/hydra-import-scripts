#!/bin/ruby
require 'fileutils'

if (!ENV.include? 'HYDRA_PROJECT_NAME') then
  abort "Missing ENV variable, 'HYDRA_PROJECT_NAME'"
end

control_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/mfcs";
in_process_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/in-progress/"

# if there is already a control file in the processing directory, exit
exit if Dir.entries(in_process_dir).length > 2

Dir.open(control_dir).sort.each do |file|
  next if file =~ /^\./
  FileUtils.mv("#{control_dir}/#{file}","#{in_process_dir}/control_file.yaml")
  break
end
