# frozen_string_literal: true

require 'spec_helper'
require 'savon/mock/spec_helper'
require 'eod_data/client'
require_relative 'xml_templates'

RSpec.describe EODData::Client do
  include Savon::SpecHelper

  after do
    savon.unmock!
  end

  before do
    savon.mock!
  end

  describe '#quote' do
    context 'when a matching quote can be found' do
      it 'returns the matching quote' do
        # Arrange
        client = described_class.new(
          base_url: 'http://localhost:8080',
          logger: Logger.new(IO::NULL)
        )
        exchange = 'CBOT'
        symbol = 'ZCH20'
        token = Faker::Alphanumeric.alphanumeric(number: 12).upcase
        # We don't want to have to mock out the token authentication.
        allow(client)
          .to receive(:token)
          .and_return(token)
        quote = format(
          EODData::XmlTemplates::QUOTE_ELEMENT,
          ask: 0,
          bid: 0,
          change: 10,
          close: 350.0,
          date_time: DateTime.now,
          description: 'Corn {Mar 20}',
          high: 350,
          low: 340,
          modified: DateTime.now,
          name: 'Corn {Mar 20}',
          next_open: 0,
          open: 340,
          open_interest: 0,
          previous: 350,
          previous_close: 350,
          symbol: symbol,
          volume: 1000
        )
        quote_response = format(
          EODData::XmlTemplates::QuoteGet::SUCCESS,
          message: 'Success',
          quote: quote
        )
        wsdl = File.read('./spec/fixtures/eod_data.wsdl.xml')

        savon
          .expects(:quote_get)
          .with(
            message: {
              Exchange: exchange,
              Symbol: symbol,
              Token: token
            }
          )
          .returns(quote_response)
        stub_request(:get, 'http://localhost:8080/data.asmx?WSDL')
          .to_return(status: 200, body: wsdl)
        # Act
        result = client.quote(exchange, symbol)
        # Assert
        expect(result).to have_attributes(
          message: 'Success',
          quote: have_attributes(
            close: '350.0',
            description: 'Corn {Mar 20}',
            name: 'Corn {Mar 20}',
            symbol: symbol
          ),
          success?: true
        )
      end
    end
  end
end
