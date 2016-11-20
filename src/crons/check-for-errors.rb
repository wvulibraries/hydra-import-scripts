#!/bin/ruby
require 'yaml'
require 'fileutils'
require 'net/smtp'

projects_with_errors = Array.new
Dir.open("/mnt/nfs-exports/mfcs-exports/") do |project_dir|
  next if Dir.entries("/mnt/nfs-exports/mfcs-exports/#{project_dir}/control/hydra/error").length > 2
  projects_with_errors.push project_dir
end


msgstr = "From: libsys@mail.wvu.edu\nSubject: Projects with errors\nThe following projects have errors:\n"
projects_with_errors.each do |project|
  msgstr = msgstr+"\t #{project}\n"
end

Net::SMTP.start('smtp.wvu.edu', 25) do |smtp|
  smtp.send_message msgstr, 'libsys@mail.wvu.edu', 'libsys@mail.wvu.edu'
end
