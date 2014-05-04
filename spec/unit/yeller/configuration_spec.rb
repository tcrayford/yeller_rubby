require_relative '../../../lib/yeller/configuration'

describe Yeller::Configuration do
  describe "servers" do
    it "starts with a default set of 5 servers" do
      Yeller::Configuration.new.servers.first.should == Yeller::SecureServer.new("collector1.yellerapp.com", 443)
    end

    it "lets you remove the default servers" do
      Yeller::Configuration.new.remove_default_servers.servers.should == []
    end

    it "lets you add custom servers" do
      config = Yeller::Configuration.new
      config.remove_default_servers
      config.add_server("example.com", 443)
      config.servers.should == [Yeller::SecureServer.new("example.com", 443)]
    end

    it "lets you add insecure http servers if you really want to" do
      config = Yeller::Configuration.new
      config.remove_default_servers
      config.add_insecure_server("example.com", 80)
      config.servers.should == [Yeller::Server.new("example.com", 80)]
    end

  end

  describe "startup_params" do
    it "lets you set a custom environment" do
      config = Yeller::Configuration.new
      config.environment = 'development'
      config.startup_params[:"application-environment"].should == 'development'
    end

    it "lets you set a custom hostname" do
      config = Yeller::Configuration.new
      config.host = 'an_server'
      config.startup_params[:host].should == 'an_server'
    end

  end
end
