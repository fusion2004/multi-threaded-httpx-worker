#!/usr/bin/env ruby
# frozen_string_literal: true

require 'httpx'

# Shared HTTPX session for all threads
SHARED_SESSION = HTTPX.plugin(:persistent).with(
  # debug_level: 3,
  # debug_redact: true,
  # debug: $stdout,
  ssl: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  timeout: { read_timeout: 2 }
)

$shutdown = false

# Signal handler for clean shutdown
trap('INT') do
  puts "\n\nReceived SIGINT (Ctrl-C), initiating clean shutdown..."
  $shutdown = true
end

trap('TERM') do
  puts "\n\nReceived SIGTERM, initiating clean shutdown..."
  $shutdown = true
end

def shutdown_requested?
  $shutdown
end

# Worker function for each thread
def worker_loop(thread_id)
  puts "[Thread #{thread_id}] Starting worker thread"
  request_count = 0

  until shutdown_requested?
    begin
      request_count += 1
      response = SHARED_SESSION.get('https://localhost:8080')

      if response.error
        puts "[Thread #{thread_id}] HTTPX Error on request ##{request_count}: #{response.error.class} - #{response.error.message}"
      else
        puts "[Thread #{thread_id}] Request ##{request_count} - Status: #{response.status}"
      end

    rescue HTTPX::Error => e
      puts "[Thread #{thread_id}] HTTPX Error on request ##{request_count}: #{e.class} - #{e.message}"
    rescue StandardError => e
      puts "[Thread #{thread_id}] Error on request ##{request_count}: #{e.class} - #{e.message}"
    end
  end

  puts "[Thread #{thread_id}] Shutting down after #{request_count} requests"
rescue StandardError => e
  puts "[Thread #{thread_id}] Fatal error: #{e.class} - #{e.message}"
  puts "[Thread #{thread_id}] Backtrace: #{e.backtrace.join("\n")}"
end

# Main execution
def main
  puts "Starting multi-threaded HTTPX worker"
  puts "Target: https://localhost:8080"
  puts "Threads: 10"
  puts "Press Ctrl-C to initiate shutdown, and again to force it\n\n"

  threads = []

  # Create 10 worker threads
  10.times do |i|
    thread_id = i + 1
    threads << Thread.new { worker_loop(thread_id) }
    sleep(0.1)
  end

  # Wait for all threads to complete
  threads.each(&:join)

  puts "\nAll threads have shut down cleanly. Exiting."
end

# Run the application
main

