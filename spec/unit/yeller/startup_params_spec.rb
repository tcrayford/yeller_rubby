require_relative '../../../lib/yeller/startup_params'

describe Yeller::StartupParams do
  before do
    ENV.delete('RAILS_ENV')
    ENV.delete('RACK_ENV')
  end

  it "hostname defaults to the current hostname" do
    Socket.should_receive(:gethostname).and_return('hostname')
    Yeller::StartupParams.defaults.fetch(:hostname).should == 'hostname'
  end

  describe "application environment" do
    it "application environment uses the passed in option if set" do
      ENV['RAILS_ENV'] = 'production'
      Yeller::StartupParams.defaults(:"application-environment" => 'development').fetch(:"application-environment").should == 'development'
    end

    it "application environment uses RAILS_ENV if present" do
      ENV['RAILS_ENV'] = 'production'
      Yeller::StartupParams.defaults.fetch(:"application-environment").should == 'production'
    end

    it "application environment uses RACK_ENV if present" do
      ENV['RACK_ENV'] = 'production'
      Yeller::StartupParams.defaults.fetch(:"application-environment").should == 'production'
    end

    it "application environment falls back to 'production' if it can't be inferred" do
      Yeller::StartupParams.defaults.fetch(:"application-environment").should == 'production'
    end
  end

  it "version uses the client version number" do
    Yeller::StartupParams.defaults.fetch(:"client-version").should == "yeller_rubby: #{Yeller::VERSION}"
  end
end
