require_relative 'scripts'
require_relative 'output'
require 'yaml'

def read_config(relative_path)
  current_dir = File.expand_path File.dirname(__FILE__)
  YAML.load_file "#{current_dir}/../#{relative_path}"
end

def set_log_file(path)
  file = File.new(path, 'a+')
  file.sync = true
  use Rack::CommonLogger, path
end

def set_pid_file(config)
  pid_path = config['pid_file'] || '/var/run/mci.pid'
  pid = Process.pid
  puts_info "PID file: #{pid_path}"
  File.open pid_path, 'w' do |file|
    file.write pid
  end
end

def get_job_data(job_directory)
  jobs = {}
  current_dir = File.expand_path File.dirname(__FILE__)
  Dir.glob("#{current_dir}/../#{job_directory}/*.yaml").each do |path|
    job = YAML.load_file path
    job_name = File.basename path, '.yaml'
    jobs[job_name] = job
  end
  return jobs
end

def reject_job(name)
  throw_error "No configuration for job:\n#{name}"
end
