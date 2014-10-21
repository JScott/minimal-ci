require_relative 'payload'
require_relative 'output'
require 'fileutils'

def from_workspace(job, logger=Logger.new(STDOUT))
  path = workspace_path_for job
  logger.info "Working from '#{path}' for '#{job}'"
  FileUtils.mkdir_p path
  Dir.chdir path do
    yield
  end
end

def workspace_path_for(job_name)
  current_dir = File.expand_path File.dirname(__FILE__)
  "#{current_dir}/../workspaces/#{job_name}"
end

def run_script(path, logger=Logger.new(STDOUT))
  logger.info "Running '#{path}'..."
  IO.popen(path) do |io|
    while line = io.gets
      logger.info line
    end
  end
  logger.info "Script done. (exit status: #{$?.exitstatus})"
end

def run_scripts(job_name, scripts, logger=Logger.new(STDOUT))
  from_workspace(job_name, logger) do
    scripts.each { |command| run_script command, logger }
  end
end
