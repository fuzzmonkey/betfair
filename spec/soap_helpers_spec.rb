require 'tempfile'
require 'spec_helper'

module Betfair

  describe "Helper methods for mashing the data from the API - " do

    include LoginHelper

    before(:all) do
      login()
      @helpers = Betfair::SOAPHelpers.new
    end

    describe "Create a hash from the get_all_markets API call"  do
      it "pulls the relevant stuff out of get_all_markets and puts it in a hash" do
        savon.expects(:get_all_markets).returns(:success)
        markets = @bf.get_all_markets(@session_token, 2)
        markets = @helpers.split_markets_string(markets)
        markets.should_not be_nil
      end
    end

    describe "Create a hash for the market details"  do
      it "pulls the relevant stuff out of market details and puts it in a hash" do
        savon.expects(:get_market).returns(:success)
        market = @bf.get_market(@session_token, 2, 10038633)
        market_info = @helpers.market_info(market)
        market_info.should_not be_nil
      end
    end

    describe "Cleans up the get market details"  do
      it "sort the selections for each market out " do
        savon.expects(:get_market).returns(:success)
        market = @bf.get_market(@session_token, 2, 10038633)
        details = @helpers.details(market)
        details.should_not be_nil
      end
    end

    describe "Get the price string for a selection"  do
      it "so that we can combine it together with market info" do
        savon.expects(:get_market_prices_compressed).returns(:success)
        prices = @bf.get_market_prices_compressed(@session_token, 2, 10038633)
        prices = @helpers.prices(prices)
        prices.should_not be_nil
      end
    end

    describe "Combine market details and selection prices api call"  do
      it "Combines the two api calls of get_market and get_market_prices_compressed " do

        savon.expects(:get_market).returns(:success)
        market = @bf.get_market(@session_token, 2, 10038633)

        savon.expects(:get_market_prices_compressed).returns(:success)
        prices = @bf.get_market_prices_compressed(@session_token, 2, 10038633)

        combined = @helpers.combine(market, prices)
        combined.should_not be_nil
      end
    end

    describe "set up an odds tables of all possible Betfair Odds" do
      it "should return a hash of all possible Betfair odds with correct increments" do
        odds_table = @helpers.odds_table
        odds_table.should_not be_nil
        odds_table.should be_an_instance_of(Array)
        odds_table.count.should eq(350)
        odds_table[256].should eq(85)
      end

      it "should return a standard hash" do
        betfair_odds = @helpers.set_betfair_odds(275, 0, false, false)
        betfair_odds.should be_an_instance_of(Hash)
        betfair_odds[:price].should eq(275)
        betfair_odds[:prc].should eq(280)
        betfair_odds[:increment].should eq(10)
        betfair_odds[:pips].should eq(0)
      end

      it "should return a standard hash with prc at 1 pip and price rounded up" do
        betfair_odds = @helpers.set_betfair_odds(2.31, 1, true, false)
        betfair_odds.should be_an_instance_of(Hash)
        betfair_odds[:price].should eq(2.31)
        betfair_odds[:prc].should eq(2.34)
        betfair_odds[:increment].should eq(0.02)
        betfair_odds[:pips].should eq(1)
      end

      it "should return a standard hash with prc at 2 pip and price rounded down" do
        betfair_odds = @helpers.set_betfair_odds(2.31, 5, false, true)
        betfair_odds.should be_an_instance_of(Hash)
        betfair_odds[:price].should eq(2.31)
        betfair_odds[:prc].should eq(2.4)
        betfair_odds[:increment].should eq(0.02)
        betfair_odds[:pips].should eq(5)
      end

      it "should return an even spread of odds based on the odds_table method" do
        spread = @helpers.get_odds_spread(271, 343)
        spread.should eq(70.0)
        spread = @helpers.get_odds_spread(1.28, 3.43)
        spread.should eq(2.17)
      end

    end

  end
end
