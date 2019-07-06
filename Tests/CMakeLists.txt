
add_executable(CassowaryTests
  Tests.swift)
target_link_libraries(CassowaryTests PRIVATE
  cassowary)

if(CMAKE_TESTING_ENABLED)
  add_test(NAME CassowaryTests
    COMMAND $<TARGET_FILE:CassowaryTests>
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
endif()

