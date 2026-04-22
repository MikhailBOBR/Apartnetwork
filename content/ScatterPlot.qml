import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    property var points: []
    property color gridColor: "#EEE4D6"
    property color axisColor: "#D4C6B2"
    property color textColor: "#21313A"
    property color mutedColor: "#6B7280"
    property color accentColor: "#1B6B65"
    property color accentWarm: "#D97D54"

    implicitHeight: 320

    function minValue(key) {
        if (!points || points.length === 0)
            return 0

        var value = points[0][key]
        for (var index = 1; index < points.length; ++index)
            value = Math.min(value, points[index][key])
        return value
    }

    function maxValue(key) {
        if (!points || points.length === 0)
            return 1

        var value = points[0][key]
        for (var index = 1; index < points.length; ++index)
            value = Math.max(value, points[index][key])
        return value
    }

    onPointsChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: legendRow.top
            bottomMargin: 14
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var left = 22
            var right = width - 18
            var top = 16
            var bottom = height - 22
            var plotWidth = Math.max(1, right - left)
            var plotHeight = Math.max(1, bottom - top)

            ctx.strokeStyle = root.gridColor
            ctx.lineWidth = 1

            for (var line = 0; line <= 4; ++line) {
                var y = top + (plotHeight / 4) * line
                ctx.beginPath()
                ctx.moveTo(left, y)
                ctx.lineTo(right, y)
                ctx.stroke()
            }

            ctx.strokeStyle = root.axisColor
            ctx.lineWidth = 1.2
            ctx.beginPath()
            ctx.moveTo(left, top)
            ctx.lineTo(left, bottom)
            ctx.lineTo(right, bottom)
            ctx.stroke()

            if (!root.points || root.points.length === 0)
                return

            var xMin = root.minValue("x")
            var xMax = root.maxValue("x")
            var yMin = root.minValue("y")
            var yMax = root.maxValue("y")

            if (xMin === xMax)
                xMax += 1
            if (yMin === yMax)
                yMax += 1

            for (var pointIndex = 0; pointIndex < root.points.length; ++pointIndex) {
                var point = root.points[pointIndex]
                var ratioX = (point.x - xMin) / (xMax - xMin)
                var ratioY = (point.y - yMin) / (yMax - yMin)
                var px = left + ratioX * plotWidth
                var py = bottom - ratioY * plotHeight

                ctx.fillStyle = point.accent ? root.accentWarm : root.accentColor
                ctx.globalAlpha = point.accent ? 0.70 : 0.46
                ctx.beginPath()
                ctx.arc(px, py, point.accent ? 4.6 : 3.6, 0, Math.PI * 2)
                ctx.fill()
            }

            ctx.globalAlpha = 1.0
        }
    }

    Label {
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 2
        }
        text: "Цена, млн ₽"
        color: root.mutedColor
        font.pixelSize: 13
    }

    Label {
        anchors {
            bottom: legendRow.top
            right: parent.right
            rightMargin: 4
            bottomMargin: 12
        }
        text: "Площадь, м²"
        color: root.mutedColor
        font.pixelSize: 13
    }

    Row {
        id: legendRow
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        spacing: 18

        Row {
            spacing: 8
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: root.accentColor
            }
            Label {
                text: "вторичный / готовый фонд"
                color: root.textColor
                font.pixelSize: 13
            }
        }

        Row {
            spacing: 8
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: root.accentWarm
            }
            Label {
                text: "новый дом / недавняя постройка"
                color: root.textColor
                font.pixelSize: 13
            }
        }
    }
}
