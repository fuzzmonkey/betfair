require 'spec_helper'

module Betfair

  describe "General API Methods" do

    before :all do
      @client = Betfair::JSONRPC::Client.new({:adapter => :net_http})
      @client.setup_connection 'foo', 'bar'
    end

    describe "list competitions API call given an array of sporting ids" do
      it "should return an array of competitions" do
        stub_request(:post, 'https://beta-api.betfair.com/json-rpc').to_return(:body => load_body("json/list_competitions/success.json"))

        rsp = @client.list_competitions []
        rsp.should eq [{:id=>"2372210", :name=>"Fed Cup 2013", :market_count=>1}, {:id=>"2203993", :name=>"French Open 2013", :market_count=>4}, {:id=>"2269816", :name=>"The Open Championship 2013", :market_count=>1}, {:id=>"2203707", :name=>"US Open 2013", :market_count=>4}, {:id=>"2467323", :name=>"Mubadala World Tennis 2012 (Exhibition Event)", :market_count=>5}, {:id=>"2203705", :name=>"Wimbledon 2013", :market_count=>4}, {:id=>"2244972", :name=>"US Masters 2013", :market_count=>2}, {:id=>"2352775", :name=>"Tennis Specials 2013", :market_count=>36}, {:id=>"2371932", :name=>"Davis Cup 2013", :market_count=>2}]
      end
    end

  end

end
