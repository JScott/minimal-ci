require_relative "../../helpers/configs.rb"

describe "helper/configs.rb" do
  before(:all) do
    @config_path = 'spec/data/config.yaml'
  end
  describe 'read_config' do
    it 'returns the config file from the server root path' do
      config = read_config @config_path
      expect(config).to_not be_nil
      expect(config).to be_instance_of(Hash)
    end
  end
  describe 'set_log_file' do
    before(:all) do
      @config = read_config @config_path
    end
    it 'redirects logger output to a given file' do
      skip 'Having logging problems right now'
      set_log_file @config['parser']['log_file']
      string = 'hi'
      logger.info string
      expect(File.read @config['parser']['log_file']).to match string
    end
  end
  describe 'set_pid_file' do
    before(:all) do
      @config = read_config @config_path
    end
    it 'creates a PID file with the PID of this script' do
      set_pid_file @config['parser']['pid_file']
      expect(File.read @config['parser']['pid_file']).to eq Process.pid.to_s
    end
  end
  describe 'get_job_data' do
    it 'retrieves job data from a directory' do
      jobs = get_job_data './spec/data/jobs/valid'
      expect(jobs.count).to eq 2
      expect(jobs['two']).to_not be_nil
    end
  end
  describe 'reject_job' do
    it 'throws an error' do
      expect { reject_job 'test' }.to throw_symbol(:error)
    end
  end
end
