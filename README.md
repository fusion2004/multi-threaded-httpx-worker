# multi-threaded-httpx-worker

A Ruby application demonstrating multi-threaded HTTP requests using the HTTPX gem with a shared session.

## Features

- **Shared HTTPX Session**: All threads use a single persistent HTTPX session for efficient connection pooling
- **10 Concurrent Threads**: Each thread continuously makes requests to `https://localhost:8080`
- **Clean Shutdown**: Ctrl-C (SIGINT) or SIGTERM triggers graceful shutdown of all threads
- **Error Handling**: Each thread captures and logs errors with thread identification
- **Thread-Safe**: Uses mutex for safe shutdown coordination across threads

## Requirements

- Ruby
- Bundler

## Installation

Install dependencies using bundler:

```bash
bundle install
```

## Usage

Run the worker:

```bash
bundle exec ruby worker.rb
```

The application will:
1. Create a shared HTTPX session
2. Start 10 worker threads
3. Each thread will continuously request `https://localhost:8080`
4. Log all requests, responses, and errors with thread identification
5. Continue until you press Ctrl-C

To stop the application cleanly, press **Ctrl-C**. All threads will complete their current request and shut down gracefully.

## Output Example

```
Starting multi-threaded HTTPX worker
Target: https://localhost:8080
Threads: 10
Press Ctrl-C to initiate clean shutdown

[Thread 1] Starting worker thread
[Thread 2] Starting worker thread
[Thread 3] Starting worker thread
...
[Thread 1] HTTPX Error on request #1: HTTPX::ConnectionError - Connection refused
[Thread 2] HTTPX Error on request #1: HTTPX::ConnectionError - Connection refused
...

^C
Received SIGINT (Ctrl-C), initiating clean shutdown...
[Thread 1] Shutting down after 5 requests
[Thread 2] Shutting down after 5 requests
...
All threads have shut down cleanly. Exiting.
```

## Configuration

You can modify the following in `worker.rb`:
- **Target URL**: Change `'https://localhost:8080'` to your desired endpoint
- **Number of threads**: Modify the `10.times` loop
- **Request delay**: Adjust `sleep(0.1)` to control request rate per thread

## Dependencies

- [HTTPX](https://gitlab.com/os85/httpx) - HTTP client library with HTTP/2 support
