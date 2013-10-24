cmake_minimum_required(VERSION 2.8.7 FATAL_ERROR)

project(track-editor CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(sources

    track_editor.cc
    grid_operator.cc
    grid_operator.h

    qml/TrackEditor.qml
    qml/Tile.qml
)

set(moc_headers

   grid_operator.h
)

set(reslists
    reslist.qrc
)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING
  "Choose the type of build: Debug/Release" FORCE)
endif()

find_package(Qt5Quick REQUIRED)
include_directories(${Qt5Quick_INCLUDE_DIRS})
add_definitions(${Qt5Quick_DEFINITIONS})
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Quick_EXECUTABLE_COMPILE_FLAGS}")


find_package(Qt5Widgets REQUIRED)
include_directories(${Qt5Widgets_INCLUDE_DIRS})
add_definitions(${Qt5Widgets_DEFINITIONS})
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Widgets_EXECUTABLE_COMPILE_FLAGS}")

include(CheckCXXCompilerFlag)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
  CHECK_CXX_COMPILER_FLAG("-std=c++11" STDCPP11_SUPPORTED)
  if(STDCPP11_SUPPORTED)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
  else()
    CHECK_CXX_COMPILER_FLAG("-std=c++0x" STDCPP0X_SUPPORTED)
    if(STDCPP0X_SUPPORTED)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
    else()
      message(FATAL_ERROR "Compiler doesn't appear to support C++11 or at least C++0x")
    endif()
  endif()
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} -O0 -ggdb3 -Wall -Wextra -pedantic")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O2")
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  message(STATUS "Warning: building on Windows is experimental")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} /Od")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} /O2")
endif()

add_subdirectory(libtrack EXCLUDE_FROM_ALL)
include_directories(libtrack
                    ${CMAKE_BINARY_DIR}/libtrack
)

set(QML_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/")

qt5_wrap_cpp(moc_cpp ${moc_headers})
qt5_add_resources(resources ${reslists})

message(STATUS "Build type is: ${CMAKE_BUILD_TYPE}")

if(MSVC)
  add_executable(track-editor WIN32 ${sources} ${moc_cpp} ${reslists} ${resources})
  set_target_properties(track-editor PROPERTIES LINK_FLAGS_RELEASE "/SUBSYSTEM:WINDOWS")
  set_target_properties(track-editor PROPERTIES LINK_FLAGS_DEBUG "/SUBSYSTEM:CONSOLE")
  target_link_libraries(track-editor track ${Qt5Quick_LIBRARIES} ${Qt5Widgets_LIBRARIES})
else()
  add_executable(track-editor ${sources} ${moc_cpp} ${reslists} ${resources})
  target_link_libraries(track-editor track ${Qt5Quick_LIBRARIES} ${Qt5Widgets_LIBRARIES})
endif()
