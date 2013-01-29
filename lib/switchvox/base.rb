#! /usr/bin/env ruby

module Switchvox

require 'uri'
require 'net/https'
require 'openssl'
require 'digest/md5'
require 'rubygems'
require 'json'
require 'ostruct'
require 'mime/types'

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
  BOUNDARY = "---------------------------7d44e178b0434"
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
    body = wrap_json(method, parameters)
    header   = {'Content-Type' => "text/json"}
    # Send the request
    send_request(body, header)

  end

  def upload(method, parameters={})
    body = multipart_upload(method, parameters)
    header = {'Content-Type' => 'multipart/form-data; boundary=' + BOUNDARY}
    send_request(body, header)
  end

  # TODO - cover this with specs and return json not call other method
  def json_parse(body)
    json = JSON.parse body
    convert_to_obj(json["response"]["result"])
  end

  def convert_to_obj(arg)
    if arg.is_a? Hash
      arg.each { |k, v| arg[k] = convert_to_obj(v) }
      OpenStruct.new arg
    elsif arg.is_a? Array
      arg.map! { |v| convert_to_obj(v) }
    else
      arg
    end
  end

  protected

    def send_request(body, header)
      login! unless logged_in?
      request  = Net::HTTP::Post.new(@url.path, header)
      request.digest_auth(@user, @pass, @auth_header)
      request.body = body
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

    def multipart_upload(method, parameters)

      # assume the parameter with the word 'file' as part of the key represents the file to be uploaded
      # we'll set it to the file variable then remove it from the rest of the parameters
      file = ""
      parameters.each do |k,v|
        if k.to_s.scan('file').length > 0
          file = v
          parameters.delete(k)
          break
        end
      end
      json = wrap_json(method, parameters)

      # build the body of the request
      # add the file data
      post_body = []
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{File.basename(file)}\"\r\n"
      post_body << "Content-Type: #{MIME::Types.type_for(file)[0]}\r\n\r\n"
      post_body << File.read(file)

      # add the json with the method name
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"request\"\r\n\r\n"
      post_body << json
      post_body << "\r\n\r\n--#{BOUNDARY}--\r\n"
      return post_body.join
    end

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


