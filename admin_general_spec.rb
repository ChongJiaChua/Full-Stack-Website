require "rspec"
require "rack/test"

RSpec.describe "Admin Ban and Settings Views", type: :request do

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
      DB[:bannedusers].delete
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
  
  before(:all) do
    DB.execute("PRAGMA foreign_keys = OFF;")
  end

  after(:all) do
    DB.execute("PRAGMA foreign_keys = ON;")
  end

  describe "when an admin bans a user" do
    it "saves the banned user to the ban user database" do
      session = { "user" => "user", "logged_in" => true } #Assert the session value
      post "/admin_ban", {"username" => "test_banning", "ban_reason" => "bullying"}, {"rack.session" => session}
      ban_user = Banneduser.first(banned_user: "test_banning")
      expect(ban_user).not_to be_nil
      expect(ban_user.banned_user).to eq("test_banning")
    end
  end

  describe "when an admin changes a user's email successfully" do
    it "changes the users email in the database" do
      session = { "user" => "user", "logged_in" => true } #Assert the session value
      post "/admin_settings", {"old_username" => "test_user", "new_username" => "user3", "new_email" => "updated@example.com"}, {"rack.session" => session}
      updated_user = User.first(user_name: "test_user")
      expect(updated_user).not_to be_nil
      expect(updated_user.email).to eq("updated@example.com")
    end
  end

  describe "an admin changes a user's email with incorrect format" do
    it "does not change email in users database" do
      session = { "user" => "user", "logged_in" => true } #Assert the session value
      post "/admin_settings", {"old_username" => "test_user", "new_username" => "user3", "new_email" => "m"}, {"rack.session" => session}
      updated_user = User.first(user_name: "test_user")
      expect(updated_user).not_to be_nil
      expect(updated_user.email).to eq("test@example.com")
    end
  end
end