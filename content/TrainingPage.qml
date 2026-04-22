import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property color surfaceColor: "#FFF9F1"
    property color borderColor: "#E4D8C8"
    property color textColor: "#21313A"
    property color mutedColor: "#6B7280"
    property color accentColor: "#1B6B65"
    property color accentWarm: "#D97D54"

    property bool trainingBusy: false

    function appendLog(message, color) {
        trainingLog.append("<span style='color:" + color + "'>" + message + "</span>")
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        Column {
            width: root.width - 6
            spacing: 18

            Rectangle {
                width: parent.width
                radius: 26
                color: root.surfaceColor
                border.color: root.borderColor
                implicitHeight: 118

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 8

                    Label {
                        text: "Обучение, контроль ошибки и рыночные коэффициенты"
                        color: root.textColor
                        font.pixelSize: 26
                        font.bold: true
                    }

                    Label {
                        text: "Здесь можно переобучить модель на встроенной базе, посмотреть динамику MSE и понять, как разные округа влияют на стоимость внутри выборки."
                        color: root.mutedColor
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            Flow {
                width: parent.width
                spacing: 14

                Repeater {
                    model: predictionViewModel.marketHighlights

                    delegate: InsightCard {
                        width: root.width < 1120 ? parent.width : (root.width - 42) / 4
                        title: modelData.title
                        value: modelData.value
                        caption: modelData.caption
                        surfaceColor: root.surfaceColor
                        borderColor: root.borderColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        accentColor: index % 2 === 0 ? root.accentColor : root.accentWarm
                    }
                }
            }

            Flow {
                width: parent.width
                spacing: 18

                Rectangle {
                    width: root.width < 1120 ? parent.width : parent.width * 0.42 - 9
                    radius: 28
                    color: root.surfaceColor
                    border.color: root.borderColor
                    implicitHeight: 290

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 14

                        Label {
                            text: "Параметры обучения"
                            color: root.textColor
                            font.pixelSize: 22
                            font.bold: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Эпохи"; color: root.mutedColor }
                                SpinBox {
                                    id: epochsBox
                                    Layout.fillWidth: true
                                    from: 100
                                    to: 5000
                                    stepSize: 100
                                    value: 1800
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Learning rate"; color: root.mutedColor }
                                TextField {
                                    id: learningRateField
                                    Layout.fillWidth: true
                                    text: "0.0035"
                                    validator: DoubleValidator { bottom: 0.0001; top: 0.05; decimals: 4 }
                                }
                            }
                        }

                        RowLayout {
                            spacing: 12

                            Button {
                                id: trainButton
                                text: root.trainingBusy ? "Идёт обучение..." : "Переобучить модель"
                                enabled: !root.trainingBusy
                                onClicked: predictionViewModel.trainModel(epochsBox.value, parseFloat(learningRateField.text))

                                background: Rectangle {
                                    radius: 18
                                    color: root.accentColor
                                    opacity: parent.enabled ? 1.0 : 0.6
                                }

                                contentItem: Label {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.bold: true
                                }
                            }

                            BusyIndicator {
                                running: root.trainingBusy
                                visible: running
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.borderColor
                        }

                        Label {
                            text: predictionViewModel.bestMse > 0
                                  ? "Лучший MSE: " + predictionViewModel.bestMse.toFixed(6)
                                  : "Лучший MSE: пока нет данных"
                            color: root.textColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            text: "После обучения веса автоматически сохраняются в пользовательское хранилище приложения."
                            color: root.mutedColor
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }
                }

                Rectangle {
                    width: root.width < 1120 ? parent.width : parent.width * 0.58 - 9
                    radius: 28
                    color: root.surfaceColor
                    border.color: root.borderColor
                    implicitHeight: 290

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Label {
                            text: "Окружные коэффициенты в выборке"
                            color: root.textColor
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Label {
                            text: "Это инженерные индексы, на которых калибрована выборка. Они помогают модели чувствовать разницу между более дорогими и более доступными округами."
                            color: root.mutedColor
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        Repeater {
                            model: predictionViewModel.districtIndices

                            delegate: RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Label {
                                    text: modelData.label
                                    color: root.textColor
                                    font.pixelSize: 14
                                    Layout.preferredWidth: 110
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 14
                                    radius: 7
                                    color: "#F2E8DB"

                                    Rectangle {
                                        width: parent.width * (modelData.value / 650000)
                                        height: parent.height
                                        radius: parent.radius
                                        color: index < 2 ? root.accentWarm : root.accentColor
                                    }
                                }

                                Label {
                                    text: Math.round(modelData.value / 1000) + " тыс."
                                    color: root.mutedColor
                                    font.pixelSize: 13
                                    Layout.preferredWidth: 64
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                radius: 28
                color: root.surfaceColor
                border.color: root.borderColor
                implicitHeight: 410

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    Label {
                        text: "Кривая ошибки обучения"
                        color: root.textColor
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Label {
                        text: predictionViewModel.trainingCurve.length > 1
                              ? "График обновляется по мере обучения. Чем ниже MSE, тем точнее аппроксимация встроенной выборки."
                              : "После запуска обучения здесь появится линия изменения MSE."
                        color: root.mutedColor
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    LineChart {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        points: predictionViewModel.trainingCurve
                        gridColor: "#EEE4D6"
                        axisColor: root.borderColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        accentColor: root.accentColor
                    }
                }
            }

            Rectangle {
                width: parent.width
                radius: 28
                color: root.surfaceColor
                border.color: root.borderColor
                implicitHeight: 250

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Label {
                        text: "Журнал обучения"
                        color: root.textColor
                        font.pixelSize: 22
                        font.bold: true
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TextArea {
                            id: trainingLog
                            readOnly: true
                            textFormat: TextEdit.RichText
                            wrapMode: TextEdit.Wrap
                            font.family: "Consolas"
                            color: root.textColor
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: predictionViewModel

        function onTrainingStarted() {
            root.trainingBusy = true
            trainingLog.clear()
            root.appendLog("Обучение запущено.", root.accentColor)
        }

        function onTrainingProgress(epoch, mse) {
            root.appendLog("Эпоха " + epoch + " • MSE = " + mse.toFixed(6), root.textColor)
        }

        function onTrainingFinished() {
            root.trainingBusy = false
            root.appendLog("Обучение завершено. Веса сохранены.", root.accentWarm)
        }
    }
}
