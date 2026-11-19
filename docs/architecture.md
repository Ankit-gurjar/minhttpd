# Architecture notes

## Project objective

Build a small, educational, production-oriented HTTP/1.1 server in C++20 using POSIX sockets
and standard-library concurrency primitives. The implementation is written by the project
owner; these files are only the repository scaffold and design prompts.

## Intended baseline architecture

```text
                         TCP client
                             |
                             v
                      Listening socket
                             |
                          accept()
                             |
                             v
                        Bounded queue
                             |
               +-------------+-------------+
               |             |             |
             Worker 1      Worker 2      Worker N
               |             |             |
               +-------------+-------------+
                             |
                             v
                        HTTP parser
                             |
                         HttpRequest
                             |
                           Router
                  +----------+----------+
                  |          |          |
                 Root       Echo      Static
                  |          |          |
                  +----------+----------+
                             |
                       HttpResponse
                             |
                          send all
                             |
                           Client
```

## Planned responsibilities

| Component | Responsibility | Planned milestone |
|---|---|---:|
| `Socket` | Own and manage a POSIX socket descriptor using RAII | Day 3 |
| `Server` | Coordinate listener, accept loop, queue, and shutdown | Day 3 onward |
| `HttpRequest` | Store parsed method, target, version, headers, and body | Day 6 |
| `HttpResponse` | Store status, headers, and response body | Day 5 |
| `HttpParser` | Convert a bounded byte sequence into a request or parse error | Day 6 |
| `Router` | Match method + path and dispatch a handler | Day 7 |
| `ThreadPool` | Run accepted-connection jobs on a fixed worker set | Days 9–11 |
| `Logger` | Emit consistent timestamped log messages | Day 12 |
| `Config` | Hold validated server configuration | Day 12 |

## Intended initial request lifecycle

1. The process creates a listening TCP socket and binds it to a configured port.
2. The accept loop accepts a client connection, obtaining a distinct connected socket descriptor.
3. The accepted descriptor is submitted to a bounded work queue.
4. A worker reads a bounded request, parses HTTP, dispatches a handler, and writes a response.
5. The initial baseline closes the client connection after one response (`Connection: close`).
6. Shutdown stops accepting, wakes workers, resolves queued work according to the documented policy,
   joins threads, and releases resources.

This is a design target, not implemented behavior. Validate each step while building it.

## Initial endpoint ideas

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/` | Small plain-text or HTML welcome response |
| `GET` | `/health` | Health response |
| `GET` | `/echo?message=...` | Echo a query parameter |
| `POST` | `/echo` | Echo a bounded request body |
| `GET` | `/static/<path>` | Serve files beneath a configured document root |

These are a small demonstration surface, not a database-backed CRUD API.

## Initial constraints

- HTTP/1.1 only.
- Blocking POSIX socket I/O in the baseline.
- One request per connection initially; close after responding.
- Fixed-size worker pool with a bounded queue.
- Explicit limits for request line, headers, and body.
- No TLS, HTTP/2, chunked transfer coding, or advanced proxy behavior in the baseline.
- Never map a request path directly to an unrestricted filesystem path.

## Questions to resolve before implementation

- What should happen when the work queue is full?
- What happens if a client disconnects while a worker is reading or writing?
- Which component owns each file descriptor, and who closes it?
- How will `EINTR`, partial `recv()`, and partial `send()` be handled?
- What are the request and header size limits?
- What is the exact shutdown policy for queued and active jobs?
