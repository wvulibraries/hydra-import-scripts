#!/bin/ruby
require 'fileutils'

# Config variables

control_dir = "/mnt/nfs-exports/mfcs-exports/{{ project_name }}/control/mfcs";
in_process_dir = "/mnt/nfs-exports/mfcs-exports/{{ project_name }}/control/hydra/in-progress/"

### Stop Editing ###

project_name = ENV['HYDRA_PROJECT_NAME']
control_dir = control_dir.gsub(/{{ project_name }}/, project_name)
in_process_dir = in_process_dir.gsub(/{{ project_name }}/, project_name)

exit if Dir.entries(in_process_dir).length > 2

Dir.open(control_dir).sort.each do |file|
  next if file =~ /^\./
  FileUtils.mv("#{control_dir}/#{file}","#{in_process_dir}/#{file}")
  break
end
