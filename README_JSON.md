# BETFAIR JSON API #


## Install the gem ##

Install it with [RubyGems](http://rubygems.org/gems/betfair)

      gem install betfair (note version 1.0.6 will be the last supported version for the SOAP API. It will deprecated from the Gem once the new JSON
                          API is complete)

or add this to your Gemfile if you use [Bundler](http://gembundler.com/):

      gem 'betfair', '>=1.0.7'

## Introduction
In a irb console

    require 'betfair'

From a Gemfile

    gem 'betfair', '>=1.0.7'

Load the general api class

    @bf = Betfair::JSONRPC.new


# API METHODS #

## Initialize API ##

  @bf = Betfair::JSONRPC.new('app_key', 'username', 'password')

## List competitions ##

  @bf.list_competitions([1,2,3,4])


# To Do #
* WRITE TESTS, need to work out best way to do this

## Contribute ##
Betfair is currently building out its new API based on RESTful JSON approach.

If you wish to contribute please for this repo, add any API calls or helper methods that you like.

Please make sure they are well tested and give me a pull request.

You will need to email bdp@betfair.com asking for an application key to access the JSON version of the API.

Tell them you are contributing to this gem.

## License ##
(The MIT License)

Copyright (c) 2012 Luke Byrne

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
