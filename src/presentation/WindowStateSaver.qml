import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtCore

Item
{
    property Window window
    property string windowName: ""

    Settings
    {
        id: s
        category: windowName
        property int x
        property int y
        property int width
        property int height
        property int visibility
    }

    Component.onCompleted:
    {
        if (s.width && s.height)
        {
            restoreWindow(s)
        }
    }

    Connections
    {
        target: window

        function onXChanged() {saveSettingsTimer.restart()}
        function onYChanged() {saveSettingsTimer.restart()}
        function onWidthChanged() {saveSettingsTimer.restart()}
        function onHeightChanged() {saveSettingsTimer.restart()}
        function onVisibilityChanged() {saveSettingsTimer.restart()}
    }

    Timer
    {
        id: saveSettingsTimer
        interval: 1000
        repeat: false
        onTriggered: saveSettings()
    }

    function saveSettings()
    {
        switch(window.visibility)
        {
        case ApplicationWindow.Windowed:
            s.x = window.x;
            s.y = window.y;
            s.width = window.width;
            s.height = window.height;
            s.visibility = window.visibility;
            break;
        case ApplicationWindow.FullScreen:
            s.visibility = window.visibility;
            break;
        case ApplicationWindow.Maximized:
            s.visibility = window.Maximized;
            break;
        }
    }

    function restoreWindow(s) {
        window.x = s.x;
        window.y = s.y;
        window.width = s.width;
        window.height = s.height;
        window.visibility = s.visibility;
    }
}
