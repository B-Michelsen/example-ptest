cmake_minimum_required(VERSION 3.10)
project(example-ptest LANGUAGES CXX VERSION 1.0.0)

add_executable(main main.cpp)

include(GNUInstallDirs)

set_target_properties(main PROPERTIES OUTPUT_NAME "my-application")
install(TARGETS main RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
