$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'switchvox/net_http_digest_auth'
require 'switchvox/base'

module Switchvox
  VERSION = '0.1.0'
end
