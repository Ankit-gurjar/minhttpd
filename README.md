# minhttpd

A small, production-oriented **HTTP/1.1 server built from scratch** using **C++20, POSIX sockets,
threads, and CMake**.

This is a systems-programming learning project, not a CRUD application and not a wrapper around
an existing HTTP server library. The goal is to understand the network and operating-system
mechanics beneath web frameworks: file descriptors, TCP streams, HTTP framing, partial I/O,
resource limits, thread pools, synchronization, and graceful shutdown.

> **Current status:** The actual server is not
> implemented yet. Future source/header files are intentionally TODO-only so the implementation
> and design decisions remain yours.

## Project goals

By the end of the build, the intended server should:

- Accept TCP connections using POSIX sockets.
- Parse a deliberately limited, documented subset of HTTP/1.1.
- Generate correct HTTP responses and handle common malformed-request cases.
- Route a few small endpoints without a database.
- Serve static files only from a configured document root.
- Dispatch accepted connections to a fixed-size worker pool.
- Use a bounded queue and define behavior under overload.
- Apply request/header/body size limits.
- Handle partial reads/writes and client disconnects correctly.
- Log requests/errors and expose basic server statistics.
- Shut down cleanly and release owned resources.
- Include unit/integration tests and a reproducible benchmark report.

## Planned technology

| Area                 | Choice                                                                |
| -------------------- | --------------------------------------------------------------------- |
| Language             | C++20                                                                 |
| Operating-system API | POSIX sockets available on macOS                                      |
| Concurrency          | `std::thread`, `std::mutex`, `std::condition_variable`, `std::atomic` |
| Build system         | CMake                                                                 |
| Build executor       | Ninja                                                                 |
| Compiler on Mac      | Apple Clang from Xcode Command Line Tools                             |
| Tests                | CTest initially; test framework decision later                        |
| Debugging            | LLDB, AddressSanitizer, UndefinedBehaviorSanitizer                    |
| Client tools         | `curl`, `nc`, `lsof`; load generator later                            |

No third-party HTTP framework is used in the baseline.

## Planned baseline architecture

```text
Client
  |
  | TCP
  v
Listening socket -> accept loop -> bounded connection queue
                                      |
                         +------------+------------+
                         |            |            |
                      Worker 1     Worker 2     Worker N
                         |            |            |
                         +------------+------------+
                                      |
                                  HTTP parser
                                      |
                                  HttpRequest
                                      |
                                    Router
                             +--------+--------+
                             |        |        |
                            Root    Echo     Static
                             |        |        |
                             +--------+--------+
                                      |
                                 HttpResponse
                                      |
                                 send response
                                      |
                                    Client
```

See [`docs/architecture.md`](docs/architecture.md) for responsibilities and design questions.

### Initial endpoint plan

| Method | Path                | Purpose                                  |
| ------ | ------------------- | ---------------------------------------- |
| `GET`  | `/`                 | Welcome response                         |
| `GET`  | `/health`           | Health response                          |
| `GET`  | `/echo?message=...` | Query-string echo                        |
| `POST` | `/echo`             | Bounded body echo                        |
| `GET`  | `/static/<path>`    | Static content beneath the document root |

The initial connection policy is one request per connection followed by close. Persistent
connections, TLS, HTTP/2, chunked transfer coding, and event-driven `kqueue` I/O are stretch goals,
not baseline requirements.

## Repository layout

```text
minhttpd/
├── CMakeLists.txt
├── CMakePresets.json
├── README.md
├── .clang-format
├── .editorconfig
├── .gitattributes
├── .gitignore
├── include/minhttpd/
│   ├── config.hpp
│   ├── http_parser.hpp
│   ├── http_request.hpp
│   ├── http_response.hpp
│   ├── logger.hpp
│   ├── router.hpp
│   ├── server.hpp
│   ├── socket.hpp
│   └── thread_pool.hpp
├── src/
│   ├── config.cpp
│   ├── http_parser.cpp
│   ├── http_request.cpp
│   ├── http_response.cpp
│   ├── logger.cpp
│   ├── main.cpp
│   ├── router.cpp
│   ├── server.cpp
│   ├── socket.cpp
│   └── thread_pool.cpp
├── tests/
│   └── README.md
├── docs/
│   ├── architecture.md
│   ├── day-01-networking-foundations.md
│   ├── day-02-macos-cmake-setup.md
│   ├── decisions.md
│   ├── learning-log.md
│   └── research-sources.md
├── scripts/
│   └── check_environment.sh
├── config/
│   └── README.md
└── static/
    └── README.md
```

The `.cpp`/`.hpp` module files are placeholders. Define interfaces only when you reach that
module's milestone; avoid designing everything before understanding the underlying behavior.

## macOS prerequisites

1. Xcode Command Line Tools (or full Xcode).
2. Apple Clang / `clang++`.
3. CMake 3.21 or newer.
4. Ninja.
5. Git.

Install Command Line Tools if they are not already present:

```bash
xcode-select --install
```

Install CMake and Ninja using Homebrew:

```bash
brew update
brew install cmake ninja
```

Check all required commands:

```bash
./scripts/check_environment.sh
```

## Build and run

From the repository root:

```bash
# Configure a Debug build
cmake --preset macos-debug

# Compile
cmake --build --preset macos-debug

# Run the starter executable
./build/debug/minhttpd

# Run the Day 2 smoke test
ctest --preset macos-debug
```

Expected output:

```text
minhttpd scaffold is ready.
```

The current smoke test only proves that the starter executable launches. It does not test
networking or HTTP behavior.

### Other build configurations

```bash
# AddressSanitizer + UndefinedBehaviorSanitizer
cmake --preset macos-asan
cmake --build --preset macos-asan
ctest --preset macos-asan

# Optimized Release build
cmake --preset macos-release
cmake --build --preset macos-release
ctest --preset macos-release
```

Build output is written beneath `build/` and is ignored by Git.

## Coding standards and project settings

- Use C++20; do not rely on compiler-specific language extensions.
- Prefer RAII for resources such as socket descriptors, locks, and files.
- Keep ownership clear: every descriptor should have one well-defined owner.
- Check system-call return values and report errors with useful context.
- Never assume one `recv()` reads a complete request or one `send()` writes a complete response.
- Bound queues and untrusted input; document overload and rejection behavior.
- Keep socket transport, HTTP parsing, routing, handlers, and logging as separate concerns.
- Do not add dependencies unless there is a clear reason and the trade-off is documented.
- Do not silence compiler warnings just to get a green build.
- Add tests for malformed input, boundary values, concurrent requests, disconnects, and shutdown.

Formatting is described by `.clang-format`; whitespace/newline defaults are in `.editorconfig`.

## Research references

- [Beej's Guide to Network Programming](https://beej.us/guide/bgnet/html/)
- [RFC 9293 — Transmission Control Protocol](https://www.rfc-editor.org/rfc/rfc9293.html)
- [RFC 9112 — HTTP/1.1](https://www.rfc-editor.org/rfc/rfc9112.html)
- [Apple — Installing Xcode Command Line Tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools)
- [CMake Presets manual](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)

A curated reading order and the specific concepts to study are in
[`docs/research-sources.md`](docs/research-sources.md).

## Scope disclaimer

This project is intended to be production-oriented in its engineering practices, but it is an
educational server and must not be represented as a hardened, general-purpose production HTTP
server. Document supported protocol behavior and known limitations honestly.
