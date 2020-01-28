# frozen_string_literal: true

RSpec.describe EODData do
  it 'has a version number' do
    expect(EODData::VERSION).not_to be nil
  end
end
