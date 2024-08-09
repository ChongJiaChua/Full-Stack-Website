require 'spec_helper'
require 'rack/test'

RSpec.describe "Settings", type: :request do
  include Rack::Test::Methods

  class User < Sequel::Model
    unrestrict_primary_key
  end

  def generate_iv
    Sequel.blob(OpenSSL::Cipher.new('AES-128-CBC').random_iv)
  end

  def generate_salt
    Sequel.blob(OpenSSL::Random.random_bytes(16))
  end

  def create_test_user(attributes = {})
    password = attributes[:password] || 'Test*1234'
    aes = OpenSSL::Cipher.new('AES-128-CBC').encrypt
    iv = generate_iv
    salt = generate_salt
    aes.iv = iv
    aes.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(password, salt, 20_000, 16)
    encrypted_password = Sequel.blob(aes.update(password) + aes.final)

    default_attributes = {
      user_name: 'test_user',
      email: 'test@example.com',
      password: encrypted_password,
      iv: iv,
      salt: salt
    }

    User.create(default_attributes.merge(attributes))
  end

  before do
    DB.transaction do
      DB[:users].delete
    end
  end

  before(:each) do
    @user = create_test_user
    @session = { 'logged_in' => true, 'user' => @user.user_name }
    allow_any_instance_of(Sinatra::Base).to receive(:session).and_return(@session)
  end

  def set_logged_in(user)
    allow_any_instance_of(Sinatra::Base).to receive(:session).and_return({ 'logged_in' => true, 'user' => user.user_name })
  end

  describe "GET /settings" do
    it "Load Check: Status 200" do
        get "/settings"
        expect(last_response.status).to eq(200)
    end
  end


  it "successfully updates settings with valid data" do
    set_logged_in(@user)
    post '/settings', {
      "newUsername" => "testuser",
      "newEmail" => "updated@example.com",
      "currentPassword" => "Test*1234",
      "newPassword" => "testuser1!"
    }
    expect(last_response).to be_redirect
    follow_redirect!

    expect(last_request.path).to eq('/settings')
    expect(last_response.body).to include("Settings")
  
  end

  it "does not update settings with an incorrect current password" do
    set_logged_in(@user)
    post '/settings', {
      newUsername: 'updateduser',
      newPassword: 'New*Pass123',
      newEmail: 'updated@example.com',
      currentPassword: 'wrong_password',
      phone_number: '1234567890'
    }

    expect(last_response).to be_ok
    expect(last_response.body).to include("Your current password is incorrect.")
    expect(User.first(user_name: 'test_user')).not_to be_nil
  end

  it "returns validation errors when provided invalid data" do
    set_logged_in(@user)
    post '/settings', {
      newUsername: 'updateduser',
      newPassword: 'short',
      newEmail: 'invalid-email',
      currentPassword: 'Test*1234',
      phone_number: '1234567890'
    }

    expect(last_response).to be_ok
    expect(last_response.body).to include("Password must be at least 8 characters long.")
    expect(last_response.body).to include("Invalid email format.")
  end

  it "returns validation errors when provided invalid data" do
    set_logged_in(@user)
    post '/settings', {
      newUsername: 'updateduser',
      newPassword: 'useroneone',
      newEmail: 'invalid-email@email.com',
      currentPassword: 'Test*1234',
      phone_number: '1234567890'
    }

    expect(last_response).to be_ok
    expect(last_response.body).to include("Password must contain at least one number.")
  end
end
