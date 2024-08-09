# Gems
require "require_all"
require "sinatra"
require "logger"
require "openssl"
require "sequel"
require "rspec"

# So we can escape HTML special characters in the view
include ERB::Util

# Sessions
enable :sessions

# Database
mode = ENV.fetch("APP_ENV", "databases")
path = File.dirname(__FILE__)
file_minus_ext = "#{path}/#{mode}"

DB = Sequel.sqlite("#{file_minus_ext}.sqlite3",
                   logger: Logger.new("#{file_minus_ext}.log"))


# Directories that are required
require_rel "models", "controller"