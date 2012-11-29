require 'spec_helper'
require 'switchvox/base'

describe Switchvox::Base do
  let(:host) { 'example.com' }
  let(:switchvox) do
    stub_request(:head, 'https://' + host + '/json').
       with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
       to_return(:status => 200, :body => "", :headers => {})
    req = Net::HTTP.new(host, '8080')
    Switchvox::Base.new(host ,Faker::Internet.user_name, 'password')
  end

end