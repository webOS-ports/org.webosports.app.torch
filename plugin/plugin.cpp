/*
 * Copyright (C) 2026 Herman van Hazendonk <github.com@herrie.org>
 * GPL-3.0-only.
 */

#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include "torch.h"

class TorchPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override
    {
        Q_ASSERT(uri == QLatin1String("TorchApp"));
        qmlRegisterSingletonType<Torch>(uri, 1, 0, "Torch",
            [](QQmlEngine *, QJSEngine *) -> QObject * { return new Torch; });
    }
};

#include "plugin.moc"
