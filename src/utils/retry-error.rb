#!/bin/ruby
require 'yaml'
require 'fileutils'

#  retry-error
# ==================================================
# Name : David J. Davis
# Date :  4/11/2017
#
# Requirements:  You must run add_project_env.sh first
# so that the environmental variable is able to be used.
#
# Useage: From the terminal as root user run the command
# ruby ./retry-error.rb {filename.yaml}
#
# Description: The following code goes through the following
# checks to make sure that all items are present
# ---- ENV['HYDRA_PROJECT_NAME']
# ---- ARGV of a filename which is the error file
# ---- Error File Exists
# ---- Project Names Match
#  If all exists it tries to run through the export script
#  and if it passes the file is moved out of the error folder
#  to the completed folder, if fails it is not moved.

unless ENV.include? 'HYDRA_PROJECT_NAME'
  abort "Missing ENV variable, 'HYDRA_PROJECT_NAME'"
end

usage = 'Usage: ruby ./retry-error.rb {filename}'
abort "Error: Expected filename.\n #{usage}" if ARGV.empty?
abort "Error: Too many arguments.\n #{usage}" if ARGV.length > 1

filename = ARGV
error_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/error"
success_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/finished"

unless File.exist?("#{error_dir}/#{filename}")
  abort '#{filename} is missing make sure that it is correct and present in the error folder'
end

config = YAML.load_file("#{error_dir}/#{filename}")

if config['project_name'] != ENV['HYDRA_PROJECT_NAME']
  abort 'Project name in control file does not match ENV HYDRA_PROJECT_NAME'
end

Dir.chdir("/home/#{ENV['HYDRA_PROJECT_NAME']}.lib.wvu.edu/hydra/") do |dir_name|
  export_locations = "/mnt/nfs-exports/mfcs-exports/#{config['project_name']}/export/#{config['time_stamp']}"
  result = `/usr/local/bin/rails runner import/import.rb #{export_locations}`

  # looks at last bash command to see false status
  if $?.success?
    FileUtils.mv("#{error_dir}/#{config['time_stamp']}.yaml","#{success_dir}/#{config['time_stamp']}.yaml")
  else
    abort "Error processing. Moved to error control directory. #{result}"
  end
end
