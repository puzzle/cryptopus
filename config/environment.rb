# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
require 'benchmark'
puts "initialize app: #{Benchmark.measure { Cryptopus::Application.initialize! } }"

HTTPS_HOST = 'http://localhost:8080/'
