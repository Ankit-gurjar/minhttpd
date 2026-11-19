# Architecture decision log

Record decisions that affect interfaces or behavior. Include the reason and trade-offs. Revisit
a decision when new evidence shows it is wrong.

## ADR-000 — Initial project constraints

- **Status:** Accepted as the learning baseline
- **Date:** 2026-11-19
- **Decision:** Use C++20, POSIX sockets, standard-library threads/synchronization, CMake, and a
  small HTTP/1.1 feature set.
- **Reason:** Keep the project focused on understanding OS/networking/concurrency fundamentals
  instead of delegating them to an application framework.
- **Consequences:** The project must explicitly handle descriptor ownership, partial I/O,
  request framing, bounded resources, synchronization, and shutdown.
- **Not included in the baseline:** TLS, HTTP/2, async I/O/kqueue, databases, and third-party
  HTTP frameworks.

## Future decision template

### ADR-XXX — Title

- **Status:** Proposed / Accepted / Superseded
- **Date:** YYYY-MM-DD
- **Context:** What problem are we solving?
- **Decision:** What did we choose?
- **Alternatives:** What else did we consider?
- **Trade-offs:** What becomes easier or harder?
