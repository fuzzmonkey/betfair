module Betfair

  class SOAPHelpers

    ## HELPER METHODS
    #

    def all_markets(markets)
      market_hash = {}
      markets.gsub! '\:', "\0"
      markets = markets.split ":"
      markets.each do |piece|
        piece.gsub! "\0", '\:'
        foo = piece.split('~')
        market_hash[foo[0].to_i] = {
          :market_id            => foo[0].to_i,
          :market_name          => foo[1].to_s,
          :market_type          => foo[2].to_s,
          :market_status        => foo[3].to_s,
          # bf returns in this case time in Epoch, but in milliseconds
          :event_date           => Time.at(foo[4].to_i/1000),
          :menu_path            => foo[5].to_s,
          :event_hierarchy      => foo[6].to_s,
          :bet_delay            => foo[7].to_s,
          :exchange_id          => foo[8].to_i,
          :iso3_country_code    => foo[9].to_s,
          # bf returns in this case time in Epoch, but in milliseconds
          :last_refresh         => Time.at(foo[10].to_i/1000),
          :number_of_selections    => foo[11].to_i,
          :number_of_winners    => foo[12].to_i,
          :total_amount_matched => foo[13].to_f,
          :bsp_market           => foo[14] == 'Y' ? true : false,
          :turning_in_play      => foo[15] == 'Y' ? true : false
        }
      end
      return market_hash
    end

    # Pass in the string returned from the get_all_markets() API call and get back a proper hash
    # This duplicates the helper above, not sure where this came from one of contributors must have added it.
    def split_markets_string(string)
      string_raw = string
      foo = []
      if string_raw.is_a?(String)
        string_raw.split(':').each do |string|
          bar = string.split('~')

          bsp_market        = bar[14] == 'Y' ? true : false
          turning_in_play   = bar[15] == 'Y' ? true : false
          event_date        = Time.at(bar[4].to_i/1000).utc
          last_refresh      = Time.at(bar[10].to_i/1000).utc

          doh = { market_id: bar[0].to_i, market_name: bar[1], market_type: bar[2], market_status: bar[3], event_date: event_date, menu_path: bar[5], event_heirachy: bar[6],
                  bet_delay: bar[7].to_i, exchange_id: bar[8].to_i, iso3_country_code: bar[9], last_refresh: last_refresh, number_of_selections: bar[11].to_i, number_of_winners: bar[12].to_i,
                  total_amount_matched: bar[13].to_f, bsp_market: bsp_market, turning_in_play: turning_in_play }
          foo << doh if !doh[:market_name].nil?
        end
      end
      return foo
    end

    def market_info(details)
      { :exchange_id => nil,
        :market_type_id => nil,
        :market_matched => nil,
        :menu_path => details[:menu_path],
        :market_id => details[:market_id],
        :market_name => details[:name],
        :market_type_name => details[:menu_path].to_s.split('\\')[1]
      }
    end

    def details(market)
      selections = []
      market[:runners][:runner].each { |selection| selections << { :selection_id => selection[:selection_id].to_i, :selection_name => selection[:name] } }
      return { :market_id => market[:market_id].to_i, :market_type_id => market[:event_type_id].to_i, :selection => selections }
    end

    def prices(prices)
      price_hash = {}
      prices.gsub! '\:', "\0"
      pieces = prices.split ":"
      pieces.each do |piece|
        piece.gsub! "\0", '\:'
        price_hash[piece.split('~')[0].to_i] = piece
      end
      return price_hash
    end

    def combine(market, prices)
      market = details(market)
      prices = prices(prices)
      market[:selection].each do |selection|
        selection.merge!( { :market_id => market[:market_id] } )
        selection.merge!( { :market_type_id => market[:market_type_id] } )
        selection.merge!(price_string(prices[selection[:selection_id]]))
      end
    end

    ##
    #
    # Complete representation of market price data response,
    # except "removed selection" which is returned as raw string.
    #
    ##
    def prices_complete(prices)
      aux_hash   = {}
      price_hash = {}

      prices.gsub! '\:', "\0"
      pieces = prices.split ":"

      # parsing first the auxiliary price info
      aux = pieces.first
      aux.gsub! "\0", '\:'
      foo = aux.split('~')
      aux_hash =   {
        :market_id                      => foo[0].to_i,
        :currency                       => foo[1].to_s,
        :market_status                  => foo[2].to_s,
        :in_play_delay                  => foo[3].to_i,
        :number_of_winners              => foo[4].to_i,
        :market_information             => foo[5].to_s,
        :discount_allowed               => foo[6] == 'true' ? true : false,
        :market_base_rate               => foo[7].to_s,
        :refresh_time_in_milliseconds   => foo[8].to_i,
        :removed_selections             => foo[9].to_s,
        :bsp_market                     => foo[10] == 'Y' ? true : false
      }

      # now iterating over the prices excluding the first piece that we already parsed above
      pieces[1..-1].each do |piece|
        piece.gsub! "\0", '\:'

        bar = piece.split('~')
        # using the selection_id as hash key
        price_hash_key = bar[0].to_i

        price_hash[price_hash_key] = {
          :selection_id                 => bar[0].to_i,
          :order_index                  => bar[1].to_i,
          :total_amount_matched         => bar[2].to_f,
          :last_price_matched           => bar[3].to_f,
          :handicap                     => bar[4].to_f,
          :reduction_factor             => bar[5].to_f,
          :vacant                       => bar[6] == 'true' ? true : false,
          :far_sp_price                 => bar[7].to_f,
          :near_sp_price                => bar[8].to_f,
          :actual_sp_price              => bar[9].to_f
        }

        # merge lay and back prices into price_hash
        price_hash[price_hash_key].merge!(price_string(piece, true))
      end

      price_hash.merge!(aux_hash)

      return price_hash
    end

    def price_string(string, prices_only = false)
      string_raw = string
      string = string.split('|')

      price = { :prices_string => nil, :selection_matched => 0, :last_back_price => 0, :wom => 0,
        :b1 => 0, :b1_available => 0, :b2 => 0, :b2_available => 0, :b3 => 0, :b3_available => 0,
        :l1 => 0, :l1_available => 0, :l2 => 0, :l2_available => 0, :l3 => 0, :l3_available => 0
      }

      if !string[0].nil? and !prices_only
        str = string[0].split('~')
        price[:prices_string] = string_raw
        price[:selection_matched] = str[2].to_f
        price[:last_back_price]   = str[3].to_f
      end

      # Get the b prices (which are actually the l prices)
      if !string[1].nil?
        b = string[1].split('~')
        price[:b1]             = b[0].to_f if !b[0].nil?
        price[:b1_available]   = b[1].to_f if !b[1].nil?
        price[:b2]             = b[4].to_f if !b[5].nil?
        price[:b2_available]   = b[5].to_f if !b[6].nil?
        price[:b3]             = b[8].to_f if !b[8].nil?
        price[:b3_available]   = b[9].to_f if !b[9].nil?
        combined_b = price[:b1_available] + price[:b2_available] + price[:b3_available]
      end

      # Get the l prices (which are actually the l prices)
      if !string[2].nil?
        l = string[2].split('~')
        price[:l1]             = l[0].to_f if !l[0].nil?
        price[:l1_available]   = l[1].to_f if !l[1].nil?
        price[:l2]             = l[4].to_f if !l[4].nil?
        price[:l2_available]   = l[5].to_f if !l[5].nil?
        price[:l3]             = l[8].to_f if !l[8].nil?
        price[:l3_available]   = l[9].to_f if !l[9].nil?
        combined_l = price[:l1_available] + price[:l2_available] + price[:l3_available]
      end

      price[:wom] = combined_b / ( combined_b + combined_l ) unless combined_b.nil? or combined_l.nil?

      return price
    end

    def odds_table
      odds_table = []
      (1.01..1.99).step(0.01).each  { |i| odds_table << i.round(2) }
      (2..2.98).step(0.02).each     { |i| odds_table << i.round(2) }
      (3..3.95).step(0.05).each     { |i| odds_table << i.round(2) }
      (4..5.9).step(0.1).each       { |i| odds_table << i.round(2) }
      (6..9.8).step(0.2).each       { |i| odds_table << i.round(2) }
      (10..19.5).step(0.5).each     { |i| odds_table << i.round(2) }
      (20..29).step(1).each         { |i| odds_table << i.round }
      (30..48).step(2).each         { |i| odds_table << i.round }
      (50..95).step(5).each         { |i| odds_table << i.round }
      (100..1000).step(10).each     { |i| odds_table << i.round }
      return odds_table
    end

    def set_betfair_odds(price, pips = 0, round_up = false, round_down = false)
      price = price.to_f
      prc = price
      case price
        when 0..1       then prc = increment = 1.01
        when 1.01..1.99 then increment = 0.01
        when 2..2.98    then increment = 0.02
        when 3..3.95    then increment = 0.05
        when 4..5.9     then increment = 0.1
        when 6..9.8     then increment = 0.2
        when 10..19.5   then increment = 0.5
        when 20..29     then increment = 1
        when 30..48     then increment = 2
        when 50..95     then increment = 5
        when 100..1000  then increment = 10
      else
        price = 1000
        increment = 1000
      end

      if round_up == true
        prc = ( (prc / increment).ceil * increment ).round(2)
      elsif round_down == true
        prc = ( (prc / increment).floor * increment ).round(2)
      else
        prc = ( (prc / increment).round * increment ).round(2)
      end

      ot = odds_table     # Set up the odds table
      unless pips == 0 and odds_table.count > 0   # If pips is 0
        index = ot.index(prc) + pips
        index = 0   if index < 0
        index = 349 if index > 349
        prc = ot[index]  # Grab x number of pips above
      end

      { price: price, prc: prc, pips: pips, increment: increment }

    end

    def get_odds_spread(back_odds = 0, lay_odds = 0)
      back_odds = set_betfair_odds(back_odds)
      lay_odds = set_betfair_odds(lay_odds)
      diff = lay_odds[:prc] - back_odds[:prc]
    end

  end

end
