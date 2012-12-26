module Betfair

  class SOAP

    ## Some handy constants...

    EXCHANGE_IDS = {
      :aus => 2,
      :uk  => 1
    }

    PRODUCT_ID_FREE = 82

    BET_TYPE_LAY  = 'L'
    BET_TYPE_BACK = 'B'

    ## Success and Failure get mixed in to API result values
    # so that you can tell the difference easily - just call
    # #success? on the result to find out if it worked
    module Success
      def success?; true; end
    end # module Success


    module Failure
      def success?; false; end
    end # module Failure


    ## Bet Placement API METHODS
    #

    def place_bet(session_token, exchange_id, market_id, selection_id, bet_type, price, size)
      bf_bet = {
        :marketId           => market_id,
        :selectionId        => selection_id,
        :betType            => bet_type,
        :price              => price,
        :size               => size,
        :asianLineId        => 0,
        :betCategoryType    => 'E',
        :betPersistenceType => 'NONE',
        :bspLiability       => 0
      }

      response = exchange(exchange_id).
        session_request( session_token,
                         :placeBets,
                         :place_bets_response,
                         :bets => { 'PlaceBets' => [bf_bet] } )

      return response.maybe_result( :bet_results, :place_bets_result )
    end


   def place_multiple_bets(session_token, exchange_id, bets)
      bf_bets = []
      bets.each do |bet|
        bf_bets << {
          :marketId           => bet[:market_id],
          :selectionId        => bet[:selection_id],
          :betType            => bet[:bet_type],
          :price              => bet[:price],
          :size               => bet[:size],
          :asianLineId        => bet[:asian_line_id],
          :betCategoryType    => bet[:bet_category_type],
          :betPersistenceType => bet[:bet_peristence_type],
          :bspLiability       => bet[:bsp_liability]
        }
      end

      response = exchange(exchange_id).
        session_request( session_token,
                         :placeBets,
                         :place_bets_response,
                         :bets => { 'PlaceBets' => bf_bets } )

      return response.maybe_result( :bet_results, :place_bets_result )
    end

    def update_bet(session_token, exchange_id, bet_id, new_bet_persitence_type, new_price, new_size, old_bet_persitance_type, old_price, old_size)
       bf_bet = {
          :betId                  => bet_id,
          :newBetPersistenceType  => new_bet_persitence_type,
          :newPrice               => new_price,
          :newSize                => new_size,
          :oldBetPersistenceType  => old_bet_persitance_type,
          :oldPrice               => old_price,
          :oldSize                => old_size
        }

        response = exchange(exchange_id).
          session_request( session_token,
                           :updateBets,
                           :update_bets_response,
                           :bets => { 'UpdateBets' => [bf_bet] } )

        return response.maybe_result( :bet_results, :update_bets_result )
    end

    def update_multiple_bets(session_token, exchange_id, bets)
      bf_bets = []
      bets.each do |bet|
        bf_bets << {
          :betId                  => bet[:bet_id],
          :newBetPersistenceType  => bet[:new_bet_persitence_type],
          :newPrice               => bet[:new_price],
          :newSize                => bet[:new_size],
          :oldBetPersistenceType  => bet[:old_bet_persitance_type],
          :oldPrice               => bet[:old_price],
          :oldSize                => bet[:old_size]
        }
      end

      response = exchange(exchange_id).
        session_request( session_token,
                         :updateBets,
                         :update_bets_response,
                         :bets => { 'UpdateBets' => bf_bets } )

      return response.maybe_result( :bet_results, :update_bets_result )
    end

    def cancel_bet(session_token, exchange_id, bet_id)
      bf_bet = { :betId => bet_id }

      response = exchange(exchange_id).
        session_request( session_token,
                         :cancelBets,
                         :cancel_bets_response,
                         :bets => { 'CancelBets' => [bf_bet] } ) # "CancelBets" has to be a string, not a symbol!

      return response.maybe_result( :bet_results, :cancel_bets_result )
    end

    def cancel_multiple_bets(session_token, exchange_id, bets)
      bf_bets = []
      bets.each { |bet_id| bf_bets << { :betId => bet_id } }

      response = exchange(exchange_id).
        session_request( session_token,
                         :cancelBets,
                         :cancel_bets_response,
                         :bets => { 'CancelBets' => bf_bets } ) # "CancelBets" has to be a string, not a symbol!

      return response.maybe_result( :bet_results, :cancel_bets_result )
    end

    def cancel_bet_by_market(session_token, exchange_id, market_id)
      raise 'Service not available in product id of 82'
    end

    ## Read-Only Betting API METHODS
    #

    def get_mu_bets( session_token, exchange_id, market_id = 0, bet_status = 'MU', start_record = 0, record_count = 200, sort_order = 'ASC', order_by =  'PLACED_DATE') #, bet_ids = nil, , exclude_last_second = nil, matched_since = nil
      response = exchange(exchange_id).
        session_request( session_token,
                         :getMUBets,
                         :get_mu_bets_response,
                         #:betIds => bet_ids,
                         :betStatus => bet_status,
                         #:excludeLastSecond => exclude_last_second,
                         :marketId => market_id,
                         #:matchedSince => matched_since,
                         :orderBy => order_by,
                         :recordCount => record_count,
                         :sortOrder => sort_order,
                         :startRecord => start_record
                         )

      return response.maybe_result( :bets, :mu_bet )
    end


    def get_market(session_token, exchange_id, market_id, locale = nil)
      response = exchange(exchange_id).
        session_request( session_token,
                         :getMarket,
                         :get_market_response,
                         :marketId => market_id,
                         :locale   => locale )

      return response.maybe_result( :market )
    end


    def get_market_prices_compressed(session_token, exchange_id, market_id, currency_code = nil)
      response = exchange(exchange_id).
        session_request( session_token,
                         :getMarketPricesCompressed,
                         :get_market_prices_compressed_response,
                         :marketId => market_id,
                         :currencyCode => currency_code )

      return response.maybe_result( :market_prices )
    end


    def get_active_event_types(session_token, locale = nil)
      response = @global_service.
        session_request( session_token,
                         :getActiveEventTypes,
                         :get_active_event_types_response,
                         :locale => locale )

      return response.maybe_result( :event_type_items, :event_type )
    end


    def get_all_markets(session_token, exchange_id, event_type_ids = nil, locale = nil, countries = nil, from_date = nil, to_date = nil)
      response = exchange(exchange_id).
        session_request( session_token,
                         :getAllMarkets,
                         :get_all_markets_response,
                         :eventTypeIds => { 'int' => event_type_ids },
                         :locale       => locale,
                         :countries    => { 'country' => countries },
                         :fromDate     => from_date,
                         :toDate       => to_date )

      return response.maybe_result( :market_data )
    end


    def get_account_funds( session_token, exchange_id )
      response = exchange(exchange_id).
        session_request( session_token,
                         :getAccountFunds,
                         :get_account_funds_response )

      return response.maybe_result
    end

    def login(username, password, product_id = 82, vendor_software_id = 0, location_id = 0, ip_address = nil)
      response = @global_service.request( :login,
                                          :login_response,
                                          :username         => username,
                                          :password         => password,
                                          :productId        => product_id,
                                          :vendorSoftwareId => vendor_software_id,
                                          :locationId       => location_id,
                                          :ipAddress        => ip_address )

      return response.maybe_result( :header, :session_token )
    end

    ## General API METHODS
    #

    def keep_alive(session_token)
      response = @global_service.
        session_request( session_token,
                         :keep_alive,
                         :keep_alive_response )

      # Need to do the old school way of checking as the keep_alive
      # response doesn't return a minorErrorCode, so fails
      error_code = response[:header][:error_code]
      return error_code == 'OK' ?
        response[:header][:session_token].extend( Success ) :
        error_code.extend( Failure )
    end

    def logout(session_token)
      response = @global_service.
        session_request( session_token,
                         :logout,
                         :logout_response )
      return response.maybe_result( :header, :session_token )
    end

    #
    ## END OF API METHODS


    def exchange(exchange_id)
      exchange_id == EXCHANGE_IDS[:aus] ? @aus_service : @uk_service
    end

    def session_token(response_header)
      response_header[:error_code] == 'OK' ? response_header[:session_token] : response_header[:error_code]
    end


    def initialize(proxy = nil, logging = nil)

      SOAPClient.log = logging

      @global_service = SOAPClient.global( proxy )
      @uk_service     = SOAPClient.uk( proxy )
      @aus_service    = SOAPClient.aus( proxy )

    end




    # A wrapper around the raw Savon::Client to hide the details of
    # the Savon API and those parts of the Betfair API which are
    # constant across the different API method calls
    class SOAPClient

      # Handy constants
      NAMESPACES = {
        :aus    => 'http://www.betfair.com/exchange/v3/BFExchangeService/AUS',
        :global => 'https://www.betfair.com/global/v3/BFGlobalService',
        :uk     => 'http://www.betfair.com/exchange/v3/BFExchangeService/UK' }
      ENDPOINTS  = {
        :aus    => 'https://api-au.betfair.com/exchange/v5/BFExchangeService',
        :global => 'https://api.betfair.com/global/v3/BFGlobalService',
        :uk     => 'https://api.betfair.com/exchange/v5/BFExchangeService' }


      # Factory methods for building clients to the different endpoints
      def self.global( proxy ); new( :global, proxy ); end
      def self.uk( proxy );     new( :uk, proxy );     end
      def self.aus( proxy );    new( :aus, proxy );    end


      # Wrapper to avoid leaking Savon's logging API
      def self.log=(logging); Savon.log = !!logging; end


      # Pass the `region` (see ENDPOINTS for valid values) to pick the
      # WSDL endpoint and namespace.  `proxy` should be a string URL
      # for HTTPI to use as a proxy setting.
      def initialize( region, proxy, em_http = false)
        HTTPI::Adapter.use = :em_http if em_http == true
        @client = Savon::Client.new do |wsdl, http|

          wsdl.endpoint  = ENDPOINTS[region]
          wsdl.namespace = NAMESPACES[region]
          http.proxy = proxy if proxy
        end
      end


      # Delegate the SOAP call to bf:`method` with `body` as the
      # `bf:request` field.  Getting a Hash back, this method returns
      # response[result_field][:result] as its result.
      def request( method, result_field, body )
        response = @client.request( :bf, method ) {
          soap.body = { 'bf:request' => body }
        }.to_hash[result_field][:result]

        response.extend( ErrorPresenter )

        response
      end


      # For those requests which take place in the context of a session,
      # this method constructs the correct header and delegates to #request.
      def session_request( session_token, method, result_field, body = {})
        header_body = { :header => api_request_header(session_token) }
        full_body = header_body.merge( body )

        request method, result_field, full_body
      end


      def api_request_header(session_token)
        { :client_stamp => 0, :session_token => session_token }
      end
      protected :api_request_header


    end # class SoapClient


    # Mix this into a Hash to give it basic error reporting and a nice
    # path-based data extractor.
    module ErrorPresenter

      def success?
        self[:error_code] == "OK"
      end


      def format_error
        "#{self[:error_code]} - #{self[:header][:error_code]}"
      end


      def maybe_result( *path )
        if success?
          path.inject(self){|m,r| m[r]}.extend( Success )
        else
          format_error().extend( Failure )
        end
      end


    end # module ErrorPresenter


  end # class API

end
