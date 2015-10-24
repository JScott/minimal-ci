require_relative 'output'
require_relative '../parse/bitbucket'
require_relative '../parse/gitlab'

def parser_for(tool)
  case tool
  when 'bitbucket'
    BitbucketPayload
  when 'gitlab'
    GitlabPayload
  else
    throw_error "Stopping. No parser for tool:\n#{tool}"
  end
end

def verify_payload(payload, branch_watchlist)
  unless branch_watchlist.include? payload.branch
    throw_error "Stopping. '#{payload.branch}' is not on the branch watchlist:\n#{branch_watchlist}"
  end
end
