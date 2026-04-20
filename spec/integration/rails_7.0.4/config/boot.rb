ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'logger' # Ensure Logger is defined before bootsnap/activesupport load it out of order.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
