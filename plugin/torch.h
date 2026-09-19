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

#ifndef TORCH_H
#define TORCH_H

#include <QObject>
#include <QString>

/*
 * The camera flash LED as a plain kernel LED. LuneOS already exposes it on the
 * luna-service bus through torchd for the shell's quick toggle; this standalone
 * app instead drives the /sys/class/leds node directly (apps run as root), so it
 * needs no service permissions of its own. The node is found the same way nyx
 * and torchd find it: the LED whose name marks it a torch (preferred) or flash.
 */
class Torch : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(bool on READ on WRITE setOn NOTIFY onChanged)

public:
    explicit Torch(QObject *parent = nullptr);
    ~Torch();

    bool available() const;
    bool on() const;
    void setOn(bool on);
    Q_INVOKABLE void toggle() { setOn(!m_on); }

Q_SIGNALS:
    void onChanged();

private:
    QString m_brightnessPath;
    QString m_maxBrightness;
    bool m_on = false;
};

#endif
