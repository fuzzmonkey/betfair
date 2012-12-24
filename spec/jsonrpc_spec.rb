require 'spec_helper'

module Betfair

  describe "General API Methods" do


    ###########
    ## For the time being we need to get the session_token using the old SOAP API
    ## This is well tested in the SOAP Specs
    ## This can go when the SOAP API is deprecated
    ###########
    include LoginHelper

    before(:all) do
      login()
    end


    describe "login() function should give us a session_token from the old SOAP API" do
      it "should be a long string" do
        @session_token.should eq 'ws2RTxfNCiFjBEmVMQuPyxMbobl1FA+vf//K7CGQoUo='
      end
    end

    ###########
    ## The start of the actual JSONRPC Specs
    ###########

    describe "list competitions API call given an array of sporting ids" do
      it "should return an array" do



        bf = Betfair::JSONRPC.new('faketoken', @session_token)

        stub_request(:post, 'https://beta-api.betfair.com/json-rpc')
        .with(body: { jsonrpc: '2.0',
                    method: 'SportsAPING/v1.0/listCompetitions',
                    params: {
                      filter: {
                        eventTypeIds: [2,3]
                      }
                    },
                    id: 1
                  },
              headers: bf.headers
              )
        .to_return(:body => 'fake body')
        RestClient.get('http://host/api')
        WebMock.should have_requested(:get ,'http://host/api')

      end
    end

  end

end
