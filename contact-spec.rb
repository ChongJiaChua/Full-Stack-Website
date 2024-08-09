require "rspec"

RSpec.describe "Contact View" do
    describe "GET /contact" do
        it "loads the contact form page" do
          get "/contact"
    
          expect(last_response.status).to eq(200)
          expect(last_response.body).to include("Customer Contact Form")
        end
      end
    
      describe "POST /contact" do
        let(:valid_params) do
          {
            "email_address" => "example1@gmail.com",
            "problem" => "Popcorn",
            "comments" => "I need help with popcorn."
          }
        end
    
        context "with a valid email address" do
          it "submits the form successfully and displays the success message" do
            post "/contact", valid_params
    
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include("Success, thanks for your submission!")
          end
        end
    
        context "with an invalid email address" do
          let(:invalid_params) do
            valid_params.merge("email_address" => "invalid-email")
          end
    
          it "displays an error message for the invalid email address" do
            post "/contact", invalid_params
    
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include("Please enter a valid email address")
          end
        end
    
        context "with missing email address" do
          let(:missing_email_params) do
            valid_params.merge("email_address" => "")
          end
    
          it "displays an error message for the missing email address" do
            post "/contact", missing_email_params
    
            expect(last_response.status).to eq(200)
            expect(last_response.body).to include("Please enter a valid email address")
          end
        end
      end
    end