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

  describe '#login' do
    context 'when the login details are valid' do
      it 'returns a new login token' do
        # Arrange
        password = Faker::Internet.password
        username = Faker::Internet.username
        client = described_class.new(
          base_url: 'http://localhost:8080',
          logger: Logger.new(IO::NULL),
          password: password,
          username: username
        )
        token = Faker::Alphanumeric.alphanumeric(number: 12).upcase
        response = format(
          EODData::XmlTemplates::Login::SUCCESS,
          message: 'Login Successful',
          token: token
        )
        wsdl = File.read('./spec/fixtures/eod_data.wsdl.xml')

        savon
          .expects(:login)
          .with(
            message: {
              Username: username,
              Password: password
            }
          )
          .returns(response)
        stub_request(:get, 'http://localhost:8080/data.asmx?WSDL')
          .to_return(status: 200, body: wsdl)
        # Act
        result = client.login
        # Assert
        expect(result).to have_attributes(
          message: 'Login Successful',
          success?: true,
          token: token
        )
      end
    end

    context 'when the login details are invalid' do
      it 'returns a failure message' do
        # Arrange
        password = Faker::Internet.password
        username = Faker::Internet.username
        client = described_class.new(
          base_url: 'http://localhost:8080',
          logger: Logger.new(IO::NULL),
          password: password,
          username: username
        )
        response = format(
          EODData::XmlTemplates::Login::FAILURE,
          message: 'Invalid Username or Password'
        )
        wsdl = File.read('./spec/fixtures/eod_data.wsdl.xml')

        savon
          .expects(:login)
          .with(
            message: {
              Username: username,
              Password: password
            }
          )
          .returns(response)
        stub_request(:get, 'http://localhost:8080/data.asmx?WSDL')
          .to_return(status: 200, body: wsdl)
        # Act
        result = client.login
        # Assert
        expect(result).to have_attributes(
          message: 'Invalid Username or Password',
          success?: true,
          token: nil
        )
      end
    end
  end
end
