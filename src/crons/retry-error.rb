#!/bin/ruby
require 'yaml'
require 'fileutils'
require 'net/smtp'

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

# Make Sure that the ENV variables are set
if (!ENV.include? 'HYDRA_PROJECT_NAME') then
  abort "Missing ENV variable, 'HYDRA_PROJECT_NAME'"
end

# We are expecting to run a single file again by hand.
# Expecting this check to make sure that there is an argument given
if ARGV.empty?
  puts "Error: Expected filename"
  abort "Usage: ruby ./retry-error.rb {filename.yaml}"
end

# Don't let them add more arguments than needed
if ARGV.length >= 2
  puts "Error: Too many arguments supplied"
  abort "Usage: ruby ./retry-error.rb {filename.yaml}"
end

# define the filename from the arguments
filename = ARGV

# Mikes send notifications code
def send_notifications(emailAddr, msgstr)
  msgstr = "From: libsys@mail.wvu.edu\nSubject: Importing Update\n #{msgstr}"
  Net::SMTP.start('smtp.wvu.edu', 25) do |smtp|
    smtp.send_message msgstr, 'libsys@mail.wvu.edu', emailAddr
  end
end

# Make sure directories are present and in vars for use later
in_process_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/in-progress"
error_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/error"
success_dir = "/mnt/nfs-exports/mfcs-exports/#{ENV['HYDRA_PROJECT_NAME']}/control/hydra/finished"

# if there is no file, abort the program
if !File.exists?("#{error_dir}/#{filename}")
  abort "File is missing make sure that it is correct and present in the error folder"
end

# Grab the configuration files needed to rerun the file
config=YAML.load_file("#{error_dir}/#{filename}")

# check configs and enivronmental variables are the same
if (config['project_name'] != ENV['HYDRA_PROJECT_NAME']) then
  abort "Project name in control file does not match ENV HYDRA_PROJECT_NAME"
end

Dir.chdir("/home/#{ENV['HYDRA_PROJECT_NAME']}.lib.wvu.edu/hydra/") do |dir_name|
  export_locations = "/mnt/nfs-exports/mfcs-exports/#{config['project_name']}/export/#{config['time_stamp']}"
  result = `/usr/local/bin/rails runner import/import.rb #{export_locations}`

  # looks to see if the result has exited with a false status
  if (!$?.success?) then
    # move from processing to error
    # send email of failure and above the chron
    send_notifications(config['contact_emails'], "Import of #{config['project_name']} failed.")
    abort "Error processing. Moved to error control directory. {#{result}}"
  else
    # otherwise import succeeded
    send_notifications(config['contact_emails'], "Import of #{config['project_name']} succeeded.")
    FileUtils.mv("#{error_dir}/#{config['time_stamp']}.yaml","#{success_dir}/#{config['time_stamp']}.yaml")
  end
end
