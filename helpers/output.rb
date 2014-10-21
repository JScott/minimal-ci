require 'colorize'
require 'sinatra'
require 'logger'

def throw_error(string)
  throw :error, "! #{string}".red
end

def puts_info(string)
  logger.info "> #{string}".light_blue
end

def puts_script(string)
  logger.info string
end
