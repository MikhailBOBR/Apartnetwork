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

    implicitHeight: 300

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
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var left = 26
            var right = width - 18
            var top = 16
            var bottom = height - 28
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

            if (!root.points || root.points.length < 2)
                return

            var xMin = root.minValue("x")
            var xMax = root.maxValue("x")
            var yMin = root.minValue("y")
            var yMax = root.maxValue("y")
            var padding = (yMax - yMin) * 0.12

            if (xMin === xMax)
                xMax += 1
            if (yMin === yMax)
                yMax += 1

            yMin = Math.max(0, yMin - padding)
            yMax += padding

            ctx.beginPath()
            for (var pointIndex = 0; pointIndex < root.points.length; ++pointIndex) {
                var point = root.points[pointIndex]
                var ratioX = (point.x - xMin) / (xMax - xMin)
                var ratioY = (point.y - yMin) / (yMax - yMin)
                var px = left + ratioX * plotWidth
                var py = bottom - ratioY * plotHeight

                if (pointIndex === 0)
                    ctx.moveTo(px, py)
                else
                    ctx.lineTo(px, py)
            }

            ctx.strokeStyle = root.accentColor
            ctx.lineWidth = 2.8
            ctx.stroke()

            ctx.fillStyle = Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12)
            ctx.beginPath()
            for (var fillIndex = 0; fillIndex < root.points.length; ++fillIndex) {
                var fillPoint = root.points[fillIndex]
                var fillRatioX = (fillPoint.x - xMin) / (xMax - xMin)
                var fillRatioY = (fillPoint.y - yMin) / (yMax - yMin)
                var fillX = left + fillRatioX * plotWidth
                var fillY = bottom - fillRatioY * plotHeight

                if (fillIndex === 0) {
                    ctx.moveTo(fillX, bottom)
                    ctx.lineTo(fillX, fillY)
                } else {
                    ctx.lineTo(fillX, fillY)
                }

                if (fillIndex === root.points.length - 1) {
                    ctx.lineTo(fillX, bottom)
                    ctx.closePath()
                    ctx.fill()
                }
            }
        }
    }

    Label {
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 2
        }
        text: "MSE"
        color: root.mutedColor
        font.pixelSize: 13
    }

    Label {
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: 4
        }
        text: "Эпохи"
        color: root.mutedColor
        font.pixelSize: 13
    }
}
