require 'json'
require 'uri'

class GitlabPayload
  def initialize(data)
    @data = JSON.parse(data)
  rescue JSON::ParserError
    @data = {}
  end

  def latest_commit
    @data.fetch('commits', [{}]).last
  end

  def author
    author = latest_commit.fetch('author')
    format('%s <%s>', author.fetch('name'), author.fetch('email'))
  rescue KeyError
    nil
  end

  def commit_hash
    latest_commit.fetch('id', nil)
  end

  def message
    latest_commit.fetch('message', nil)
  end

  def repo_slug
    url = URI(@data.fetch('repository').fetch('git_http_url'))
    url.path.sub(/^\/(.+\/.+)\.git/) { $1 }
  rescue KeyError
    nil
  end

  def repository
    @data.fetch('repository', '')
  end
  
  def source_url
    latest_commit.fetch('url', '')
  end
  
  def branch
    @data.fetch('ref').sub(/^refs\/heads\//, '')
  rescue KeyError
    nil
  end

  def to_hash
    {
      'CI_GIT_AUTHOR' => author,
      'CI_GIT_BRANCH' => branch,
      'CI_GIT_HASH' => commit_hash,
      'CI_GIT_MESSAGE' => message,
      'CI_GIT_REPO_SLUG' => repo_slug,
      'CI_GIT_SOURCE_URL' => source_url
    }
  end
end
