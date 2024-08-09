require "rspec"


RSpec.describe "Payment View" do
    describe "GET /payment" do
        it "Load Check: Status 200" do
            get "/payment"
            expect(last_response.status).to eq(200)
        end
    end

    describe "POST /addPopcorn" do
        context "with not enough popcorn" do 
            it "tells user error in payment" do
                post "/addPopcorn", {"popcorn_amount" => 50, "price" => 250 }
                expect(last_response).to be_ok
                expect(last_response.body).to include("There has been an error in your payment.")
            end
        end

        context "with enough popcorn" do 
            it "redirects to homepage" do
                post "/addPopcorn", {"popcorn_amount" => 50, "price" => 2.50 }
                expect(last_response).to be_ok
            end
        end
    end
end