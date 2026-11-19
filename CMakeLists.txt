cmake_minimum_required(VERSION 3.21)

project(minhttpd
    VERSION 0.1.0
    DESCRIPTION "A small HTTP/1.1 server built from scratch with C++20 and POSIX sockets"
    LANGUAGES CXX
)

option(MINHTTPD_ENABLE_WARNINGS "Enable useful compiler warnings" ON)
option(MINHTTPD_ENABLE_SANITIZERS "Enable AddressSanitizer and UndefinedBehaviorSanitizer" OFF)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Threads REQUIRED)

add_executable(minhttpd
    src/main.cpp
    src/server.cpp
    src/socket.cpp
    src/http_request.cpp
    src/http_response.cpp
    src/http_parser.cpp
    src/router.cpp
    src/thread_pool.cpp
    src/logger.cpp
    src/config.cpp
)

target_include_directories(minhttpd
    PRIVATE
        ${PROJECT_SOURCE_DIR}/include
)

target_link_libraries(minhttpd
    PRIVATE
        Threads::Threads
)

target_compile_definitions(minhttpd
    PRIVATE
        MINHTTPD_VERSION="${PROJECT_VERSION}"
)

if(MINHTTPD_ENABLE_WARNINGS)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        target_compile_options(minhttpd PRIVATE
            -Wall
            -Wextra
            -Wpedantic
            -Wshadow
        )
    endif()
endif()

if(MINHTTPD_ENABLE_SANITIZERS)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        target_compile_options(minhttpd PRIVATE -fsanitize=address,undefined -fno-omit-frame-pointer)
        target_link_options(minhttpd PRIVATE -fsanitize=address,undefined)
    else()
        message(FATAL_ERROR "Sanitizers are configured only for Clang and GCC in this starter project.")
    endif()
endif()

include(CTest)

if(BUILD_TESTING)
    # This only verifies that the Day 2 starter executable launches.
    # Real unit and integration tests will be added later in the roadmap.
    add_test(NAME scaffold_smoke COMMAND minhttpd)
endif()
