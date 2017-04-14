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

env_var = "HYDRA_PROJECT_NAME";
usage = 'Usage: ruby ./retry-error.rb {filename}'

abort "ENV variable #{env_var} not set" unless ENV.include? env_var
abort "Error: Expected filename.\n #{usage}" if ARGV.empty?
abort "Error: Too many arguments.\n #{usage}" if ARGV.length > 1

filename = ARGV[0]
error_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV[env_var]}/control/hydra/error"
success_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV[env_var]}/control/hydra/finished"

abort "#{filename} does not exist" unless File.exist?("#{error_dir}/#{filename}")

config = YAML.load_file("#{error_dir}/#{filename}")

abort "Project name in control file does not match ENV '#{env_var}'" if config['project_name'] != ENV[env_var]

Dir.chdir("/home/#{ENV[env_var]}.lib.wvu.edu/hydra/") do |dir_name|
  result = `/usr/local/bin/rails runner import/import.rb #{error_dir}/#{filename}`

  # looks at last bash command to see false status
  if $?.success?
    FileUtils.mv("#{error_dir}/#{config['time_stamp']}.yaml","#{success_dir}/#{config['time_stamp']}.yaml")
  else
    abort "Error processing. #{result}"
  end
end
