require 'spec_helper'

describe Switchvox::Base do
  let(:host) { 'example.com' }
  let(:switchvox) do
    stub_request(:head, 'https://' + host + '/json').
       with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
       to_return(:status => 200, :body => "", :headers => {})
    req = Net::HTTP.new(host, '8080')
    Switchvox::Base.new(host ,Faker::Internet.user_name, 'password')
  end

  def response_json(body)
    Hash['response', Hash['result', body]].to_json
  end

  describe 'parse json and return object' do
    it 'should parse json and return a string' do
      words = Faker::Lorem.words(3)
      switchvox.json_parse(response_json(words)).should eq words
    end
  end
end
