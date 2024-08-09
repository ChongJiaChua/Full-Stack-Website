require "rspec"

RSpec.describe "Payment View" do
  
  before(:all) do
    DB.execute("PRAGMA foreign_keys = OFF;")
  end

  after(:all) do
    DB.execute("PRAGMA foreign_keys = ON;")
  end

  describe "when a user correctly buys popcorn" do
    it "adds the popcorn to the database" do
      session = { "user" => "user", "logged_in" => true } #Assert the session value
      user = User.first(user_name: "user")
      post "/addPopcorn", {"popcorn_amount" => "40", "price" => "10"}, {"rack.session" => session}
      expect(user).not_to be_nil
      expect(user.popcorn).to eq(100)
    end

    it "takes the money from the account" do
      session = { "user" => "user", "logged_in" => true } #Assert the session value
      user = User.first(user_name: "user")
      post "/addPopcorn", {"popcorn_amount" => "40", "price" => "10"}, {"rack.session" => session}
      expect(user).not_to be_nil
      expect(user.compound).to eq(100)
    end
  end
end