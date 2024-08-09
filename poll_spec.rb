require "rspec"

RSpec.describe "Createpoll View" do
    describe "POST /createpoll" do
        it "creates a new poll" do
            post "/createpoll", {"title" => "testPoll", "story" => "0:test", "q1" => "This is a test?", "a11" => "yes", "a21" => "no", "a31" => "maybe",
            "q2" => "", "a12" => "yes", "a22" => "", "a32" => "", "q3" => "", "a13" => "", "a23" => "", "a33" => ""}, { "rack.session" => {user: "user"} }
            expect(last_response.body).to include("Your poll has been created!")
        end
    end
end

RSpec.describe "Poll Search View" do
    describe "POST /poll" do
        it "Searches for test poll" do
            post "/poll", "storytitle" => "test"
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include("testPoll")
        end

        it "Searches for invalid poll" do
            post "/poll", "storytitle" => "toast"
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include("Sorry, no polls have been created for that story")
        end
    end
end

RSpec.describe "View Poll View" do
    describe "POST /viewpoll" do
        it "votes for a poll - if never voted before" do
            $pollToView = Poll.first(id: 0)
            post "/answerpoll", {"0" => "yes"} ,{ "rack.session" => {pollId: 0} }
            expect(last_response.body).to include("Vote Submitted")
        end
        it "votes for a poll - if voted before" do
            $pollToView = Poll.first(id: 0)
            post "/answerpoll", {"0" => "yes"} ,{ "rack.session" => {pollId: 0} }
            post "/answerpoll", {"0" => "yes"} ,{ "rack.session" => {pollId: 0} }
            expect(last_response.body).to include("Vote Submitted")
        end
    end
end