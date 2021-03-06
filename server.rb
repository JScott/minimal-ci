#!/usr/bin/env ruby
require 'sinatra'
require 'rdiscount'
require_relative 'helpers/output'
require_relative 'helpers/payload'
require_relative 'helpers/scripts'
require_relative 'helpers/configs'
require_relative 'helpers/queue'

configure do
  server_config = read_config 'config.yaml'
  #set_log_file server_config
  set_pid_file server_config
  set :port, server_config['port'] || 8080
  set :bind, '0.0.0.0'
  set :jobs, get_job_data('./jobs') 
end

get '/' do
  current_path = File.expand_path File.dirname(__FILE__)
  markdown = File.read "#{current_path}/README.md"
  RDiscount.new(markdown).to_html
end

post '/:tool/payload-for/:job' do
  puts "Received #{params['tool']} payload for #{params['job']}"
  puts catch (:error) {
    reject_job params['job'] unless settings.jobs.include? params['job']
    job = settings.jobs[params['job']]

    request.body.rewind
    parse = parser_for params['tool']
    payload = parse.new request.body.read
    verify_payload payload, job['branches']

    environment_vars = payload.to_hash
    environment_vars.merge! job['environment'] unless job['environment'].nil?
    enqueue_scripts params['job'], environment_vars, job['scripts']
  }
  status 200
end
