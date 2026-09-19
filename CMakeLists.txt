project(org.webosports.app.torch)
cmake_minimum_required(VERSION 3.5)

include(webOS/webOS)
webos_modules_init(1 0 0 QUALIFIER RC3)
webos_component(1 0 0)

set(APP_DIR ${WEBOS_INSTALL_WEBOS_APPLICATIONSDIR}/org.webosports.app.torch)

# app payload
install(DIRECTORY qml DESTINATION ${APP_DIR})
install(FILES appinfo.json icon.png DESTINATION ${APP_DIR})

# luna-service2: register the app id and grant it torchd's torch.operation
# group, so it can drive torchd exactly as the shell's Flashlight toggle does.
configure_file(sysbus/org.webosports.app.torch.manifest.json.in
               ${CMAKE_BINARY_DIR}/org.webosports.app.torch.manifest.json @ONLY)
install(FILES sysbus/org.webosports.app.torch.app.json
        DESTINATION share/luna-service2/roles.d)
install(FILES ${CMAKE_BINARY_DIR}/org.webosports.app.torch.manifest.json
        DESTINATION share/luna-service2/manifests.d)
install(FILES sysbus/org.webosports.app.torch.perm.json
        DESTINATION share/luna-service2/client-permissions.d)
