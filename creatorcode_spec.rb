require 'rspec'
require 'rack/test'

RSpec.describe 'Creator Code Check', type: :feature do
  include Rack::Test::Methods

  class User < Sequel::Model
    unrestrict_primary_key
  end

  before(:each) do
    @existing_user = User.create(user_name: 'testuser', creator_code: 'ABCDEF')
  end

  it 'accepts a valid creator code' do
    post '/checkCreatorCode', creatorCode: 'ABCDEF'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Success')
  end

  it 'rejects an invalid creator code' do
    post '/checkCreatorCode', creatorCode: 'INVALID123'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Fail') 
  end
end