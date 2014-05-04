require 'openssl'
module Yeller
  Server = Struct.new(:host, :port) do
    def client
      @client ||= Net::HTTP.new(host, port)
    end
  end

  SecureServer = Struct.new(:host, :port) do
    def client
      @client ||= setup_client
    end

    def setup_client
      http = Net::HTTP.new(host, port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.ciphers = "DEFAULT:!aNULL:!eNULL:!LOW:!EXPORT:!SSLv2"
      http
    end
  end
end
