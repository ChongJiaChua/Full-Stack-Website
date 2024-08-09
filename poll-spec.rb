require "rspec"


RSpec.describe "Createpoll View" do
    describe "GET /createpoll" do
        it "Load Check: Status 200" do
            get "/createpoll"
            expect(last_response.status).to eq(200)
        end
    end
end

RSpec.describe "Poll Search View" do
    describe "GET /poll" do
        it "Load Check: Status 200" do
            get "/poll"
            expect(last_response.status).to eq(200)
        end
    end
end

RSpec.describe "Poll Answer Route" do
    describe "POST /answerpoll" do
        it "Load Check: Status 200" do
            post "/answerpoll", "0" => "yes"
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include("Votes Submitted")
        end
    end
end

RSpec.describe "Viewpoll View" do
    describe "GET /viewpoll" do
        it "Load Check: Status 200" do
            get "/viewpoll", {}, { "rack.session" => {pollId: 0} }
            expect(last_response.status).to eq(200)

            expect(last_response.body).to include("Do you hear me?")
            expect(last_response.body).to include("yes")
            expect(last_response.body).to include("no")
            expect(last_response.body).to include("maybe")
        end
    end
end

RSpec.describe "Pollcreated View" do
    describe "GET /pollcreated" do
        it "Load Check: Status 200" do
            get "/pollcreated"
            expect(last_response.status).to eq(200)
        end
        it "message check" do
            get "/pollcreated"
            expect(last_response.body).to include("Your poll has been created!")
        end
    end
end