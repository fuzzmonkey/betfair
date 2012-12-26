require 'faraday'
require 'json'

require_relative 'jsonrpc_methods'
require_relative 'jsonrpc_helpers'

module Betfair

  module JSONRPC

    class Client
      include Methods
      include Helpers

      attr_accessor :application_key, :session_token

      def initialize client_options
        @client_options = client_options
      end

      def setup_connection application_key, session_token
        @application_key = application_key
        @session_token = session_token
        @connection = Faraday.new(:url => 'https://beta-api.betfair.com/json-rpc') do |faraday|
          faraday.adapter @client_options[:adapter] ? @client_options[:adapter] : Faraday.default_adapter
        end
      end

      def make_request method, params
        response = @connection.post do |request|
          request.headers['X-Application'] = @application_key
          request.headers['X-Authentication'] = @session_token
          request.headers['Content-Type'] = 'application/json'
          request.body = { jsonrpc: '2.0', method: method, params: params, id: 1 }.to_json
        end
        JSON.parse(response.body, symbolize_names: true)
        # error handling - either return :success => false or raise exception? Exceptions are a PITA with fibers..
      end

    end

  end

end