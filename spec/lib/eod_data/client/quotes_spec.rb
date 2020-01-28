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

  describe '#quotes' do
    context 'when no matching quotes can be found' do
      it 'returns no quotes' do
        # Arrange
        client = described_class.new(
          base_url: 'http://localhost:8080',
          logger: Logger.new(IO::NULL)
        )
        exchange = 'CBOT'
        token = Faker::Alphanumeric.alphanumeric(number: 12).upcase

        # We don't want to have to mock out the token authentication.
        allow(client)
          .to receive(:token)
          .and_return(token)
        quote_response = format(
          EODData::XmlTemplates::QuoteList::SUCCESS,
          message: 'Success',
          quotes: ''
        )
        wsdl = File.read('./spec/fixtures/eod_data.wsdl.xml')

        savon
          .expects(:quote_list2)
          .with(
            message: {
              Exchange: exchange,
              Symbols: %w[ZCH20 ZCN20].join(','),
              Token: token
            }
          )
          .returns(quote_response)
        stub_request(:get, 'http://localhost:8080/data.asmx?WSDL')
          .to_return(status: 200, body: wsdl)
        # Act
        result = client.quotes(exchange, %w[ZCH20 ZCN20])
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
            change: 10,
            close: 399.25,
            date_time: DateTime.now,
            description: 'Corn {Jul 20}',
            high: 401.75,
            low: 397.75,
            modified: DateTime.now,
            name: 'Corn {Jul 20}',
            next_open: 0,
            open: 399,
            open_interest: 262_184,
            previous: 399.25,
            previous_close: 0,
            symbol: 'ZCN20',
            volume: 34_707
          ),
          format(
            EODData::XmlTemplates::QUOTE_ELEMENT,
            ask: 0,
            bid: 0,
            change: 1.25,
            close: 388.75,
            date_time: DateTime.now,
            description: 'Corn {Mar 20}',
            high: 391,
            low: 386.75,
            modified: DateTime.now,
            name: 'Corn {Mar 20}',
            next_open: 0,
            open: 387.5,
            open_interest: 686_635,
            previous: 387.5,
            previous_close: 0,
            symbol: 'ZCH20',
            volume: 182_958
          )
        ]
        quote_response = format(
          EODData::XmlTemplates::QuoteList::SUCCESS,
          message: 'Success',
          quotes: quotes.join
        )
        wsdl = File.read('./spec/fixtures/eod_data.wsdl.xml')

        savon
          .expects(:quote_list2)
          .with(
            message: {
              Exchange: exchange,
              Symbols: %w[ZCH20 ZCN20].join(','),
              Token: token
            }
          )
          .returns(quote_response)
        stub_request(:get, 'http://localhost:8080/data.asmx?WSDL')
          .to_return(status: 200, body: wsdl)
        # Act
        result = client.quotes(exchange, %w[ZCH20 ZCN20])
        # Assert
        expect(result).to have_attributes(
          message: 'Success',
          quotes: include(
            have_attributes(
              close: '388.75',
              description: 'Corn {Mar 20}',
              name: 'Corn {Mar 20}',
              symbol: 'ZCH20'
            ),
            have_attributes(
              close: '399.25',
              description: 'Corn {Jul 20}',
              name: 'Corn {Jul 20}',
              symbol: 'ZCN20'
            )
          ),
          success?: true
        )
      end
    end
  end
end
