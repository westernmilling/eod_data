# frozen_string_literal: true

require 'savon'

module EODData
  class Client # :nodoc:
    class << self
      attr_accessor :base_url,
                    :logger,
                    :password,
                    :price_conversion_class_names,
                    :proxy_url,
                    :request_type,
                    :username

      # ```ruby
      # EODData::Client.configure do |config|
      #   config.base_url = 'http://localhost:3000'
      #   config.logger = Logger.new(STDOUT)
      #   config.password = 'password'
      #   config.price_conversion_class_names = {
      #     ZC: 'OriginalPrice'
      #     ZM: 'TonPrice'
      #   }
      #   config.username = 'username'
      # end
      # ```
      # elsewhere
      #
      # ```ruby
      # client = EODData::Client.new
      # ```
      def configure
        yield self
        true
      end
    end

    def initialize(options = {})
      options = default_options.merge(options)

      @base_url = options[:base_url]
      @logger = options.compact.fetch(:logger, Logger.new(STDOUT))
      @proxy_url = options[:proxy_url]
      @password = options[:password]
      @username = options[:username]
      @request = SavonRequest.new(@base_url, @logger, @proxy_url)
    end

    def login
      message = { Username: @username, Password: @password }

      response = @request.perform_request(:login, message: message)

      LoginResponse.new(response).result
    end

    def quote(exchange, symbol)
      message = { Exchange: exchange, Symbol: symbol, Token: token }

      response = @request.perform_request(:quote_get, message: message)

      QuoteGetResponse.new(response).result
    end

    def quotes(exchange, symbols)
      message = { Exchange: exchange, Symbols: symbols.join(','), Token: token }

      response = @request.perform_request(:quote_list2, message: message)

      QuoteList2Response.new(response).result
    end

    def quotes_by_date(exchange, quote_date)
      message = {
        Exchange: exchange,
        QuoteDate: quote_date.strftime('%Y%m%d'),
        Token: token
      }

      response = @request.perform_request(:quote_list_by_date, message: message)

      QuoteListByDateResponse.new(response).result
    end

    ##
    #
    #
    # @return [String] Login Token
    def token
      return @token if @token

      @token = login.token
    end

    protected

    ##
    # Default options
    # A {Hash} of default options populate by attributes set during
    # configuration.
    #
    # @return [Hash] containing the default options
    def default_options
      {
        base_url: EODData::Client.base_url,
        logger: EODData::Client.logger,
        proxy_url: EODData::Client.proxy_url,
        password: EODData::Client.password,
        username: EODData::Client.username
      }
    end

    class OriginalPrice # :nodoc:
      def initialize(price)
        @price = price
      end

      def call
        @price
      end
    end

    class CentsPerPoundPrice # :nodoc:
      def initialize(price)
        @price = price
      end

      def call
        @price.to_f / 100
      end
    end

    class BushelPrice # :nodoc:
      def initialize(price)
        @price = price
      end

      def call
        components = @price.strip.split('.')
        fraction_amount = components[1] || 0

        "#{components[0]}.#{fraction_amount}".to_f / 100
      end
    end

    class Response # :nodoc:
      def initialize(response)
        @response = response.body["#{response_name}_response".to_sym]
      end

      def result
        @result ||= result_class.new(
          @response["#{response_name}_result".to_sym]
        )
      end

      protected

      def result_class
        @result_class ||= begin
          result_class_name = self.class.name.sub('Response', 'Result')

          Object.const_get(result_class_name)
        end
      end

      def response_name
        @response_name ||=  self
                            .class
                            .name
                            .chomp('Response')
                            .split('::')
                            .last
                            .gsub(/(.)([A-Z])/, '\1_\2')
                            .downcase
      end
    end

    class Result # :nodoc:
      def initialize(response)
        @response = response
      end

      def data
        @response
      end

      def data_value
        data["@#{__callee__}".to_sym]
      end

      def message
        @response[:@message]
      end

      def result
        @response ? :success : :failure
      end

      def success?
        result == :success
      end
    end

    class LoginResponse < Response; end

    class LoginResult < Result # :nodoc:
      alias token data_value
    end

    class Quote < OpenStruct # :nodoc:
      def adjusted_price
        price = send(__callee__.to_s.sub('adjusted_', '').to_sym)

        convert_price(price)
      end

      alias adjusted_ask adjusted_price
      alias adjusted_change adjusted_price
      alias adjusted_close adjusted_price
      alias adjusted_high adjusted_price
      alias adjusted_low adjusted_price
      alias adjusted_open adjusted_price
      alias adjusted_previous adjusted_price

      protected

      def convert_price(price)
        symbol_symbol = symbol[0, 2].to_sym

        converter_klass = Object.const_get(
          [
            'EODData::Client',
            EODData::Client.price_conversion_class_names[symbol_symbol]
          ].join('::')
        )

        converter_klass.new(price).call
      end
    end

    class QuoteGetResponse < Response; end

    class QuoteGetResult < Result # :nodoc:
      def quote
        @quote ||= Quote.new(
          data.transform_keys { |key| key.to_s.sub('@', '') }
        )
      end

      def data
        @response[:quote]
      end
    end

    class QuoteList2Response < Response; end
    class QuoteListByDateResponse < Response; end

    class QuoteList2Result < Result # :nodoc:
      def quotes
        @quotes ||= data.map do |quote_data|
          Quote.new(quote_data.transform_keys { |key| key.to_s.sub('@', '') })
        end
      end

      protected

      def data
        return [] if @response.fetch(:quotes, nil).nil?

        [@response[:quotes][:quote]].flatten
      end
    end
    class QuoteListByDateResult < QuoteList2Result; end

    class SavonRequest # :nodoc:
      def initialize(base_url, logger, proxy_url = nil)
        @base_url = base_url
        @logger = logger
        @proxy_url = proxy_url
      end

      def perform_request(name, message)
        @logger.info("SavonRequest#perform_request #{name}, #{message}")

        response = client.call(name, message)

        response
      end

      protected

      def client
        options = {
          wsdl: wsdl,
          convert_request_keys_to: :none,
          raise_errors: false,
          logger: @logger,
          log: true,
          log_level: :debug
        }
        options = options.merge(proxy: @proxy_url) unless @proxy_url.to_s == ''

        Savon.client(options)
      end

      def wsdl
        "#{@base_url}/data.asmx?WSDL"
      end
    end
  end
end
