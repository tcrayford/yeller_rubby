require_relative '../../lib/yeller'
require_relative 'support/fake_yeller_api'

describe "Yeller API client" do
  class CustomException < StandardError; end

  def raise_exception(klass, message)
    begin
      raise klass.new(message)
    rescue klass => exception
      exception
    end
  end

  it "submits an error" do
    FakeYellerApi.start('token', 8888) do |yeller_api|
      yeller = Yeller.client do |client|
        client.token = 'token'
        client.remove_default_servers
        client.add_insecure_server "localhost", 8888
      end
      exception = raise_exception(CustomException, "an_message")
      yeller.report(exception)
      yeller_api.should have_received_exception(exception)
    end
  end

  it "submits errors to multiple endpoints" do
    FakeYellerApi.start('token', 8889, 8890) do |fake_main, fake_secondary|
      yeller = Yeller.client do |client|
        client.token = 'token'
        client.remove_default_servers
        client.add_insecure_server "localhost", 8889
        client.add_insecure_server "localhost", 8890
      end
      exception = raise_exception(CustomException, "an_message")

      2.times do
        yeller.report(exception)
      end

      fake_main.should have_received_exception(exception)
      fake_secondary.should have_received_exception(exception)
    end
  end

  it "doesn't accept errors if the token is wrong" do
    FakeYellerApi.start('wrong_token', 8891) do |yeller_api|
      yeller = Yeller.client do |client|
        client.token = 'token'
        client.remove_default_servers
        client.add_insecure_server "localhost", 8891
      end
      exception = raise_exception(CustomException, "an_message")
      yeller.report(exception)
      yeller_api.should_not have_received_exception(exception)
    end
  end

  it "records deploys" do
    FakeYellerApi.start('token', 8892) do |yeller_api|
      yeller = Yeller.client do |client|
        client.token = 'token'
        client.remove_default_servers
        client.add_insecure_server "localhost", 8892
      end
      yeller.record_deploy('3abc352', 'tcrayford', 'production')
      yeller_api.should have_received_deploy('3abc352')
    end
  end

  it "ignores exceptions in development environments" do
    FakeYellerApi.start('token', 8893) do |yeller_api|
      yeller = Yeller.client do |client|
        client.token = 'token'
        client.remove_default_servers
        client.add_insecure_server "localhost", 8893
        client.environment = 'development'
      end
      exception = raise_exception(CustomException, "an_message")
      yeller.report(exception)
      yeller_api.should_not have_received_exception(exception)
    end
  end
end
