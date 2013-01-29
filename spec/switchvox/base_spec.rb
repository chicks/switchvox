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

  describe "multipart_upload" do

    # add a public instance to a private method for testing
    # create a test file
    before(:all) do
      module Switchvox; class Base; def public_multipart_upload(f); multipart_upload(f); end; end; end
      File.open "/tmp/testfile.xml", "w" do |file|
        file.write("<element></element>")
      end
      @file = "/tmp/testfile.xml"
    end

    it "should return a string" do
      switchvox.public_multipart_upload(@file).class.should eq String
    end

    it "should return form data" do
      switchvox.public_multipart_upload(@file).should include "Content-Disposition: form-data;"
    end
  end

  describe 'parse json and return object' do
    it 'should test_object' do
      input = {"string" => "value"}
      obj = switchvox.json_parse(response_json(input))
      obj.string.should == 'value'
    end

    it 'should test test_nested_object' do
      input = {"dogs" => {"retriever" => "sparky", "basset" => "jennie", "pinscher" => "carver"}}
      obj = switchvox.json_parse(response_json(input))
      obj.dogs.retriever.should == 'sparky'
    end

    it 'should test test_array_of_objects' do
      input = [{"retriever" => "sparky"}, {"basset" => "jennie"}, {"pinscher" => "carver"}]
      obj = switchvox.json_parse(response_json(input))
      obj[0].retriever.should == "sparky"
    end

    it 'should test test_deep_nest_mixed' do
      input = {
        "kennels" => [
          {
            "dallas" => [
              {"name" => "north"},
              {"name"  => "east"},
            ]
          },
          {
            "frisco" => [
              {"name" => "south"},
              {"name"  => "west"}
            ],
            "company" => "Doggie Daze"
          }
        ]
      }
      obj = switchvox.json_parse(response_json(input))
      obj.kennels[1].frisco[1].name.should == 'west'
    end

    it 'should test test_deep_nest_hash' do
      input = {
        "kennels" => {
          "kennel" => {
            "dallas" => ["north", "south"],
            "frisco" => ["east", "west"]
          }
        }
      }
      obj = switchvox.json_parse(response_json(input))
      obj.kennels.kennel.dallas[0].should == 'north'
    end
  end
end
