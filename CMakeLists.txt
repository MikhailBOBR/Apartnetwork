cmake_minimum_required(VERSION 3.21.1)

option(LINK_INSIGHT "Link Qt Insight Tracker library" ON)
option(BUILD_QDS_COMPONENTS "Build design studio components" OFF)

project(ApartnetworkApp LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Core Gui Qml Quick Concurrent)

if (Qt6_VERSION VERSION_GREATER_EQUAL 6.3)
    qt_standard_project_setup()
endif()

set(APARTNETWORK_MODEL_SOURCES
    src/apartmentmodeladapter.h
    src/apartmentmodeladapter.cpp
    src/model/ActivationFunctions.h
    src/model/ActivationFunctions.cpp
    src/model/ApartmentModel.h
    src/model/ApartmentModel.cpp
    src/model/DataParser.h
    src/model/DataParser.cpp
    src/model/Layer.h
    src/model/Layer.cpp
    src/model/Matrix.h
    src/model/Matrix.cpp
)

qt_add_executable(ApartnetworkApp
    resources.qrc
    src/main.cpp
    src/predictionviewmodel.h
    src/predictionviewmodel.cpp
    ${APARTNETWORK_MODEL_SOURCES}
)

qt_add_resources(ApartnetworkApp "configuration"
    PREFIX "/"
    FILES
        qtquickcontrols2.conf
)

target_link_libraries(ApartnetworkApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Concurrent
)

set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
set(QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY}
    CACHE STRING "Import paths for Qt Creator's code model"
    FORCE
)

if (BUILD_QDS_COMPONENTS)
    include(${CMAKE_CURRENT_SOURCE_DIR}/qmlcomponents)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/qmlmodules)

if (LINK_INSIGHT)
    include(${CMAKE_CURRENT_SOURCE_DIR}/insight)
endif ()

include(CTest)
if (BUILD_TESTING)
    find_package(Qt6 6.2 REQUIRED COMPONENTS Test)

    qt_add_executable(ApartnetworkTests
        tests/apartnetwork_tests.cpp
        tests/test_resources.qrc
        ${APARTNETWORK_MODEL_SOURCES}
    )

    target_link_libraries(ApartnetworkTests PRIVATE
        Qt6::Core
        Qt6::Concurrent
        Qt6::Test
    )

    add_test(NAME ApartnetworkTests COMMAND ApartnetworkTests)
endif()

include(GNUInstallDirs)
install(TARGETS ApartnetworkApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

set(QML_IMPORT_PATH ${PROJECT_BINARY_DIR}/qml CACHE PATH
    "Path to the custom QML components defined by the project")
