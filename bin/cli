#!/usr/bin/env ruby

# frozen_string_literal: true

require 'dotenv/load'
require 'gli'
require 'eod_data/version'
require 'eod_data/client'

module EODData
  class CLI # :nodoc:
    extend GLI::App

    arguments :strict
    program_desc 'EODData CLI'
    subcommand_option_handling :normal
    version EODData::VERSION

    desc  'Login to EODData Financial Information Web Service ' \
          'and return a Login Token.'
    command :token do |cmd|
      cmd.action do
        eod_client = EODData::Client.new

        EODData::Client.logger.info("Login Token: #{eod_client.token}")
      end
    end

    desc 'Returns an end of day quote for a specific symbol.'
    arg_name 'exchange'
    arg_name 'symbol'
    command :quote do |cmd|
      cmd.action do |_global_options, _options, args|
        eod_client = EODData::Client.new

        exchange = args.shift
        symbol = args.shift

        EODData::Client.logger.info("Exchange: #{exchange}")
        EODData::Client.logger.info("Symbol: #{symbol}")

        result = eod_client.quote(exchange, symbol)

        EODData::Client.logger.info("Symbol: #{result.quote.symbol}")
        EODData::Client.logger.info("Close (adjusted): #{result.quote.adjusted_close}")
        EODData::Client.logger.info("Close: #{result.quote.close}")
      end
    end

    desc 'Returns latest end of day quotes for a list of symbols ' \
         'of a specific exchange.'
    arg_name 'exchange'
    arg_name 'symbols'
    command :quotes do |cmd|
      cmd.action do |_global_options, _options, args|
        eod_client = EODData::Client.new

        exchange = args.shift
        symbols = args.shift.split(',')

        EODData::Client.logger.info("Exchange: #{exchange}")
        EODData::Client.logger.info("Symbols: #{symbols}")

        result = eod_client.quotes(exchange, symbols)

        result.quotes.each do |quote|
          EODData::Client.logger.info("Quote: #{quote.symbol} - #{quote.close}")
        end
      end
    end

    desc  'Returns a complete list of end of day quotes for an ' \
          'entire exchange and a specific date.'
    arg_name 'exchange'
    arg_name 'quote_date'
    command :quotes_by_date do |cmd|
      cmd.action do |_global_options, _options, args|
        eod_client = EODData::Client.new
        logger = EODData::Client.logger

        exchange = args.shift
        quote_date = Date.parse(args.shift)

        logger.info("Exchange: #{exchange}")
        logger.info("Quote Date: #{quote_date}")

        result = eod_client.quotes_by_date(exchange, quote_date)

        result.quotes.each do |quote|
          logger.info("Quote: #{quote.symbol} - #{quote.adjusted_close}")
        end
      end
    end


    pre do |_global, _command, _options, _args|
      logger = Logger.new(STDOUT)

      EODData::Client.configure do |config|
        config.base_url = ENV.fetch('EOD_URL')
        config.logger = logger
        config.password = ENV.fetch('EOD_PASSWORD')
        config.request_type = EODData::Client::SavonRequest
        config.symbol_price_uoms = {
          KE: 'Bushel',
          MW: 'Bushel',
          ZC: 'Bushel',
          ZM: 'Ton'
        }
        config.username = ENV.fetch('EOD_USERNAME')
      end

      true
    end
  end
end

exit EODData::CLI.run(ARGV)
