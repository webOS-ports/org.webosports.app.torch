/*
 * Copyright (C) 2026 Herman van Hazendonk <github.com@herrie.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; see the GNU General Public License for more details.
 */

#include "torch.h"

#include <QDir>
#include <QFile>

Torch::Torch(QObject *parent)
    : QObject(parent)
{
    const QDir leds("/sys/class/leds");
    const QStringList names = leds.entryList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
    // Prefer a "torch" node over a "flash" one, as nyxLedTorch does.
    for (const QString &want : { QStringLiteral(":torch"), QStringLiteral(":flash") }) {
        for (const QString &name : names) {
            if (!name.endsWith(want))
                continue;
            QFile max(leds.filePath(name) + "/max_brightness");
            if (!max.open(QIODevice::ReadOnly))
                continue;
            m_maxBrightness = QString::fromLatin1(max.readAll()).trimmed();
            m_brightnessPath = leds.filePath(name) + "/brightness";
            return;
        }
    }
}

Torch::~Torch()
{
    setOn(false);
}

bool Torch::available() const
{
    return !m_brightnessPath.isEmpty();
}

bool Torch::on() const
{
    return m_on;
}

void Torch::setOn(bool on)
{
    if (!available() || on == m_on)
        return;

    QFile brightness(m_brightnessPath);
    if (!brightness.open(QIODevice::WriteOnly))
        return;
    brightness.write(on ? m_maxBrightness.toLatin1() : QByteArray("0"));
    brightness.close();

    m_on = on;
    Q_EMIT onChanged();
}
