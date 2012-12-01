#! /usr/bin/env ruby

module Switchvox

require 'uri'
require 'net/https'
require 'openssl'
require 'digest/md5'
require 'rubygems'
require 'json'

# Raised when credentials are incorrect
class LoginError < RuntimeError
end

# Raised when the response.body is empty
class EmptyResponse < RuntimeError
end

# Raised when a response is returned that we don't know how to handle
class UnhandledResponse < RuntimeError
end

# The primary class used to interact with Switchvox.
class Base

  URL = "/json"
  attr :host, true
  attr :url, true
  attr :user, false
  attr :pass, false
  attr :connection, true
  attr :session, true
  attr :debug, true
  attr :auth_header, true

  def initialize(host, user, pass, options={})
    {:debug => false}.merge! options
    @debug = options[:debug]

    @host = host
    @user = user
    @pass = pass
    @url  = URI.parse("https://" + @host + URL)
    @ssl  = false
    @ssl  = true if @url.scheme == "https"

    @connection  = false
    @auth_header = false
    login!
    raise LoginError, "Invalid Username or Password" unless logged_in?
  end

  # A standard REST call to get a list of entries
  def request(method, parameters={})
    login! unless logged_in?
    json = wrap_json(method, parameters)

    # Send the request
    header   = {'Content-Type' => "text/json"}

    request  = Net::HTTP::Post.new(@url.path, header)
    request.digest_auth(@user, @pass, @auth_header)
    request.body = json
    response = @connection.request(request)

    case response
      when Net::HTTPOK
        raise EmptyResponse unless response.body
        return json_parse(response.body)
      when Net::HTTPUnauthorized
        login!
        request(method, parameters)
      when Net::HTTPForbidden
        raise LoginError, "Invalid Username or Password"
      else raise UnhandledResponse, "Can't handle response #{response}"
    end
  end

  def json_parse(body)
    response_json = JSON.parse body
    response_json["response"]["result"].to_obj
  end

  protected

    # Check to see if we are logged in
    def logged_in?
      return false unless @auth_header
      true
    end

    # Attempt HTTP Digest Authentication with Switchvox
    def login!
      connect! unless connected?
      @auth_header = @connection.head(@url.path)
    end

    # Check to see if we have an HTTP/S Connection
    def connected?
      return false unless @connection
      return false unless @connection.started?
      true
    end

    # Connect to the remote Switchvox system.  If SSL is enabled, ignore certificate checking.
    def connect!
      @connection = Net::HTTP.new(@url.host, @url.port)
      if @ssl
        @connection.use_ssl = true
        @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      @connection.start
    end

    # Wrap a JSON method and parameters in a Switchvox compatible request body.
    def wrap_json(method, parameters={})
      json = <<-"EOF"
        {
          \"request\": {
            \"method\": \"#{method}\",
            \"parameters\": #{parameters.to_json}
          }
        }
      EOF
      json.gsub!(/^\s{8}/,'')
    end

end

end


