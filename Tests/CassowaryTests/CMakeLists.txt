
add_executable(CassowaryTests
  CassowaryTests.swift)
target_link_libraries(CassowaryTests PRIVATE
  cassowary)
target_link_libraries(CassowaryTests PUBLIC
  XCTest)

if(CMAKE_TESTING_ENABLED)
  add_test(NAME CassowaryTests
    COMMAND $<TARGET_FILE:CassowaryTests>
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
endif()

