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

  describe '#quotes_by_date' do
    context 'when no matching quotes can be found' do
      it 'returns no quotes' do
        # Arrange
        EODData::Client.configure do |config|
          config.price_conversion_class_names = {
            ZC: 'BushelPrice'
          }
        end

        client = described_class.new(
          base_url: 'http://localhost:8080',
          logger: Logger.new(IO::NULL)
        )
        exchange = 'CBOT'
        quote_date = Date.new(2020, 1, 1)
        token = Faker::Alphanumeric.alphanumeric(number: 12).upcase

        # We don't want to have to mock out the token authentication.
        allow(client)
          .to receive(:token)
          .and_return(token)
        quote_response = format(
          EODData::XmlTemplates::QuoteListByDate::SUCCESS,
          message: 'Success',
          quotes: ''
        )
        wsdl = File.read('./spec/fixtures/eod_data.wsdl.xml')

        savon
          .expects(:quote_list_by_date)
          .with(
            message: {
              Exchange: exchange,
              QuoteDate: quote_date.strftime('%Y%m%d'),
              Token: token
            }
          )
          .returns(quote_response)
        stub_request(:get, 'http://localhost:8080/data.asmx?WSDL')
          .to_return(status: 200, body: wsdl)
        # Act
        result = client.quotes_by_date(exchange, quote_date)
        # Assert
        expect(result).to have_attributes(
          message: 'Success',
          quotes: be_empty,
          success?: true
        )
      end
    end

    context 'when matching quotes can be found' do
      it 'returns the matching quotes' do
        # Arrange
        client = described_class.new(
          base_url: 'http://localhost:8080',
          logger: Logger.new(IO::NULL)
        )
        exchange = 'CBOT'
        quote_date = Date.new(2020, 1, 1)
        token = Faker::Alphanumeric.alphanumeric(number: 12).upcase

        # We don't want to have to mock out the token authentication.
        allow(client)
          .to receive(:token)
          .and_return(token)
        quotes = [
          format(
            EODData::XmlTemplates::QUOTE_ELEMENT,
            ask: 0,
            bid: 0,
            change: 0,
            close: 387.75,
            date_time: DateTime.new(2020, 1, 1),
            description: 'Corn {Mar 20}',
            high: 387.75,
            low: 387.75,
            modified: DateTime.new(1, 1, 1),
            name: 'Corn {Mar 20}',
            next_open: 0,
            open: 387.75,
            open_interest: 0,
            previous: 0,
            previous_close: 0,
            symbol: 'ZCH20',
            volume: 0
          ),
          format(
            EODData::XmlTemplates::QUOTE_ELEMENT,
            ask: 0,
            bid: 0,
            change: 0,
            close: 411.25,
            date_time: DateTime.new(2020, 1, 1),
            description: 'Corn {Mar 21}',
            high: 411.25,
            low: 411.25,
            modified: DateTime.new(1, 1, 1),
            name: 'Corn {Mar 21}',
            next_open: 0,
            open: 411.25,
            open_interest: 0,
            previous: 0,
            previous_close: 0,
            symbol: 'ZCH21',
            volume: 0
          )
        ]
        quote_response = format(
          EODData::XmlTemplates::QuoteListByDate::SUCCESS,
          message: 'Success',
          quotes: quotes.join
        )
        wsdl = File.read('./spec/fixtures/eod_data.wsdl.xml')

        savon
          .expects(:quote_list_by_date)
          .with(
            message: {
              Exchange: exchange,
              QuoteDate: quote_date.strftime('%Y%m%d'),
              Token: token
            }
          )
          .returns(quote_response)
        stub_request(:get, 'http://localhost:8080/data.asmx?WSDL')
          .to_return(status: 200, body: wsdl)
        # Act
        result = client.quotes_by_date(exchange, quote_date)
        # Assert
        expect(result).to have_attributes(
          message: 'Success',
          quotes: include(
            have_attributes(
              adjusted_close: 3.8775,
              close: '387.75',
              description: 'Corn {Mar 20}',
              name: 'Corn {Mar 20}',
              symbol: 'ZCH20'
            ),
            have_attributes(
              adjusted_close: 4.1125,
              close: '411.25',
              description: 'Corn {Mar 21}',
              name: 'Corn {Mar 21}',
              symbol: 'ZCH21'
            )
          ),
          success?: true
        )
      end
    end
  end
end
