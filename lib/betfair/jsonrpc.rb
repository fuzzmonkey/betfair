module Betfair
  require 'restclient'
  require 'json'

  class JSONRPC

    attr_accessor :app_key, :session_token, :headers

    BASE_URI = 'https://beta-api.betfair.com/json-rpc'

    def initialize(application_key, session_token)
      RestClient.log=($stdout)
      @app_key = app_key
      @session_token = session_token
      @headers = { 'X-Application' => application_key,  'X-Authentication' => @session_token }
    end

    def list_competitions(event_type_ids = [])
      payload = { jsonrpc: '2.0',
                  method: 'SportsAPING/v1.0/listCompetitions',
                  params: {
                    filter: {
                      eventTypeIds: event_type_ids
                    }
                  },
                  id: 1
                }.to_json

      response = JSON.parse(RestClient.post(BASE_URI, payload, @headers), symbolize_names: true)

      competitions = []

      response[:result].each do |res|
        res[:competition][:market_count] = res[:marketCount]
        competitions << res[:competition]
      end

      competitions #.to_yaml
    end

    def list_market_book(market_ids = [])
      payload = { jsonrpc: '2.0',
                  method: 'SportsAPING/v1.0/listMarketBook',
                  params: {
                    marketIds: market_ids,
                    priceProjection: ['EX_BEST_OFFERS']
                  },
                  id: 1
                }.to_json

      response = JSON.parse(RestClient.post(BASE_URI, payload, @headers), symbolize_names: true)
    end

  end

end
