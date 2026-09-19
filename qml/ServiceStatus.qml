/*
 * Copyright (C) 2014 Simon Busch <morphis@gravedo.de>
 * Copyright (C) 2015,2026 Herman van Hazendonk <github.com@herrie.org>
 *
 * GPL-3.0-or-later. Adapted from luna-next-cardshell's Connectors/ServiceStatus.qml;
 * only the bus name registered differs (this app's id instead of the shell's).
 */

import QtQuick 2.0
import LuneOS.Service 1.0
import LunaNext.Common 0.1

Item {
    id: serviceStatus

    property string serviceName: ""

    signal connected
    signal disconnected

    LunaService {
        id: registerServerStatus
        name: "org.webosports.app.torch-status"
        service: "luna://com.palm.bus"
        method: "signal/registerServerStatus"

        onInitialized: registerServerStatus.subscribe(JSON.stringify({"serviceName": serviceStatus.serviceName}))

        onResponse: function (message) {
            var response = JSON.parse(message.payload);
            if (response.connected)
                connected();
            else
                disconnected();
        }
    }
}
