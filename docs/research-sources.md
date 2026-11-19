# Research sources

Use the sources in sequence. Start with the accessible guide, then consult the operating-system
manual pages and standards when you need precise behavior.

## Day 1 — Networking

1. [Beej's Guide to Network Programming](https://beej.us/guide/bgnet/html/) — practical socket
   programming explanations and examples. Read the sections on sockets, client/server flow,
   `getaddrinfo`, `socket`, `bind`, `listen`, `accept`, `send`, `recv`, `shutdown`, and `close`.
2. [RFC 9293 — Transmission Control Protocol](https://www.rfc-editor.org/rfc/rfc9293.html) — the
   TCP standard. Focus on the byte-stream model, sequence numbers, acknowledgements, and
   connection lifecycle at a conceptual level.
3. [RFC 9112 — HTTP/1.1](https://www.rfc-editor.org/rfc/rfc9112.html) — the HTTP/1.1 message syntax,
   message parsing, connection management, and security considerations. For Day 1, focus on the
   message format and start-line/header/body framing.
4. macOS local manuals: `man 2 socket`, `man 2 bind`, `man 2 listen`, `man 2 accept`, `man 2 recv`,
   `man 2 send`, `man 2 shutdown`, and `man 2 close`.

## Day 2 — macOS toolchain and build system

1. [Apple — Installing the Command Line Tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools)
   — official setup instructions for `clang`, Git, SDKs, and manual pages.
2. [Homebrew CMake formula](https://formulae.brew.sh/formula/cmake) — supported installation command:
   `brew install cmake`.
3. [CMake Presets manual](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) — purpose
   and format of `CMakePresets.json` and `CMakeUserPresets.json`.
4. [CMake User Interaction Guide](https://cmake.org/cmake/help/latest/guide/user-interaction/)
   — configure/build/test workflows and preset usage.

## Research discipline

- Prefer standards and official documentation for exact behavior.
- Use Beej to build intuition, but verify edge cases in the relevant man page or RFC.
- Record the page/section and a one-sentence takeaway in `docs/learning-log.md`.
- Do not copy a full socket server or thread pool implementation; use references to understand
  behavior and then design/write your own code.
