import QtQuick
import QtTest

import LunaNext.Common 0.1

/*
 * The app - qml/main.qml - on one screen per run (see tools/run-tests.sh):
 * with no torch, with the torch off and with it on, each saved as
 * build/test-output/ui/<profile>-<state>.png to look at. torchd is not on
 * the host's bus, so what it would say is set on the window directly. On a
 * screen with a notch and rounded corners (radon) the shots show the parts
 * of the panel that are not there in red.
 */
TestCase {
    id: test
    name: "Screens"
    when: windowShown

    readonly property string shotDir: decodeURIComponent(Qt.resolvedUrl("../build/test-output/ui").toString()
                                                         .replace(/^file:\/\//, ""))
    readonly property string profile: Settings.profileName
    property var app: null

    function init_data() {
        return [{ tag: Settings.profileName + " " + Settings.displayWidth + "x" + Settings.displayHeight }];
    }

    Component {
        id: panelMask
        // What the panel does not show: the cutouts and the rounded corners.
        Canvas {
            anchors.fill: parent
            z: 100000
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "rgba(255, 0, 0, 0.6)";
                var r = Settings.displayCornerRadii;
                var w = width, h = height;
                if (r.length === 4) {
                    // top left, top right, bottom right, bottom left
                    ctx.beginPath();
                    ctx.moveTo(0, 0); ctx.lineTo(r[0], 0); ctx.arc(r[0], r[0], r[0], -Math.PI / 2, Math.PI, true); ctx.closePath();
                    ctx.moveTo(w, 0); ctx.lineTo(w, r[1]); ctx.arc(w - r[1], r[1], r[1], 0, -Math.PI / 2, true); ctx.closePath();
                    ctx.moveTo(w, h); ctx.lineTo(w - r[2], h); ctx.arc(w - r[2], h - r[2], r[2], Math.PI / 2, 0, true); ctx.closePath();
                    ctx.moveTo(0, h); ctx.lineTo(0, h - r[3]); ctx.arc(r[3], h - r[3], r[3], Math.PI, Math.PI / 2, true); ctx.closePath();
                    ctx.fill();
                }
                var cuts = Settings.displayCutouts;
                for (var i = 0; i < cuts.length; i++)
                    ctx.fillRect(cuts[i].x, cuts[i].y, cuts[i].width, cuts[i].height);
            }
        }
    }

    function shot(name) {
        wait(300);
        var mask = null;
        if (Settings.displayCutouts.length > 0 || Settings.displayCornerRadii.length > 0) {
            mask = panelMask.createObject(app.contentItem);
            mask.requestPaint();
            wait(100);
        }
        var done = false;
        var ok = app.contentItem.grabToImage(function(result) {
            result.saveToFile(shotDir + "/" + profile + "-" + name + ".png");
            done = true;
        });
        verify(ok, "grab " + name);
        tryVerify(function() { return done; }, 5000, "saved " + name);
        if (mask)
            mask.destroy();
    }

    function find(objectName) {
        function look(item) {
            if (!item)
                return null;
            if (item.objectName === objectName)
                return item;
            var kids = item.children || [];
            for (var i = 0; i < kids.length; i++) {
                var found = look(kids[i]);
                if (found)
                    return found;
            }
            return null;
        }
        var it = look(app.contentItem);
        verify(it !== null, "found " + objectName);
        return it;
    }

    // Of some size, and wholly inside the window.
    function onScreen(item, what) {
        verify(item.width > 0 && item.height > 0, what + " has a size: " + item.width + "x" + item.height);
        var box = item.mapToItem(app.contentItem, 0, 0, item.width, item.height);
        verify(box.x >= -0.5 && box.y >= -0.5
               && box.x + box.width <= app.width + 0.5 && box.y + box.height <= app.height + 0.5,
               what + " inside the " + app.width + "x" + app.height + " window: "
               + box.x + "," + box.y + " " + box.width + "x" + box.height);
        return box;
    }

    function init() {
        var component = Qt.createComponent(Qt.resolvedUrl("../qml/main.qml"));
        if (component.status === Component.Error)
            fail(component.errorString());
        app = component.createObject(null, { width: Settings.displayWidth, height: Settings.displayHeight });
        verify(app !== null, "main.qml made");
        app.requestActivate();
        waitForRendering(app.contentItem);
    }

    function cleanup() {
        if (app) {
            // Not lit, so closing does not ask torchd for anything.
            app.torchOn = false;
            app.destroy();
            app = null;
        }
        wait(50);
    }

    // The torch and the line under it, both on the screen and apart.
    function check(caption) {
        var torch = find("torchOff");
        verify(torch.visible, "torch shown");
        verify(torch.status === Image.Ready, "torch picture loaded");
        verify(torch.width > 0 && torch.height > 0, "torch has a size");
        // The picture has room around the torch (the beam above it), which
        // may run past the window on a short or a narrow one; the torch
        // itself is the middle of it, standing above the bottom edge.
        var torchBox = torch.mapToItem(app.contentItem, 0, 0, torch.width, torch.height);
        verify(torchBox.height <= app.height, "the torch is no taller than the window");
        verify(torchBox.y + torchBox.height <= app.height, "the torch stands inside the window");
        verify(torchBox.y + torchBox.height / 2 > 0, "the torch's middle is on the screen");
        verify(Math.abs(torchBox.x + torchBox.width / 2 - app.width / 2) < 1, "the torch in the middle");
        var text = find("caption");
        compare(text.text, caption);
        var textBox = onScreen(text, "caption");
        verify(text.contentWidth <= app.width, "caption fits across");
        verify(torchBox.y + torchBox.height <= textBox.y + 0.5, "the caption is below the torch, not on it");
        verify(torchBox.height >= app.height / 2, "the torch fills most of the height");
    }

    function test_unavailable() {
        app.available = false;
        shot("unavailable");
        check("Torch unavailable");
    }

    function test_off() {
        app.available = true;
        app.torchOn = false;
        shot("off");
        check("Tap to turn on");
    }

    function test_on() {
        app.available = true;
        app.torchOn = true;
        var lit = find("torchOn");
        tryVerify(function() { return lit.opacity === 1; }, 2000, "the lit torch shown");
        compare(lit.width, find("torchOff").width);
        shot("on");
        check("Tap to turn off");
    }
}
