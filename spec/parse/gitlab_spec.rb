require_relative "#{Dir.pwd}/parse/gitlab.rb"
require 'json'

describe GitlabPayload do
  before(:all) do
    payload_path = "#{File.expand_path File.dirname(__FILE__)}/../data/gitlab.json"
    @payload_data = File.open(payload_path).read
  end

  context 'with a gitlab payload' do
    before(:all) do
      @payload = GitlabPayload.new(@payload_data)
    end

    it 'parses commit data' do
      expect(@payload.latest_commit).to_not be_empty
      expect(@payload.author).to eq 'GitLab dev user <gitlabdev@dv6700.(none)>'
      expect(@payload.commit_hash).to eq 'da1560886d4f094c3e6c9ef40349f7d38b5d27d7'
      expect(@payload.branch).to eq 'master'
      expect(@payload.message).to eq "fixed readme"
    end

    it 'parses repository data' do
      expect(@payload.repo_slug).to eq 'mike/diaspora'
    end

    it 'parses the source url' do
      expect(@payload.source_url).to eq "http://example.com/mike/diaspora/commit/da1560886d4f094c3e6c9ef40349f7d38b5d27d7"
    end

    it 'casts to hash for environment variables purposes' do
      hash = @payload.to_hash
      expected_hash = {
        'CI_GIT_AUTHOR' => 'GitLab dev user <gitlabdev@dv6700.(none)>',
        'CI_GIT_HASH' => 'da1560886d4f094c3e6c9ef40349f7d38b5d27d7',
        'CI_GIT_BRANCH' => 'master',
        'CI_GIT_MESSAGE' => 'fixed readme',
        'CI_GIT_REPO_SLUG' => 'mike/diaspora',
        'CI_GIT_SOURCE_URL' => @payload.source_url
      }
      expect(hash).to eq expected_hash
    end
  end
  
  context 'with a malformed payload' do
    before(:all) do
      @payload = GitlabPayload.new('{nothing: here}')
    end

    it 'returns nil for commit data' do
      expect(@payload.latest_commit).to be_empty
      expect(@payload.author).to be_nil
      expect(@payload.commit_hash).to be_nil
      expect(@payload.branch).to be_nil
      expect(@payload.message).to be_nil
    end
    
    it 'returns nil for repository data' do
      expect(@payload.repository).to be_empty
      expect(@payload.repo_slug).to be_nil
    end

    it 'returns an empty source URL' do
      expect(@payload.source_url).to be_empty
    end
  end
end
