require 'betfair'
require 'webmock/rspec'


###########
## Everything below here can go when the SOAP API is deprecated
###########
require 'savon_spec'

RSpec.configure do |config|
  HTTPI.log = false
  Savon.log = false
  config.include Savon::Spec::Macros
  Savon::Spec::Fixture.path = File.expand_path('../fixtures/soap/', __FILE__)
end

module LoginHelper
  def login( response=:success )
    @bf = Betfair::SOAP.new
    savon.expects(:login).returns( response )
    @session_token = @bf.login('username', 'password', 82, 0, 0, nil)
  end
end
