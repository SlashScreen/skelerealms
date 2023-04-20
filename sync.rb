# frozen_string_literal: true
# This ruby script allows one to pull changes from my other godot addons to this repo.

require 'fileutils'
require 'yaml'

def load_requirements_file(path)
	# load requirements from file
	reqs = YAML.load_file(path)

	# For each requirement
	reqs.each do |k, v|
		repo = v["repo"]
		src_folder = v["src_folder"]
		dest_folder = v["dest_folder"]

		# Clone repo
		FileUtils.remove_dir "#{k}" if Dir.exists? "#{k}" # remove the cloning dir if it exists for some reason
		system "git clone --depth=1 #{repo}"

		# recurse if more addons detected
		load_requirements_file "#{k}/addons.yaml" if File.exists? "#{k}/addons.yaml"

		# move folder
		FileUtils.mkdir_p "#{dest_folder}" unless Dir.exists? "#{dest_folder}" # make dir if it doesnt already exist
		FileUtils.mv "#{k}/#{src_folder}", "#{dest_folder}/", :force => true # move folder

		# remove repo
		FileUtils.remove_dir "#{k}"
	end
end

load_requirements_file "addons.yaml"
