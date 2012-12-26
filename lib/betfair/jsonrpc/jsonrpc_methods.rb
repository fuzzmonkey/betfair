module Betfair

  module JSONRPC

    module Methods

      def list_competitions(event_type_ids = [])
        response = make_request('SportsAPING/v1.0/listCompetitions', { filter: { eventTypeIds: event_type_ids } })

        competitions = []
        response[:result].each do |res|
          res[:competition][:market_count] = res[:marketCount]
          competitions << res[:competition]
        end

        competitions
      end

      def list_market_book(market_ids = [])
        response = make_request('SportsAPING/v1.0/listMarketBook', { marketIds: market_ids, priceProjection: ['EX_BEST_OFFERS'] })
      end

    end

  end

end