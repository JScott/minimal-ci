require_relative "../../helpers/scripts.rb"
require 'yaml'

describe 'helper/scripts.rb' do
  before(:all) do
    payload_path = "#{File.expand_path File.dirname(__FILE__)}/../data/payload.yaml"
    payload_data = YAML.load_file payload_path
    @some_data = payload_data['bitbucket']
  end

  describe 'from_workspace' do
    before(:all) do
      @job = 'test-job'
    end
    it 'performs the given code at the workspace root' do
      from_workspace @job do
        File.write('workspace.txt', 'workspace')
      end
      expect(File.exist? 'workspace.txt').to be_falsey
      expect(File.exist? "#{workspace_path_for @job}/workspace.txt").to be_truthy
    end
  end

  describe 'workspace_path_for' do
    it 'returns the workspace path for a job' do
      expect(workspace_path_for 'test-job').to match /workspaces\/test-job/
    end
  end

  describe 'run_script' do
    before(:all) do
      CURRENT_DIR = File.expand_path File.dirname(__FILE__)
      @hello_script = "#{CURRENT_DIR}/../data/scripts/hello-world"
      @env_script = "#{CURRENT_DIR}/../data/scripts/hello-env"
    end
    before(:each) do
      @logger = double 'logger'
    end
    it 'logs the script output and exit status' do
      expect(@logger).to receive(:info).with(/Running/)
      expect(@logger).to receive(:info).with(/hello world/)
      expect(@logger).to receive(:info).with(/exit status: 0/)
      run_script @hello_script, @logger
    end
    it 'passes environment variables to the scripts' do
      ENV['test_status'] = 'passing'
      expect(@logger).to receive(:info).with(/Running/)
      expect(@logger).to receive(:info).with(/passing/)
      expect(@logger).to receive(:info).with(/done/)
      run_script @env_script, @logger
    end
    it 'can run and log commands instead of scripts' do
      expect(@logger).to receive(:info).with(/Running/)
      expect(@logger).to receive(:info).with(/1/)
      expect(@logger).to receive(:info).with(/exit status: 0/)
      run_script 'echo 1', @logger
    end
  end

  describe 'run_scripts' do
    before(:all) do
      CURRENT_DIR = File.expand_path File.dirname(__FILE__)
      @job_name = 'test-job'
      @scripts = [
        "#{CURRENT_DIR}/../data/scripts/hello-world",
        "#{CURRENT_DIR}/../data/scripts/hello-file"
      ]
    end
    it 'calls run_script on all scripts' do
      expect_any_instance_of(Object).to receive(:run_script).twice
      run_scripts @job_name, @scripts
    end
    it 'will write files from scripts to the workspace' do
      run_scripts @job_name, @scripts
      file_text = File.read "workspaces/#{@job_name}/hello.txt"
      expect(file_text).to eq 'hello file'
    end
  end
end
