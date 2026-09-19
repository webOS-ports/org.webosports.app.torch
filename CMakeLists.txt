project(org.webosports.app.torch)
cmake_minimum_required(VERSION 3.5)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)

include(webOS/webOS)
webos_modules_init(1 0 0 QUALIFIER RC3)
webos_component(1 0 0)

set(APP_DIR ${WEBOS_INSTALL_WEBOS_APPLICATIONSDIR}/org.webosports.app.torch)

# QML plugin providing the Torch singleton
add_library(torch-qml MODULE plugin/plugin.cpp plugin/torch.cpp)
set_target_properties(torch-qml PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_link_libraries(torch-qml Qt6::Core Qt6::Qml)

install(TARGETS torch-qml DESTINATION ${APP_DIR}/plugins/TorchApp)
install(FILES plugin/qmldir DESTINATION ${APP_DIR}/plugins/TorchApp)
install(DIRECTORY qml DESTINATION ${APP_DIR})
install(FILES appinfo.json icon.png DESTINATION ${APP_DIR})
