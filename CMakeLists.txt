cmake_minimum_required(VERSION 2.8)

project(behind_society)

add_definitions(
  -c
  -g
  -Wall
  -std=c++11
  -std=gnu++11
  -static-libgcc
  -static-libstdc++
  -D DEBUG
)

file(GLOB_RECURSE HDRS src/*.h)

file(GLOB_RECURSE SRCS
  src/*.cpp
)

add_executable(behind_society ${HDRS} ${SRCS})

if (WIN32)
  target_link_libraries(behind_society
    mingw32
    -lsfml-system
    -lsfml-window
    -lsfml-graphics
    -lsfml-audio
    -llua53
    -lopengl32
  )
endif (WIN32)

if (UNIX)
  target_link_libraries(behind_society
    -lsfml-system
    -lsfml-window
    -lsfml-graphics
    -lsfml-audio
    -llua5.3
    -lGL
  )
endif (UNIX)
