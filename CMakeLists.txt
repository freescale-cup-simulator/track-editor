cmake_minimum_required(VERSION 2.8.11 FATAL_ERROR)

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
add_definitions(${Qt5Quick_DEFINITIONS})
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Quick_EXECUTABLE_COMPILE_FLAGS}")

if(CMAKE_COMPILER_IS_GNUCXX)
  set(CMAKE_CXX_FLAGS_DEBUG
      "${CMAKE_CXX_FLAGS} -std=c++11 -O2 -ggdb3 -Wall -Wextra -pedantic")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -std=c++11 -O2")
endif()

add_subdirectory(libtrack EXCLUDE_FROM_ALL)

include_directories(${Qt5Quick_INCLUDE_DIRS}
                    libtrack
)

set(QML_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/")

qt5_wrap_cpp(moc_cpp ${moc_headers})
qt5_add_resources(resources ${reslists})

message(STATUS "Build type is: ${CMAKE_BUILD_TYPE}")

add_executable(track-editor ${sources} ${moc_cpp} ${reslists} ${resources})
qt5_use_modules(track-editor Quick)
target_link_libraries(track-editor track)