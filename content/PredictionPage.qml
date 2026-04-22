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

    property bool predictionBusy: false
    readonly property bool compactLayout: width < 1120

    function setComboByText(comboBox, value) {
        for (var index = 0; index < comboBox.model.length; ++index) {
            if (comboBox.model[index] === value) {
                comboBox.currentIndex = index
                return
            }
        }
    }

    function applyPreset(preset) {
        areaField.text = Number(preset.area).toFixed(1)
        roomsField.text = String(preset.rooms)
        floorField.text = String(preset.floor)
        floorsTotalField.text = String(preset.floorsTotal)
        metroField.text = String(preset.metroMinutes)
        yearField.text = String(preset.builtYear)
        setComboByText(districtBox, preset.district)
        setComboByText(conditionBox, preset.condition)
        setComboByText(buildingTypeBox, preset.buildingType)
        parkingBox.checked = preset.parking
        balconyBox.checked = preset.balcony
        newBuildBox.checked = preset.newBuild
    }

    Component.onCompleted: {
        if (predictionViewModel.presets.length > 0)
            applyPreset(predictionViewModel.presets[0])
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
                implicitHeight: 108

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 8

                    Label {
                        text: "Форма квартиры и быстрые сценарии"
                        color: root.textColor
                        font.pixelSize: 26
                        font.bold: true
                    }

                    Label {
                        text: predictionViewModel.datasetDescription
                        color: root.mutedColor
                        font.pixelSize: 14
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            Flow {
                width: parent.width
                spacing: 12

                Repeater {
                    model: predictionViewModel.presets

                    delegate: Button {
                        text: modelData.title
                        onClicked: root.applyPreset(modelData)

                        background: Rectangle {
                            radius: 18
                            color: hovered ? "#EAF5F1" : root.surfaceColor
                            border.color: hovered ? root.accentColor : root.borderColor
                        }

                        contentItem: Label {
                            text: parent.text
                            color: root.textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                }
            }

            Flow {
                width: parent.width
                spacing: 18

                Rectangle {
                    width: root.compactLayout ? parent.width : parent.width * 0.55 - 9
                    radius: 28
                    color: root.surfaceColor
                    border.color: root.borderColor
                    implicitHeight: 520

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 18

                        Label {
                            text: "Параметры квартиры"
                            color: root.textColor
                            font.pixelSize: 22
                            font.bold: true
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: root.compactLayout ? 1 : 2
                            rowSpacing: 12
                            columnSpacing: 14

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Площадь, м²"; color: root.mutedColor }
                                TextField {
                                    id: areaField
                                    Layout.fillWidth: true
                                    placeholderText: "например, 54.5"
                                    validator: DoubleValidator { bottom: 10; top: 500; decimals: 1 }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Комнат"; color: root.mutedColor }
                                TextField {
                                    id: roomsField
                                    Layout.fillWidth: true
                                    placeholderText: "1-5"
                                    validator: IntValidator { bottom: 1; top: 6 }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Этаж"; color: root.mutedColor }
                                TextField {
                                    id: floorField
                                    Layout.fillWidth: true
                                    placeholderText: "например, 8"
                                    validator: IntValidator { bottom: 1; top: 100 }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Этажей в доме"; color: root.mutedColor }
                                TextField {
                                    id: floorsTotalField
                                    Layout.fillWidth: true
                                    placeholderText: "например, 17"
                                    validator: IntValidator { bottom: 1; top: 120 }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Минут до метро"; color: root.mutedColor }
                                TextField {
                                    id: metroField
                                    Layout.fillWidth: true
                                    placeholderText: "например, 10"
                                    validator: IntValidator { bottom: 0; top: 60 }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Год постройки"; color: root.mutedColor }
                                TextField {
                                    id: yearField
                                    Layout.fillWidth: true
                                    placeholderText: "1960-2023"
                                    validator: IntValidator { bottom: 1950; top: 2023 }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Округ"; color: root.mutedColor }
                                ComboBox {
                                    id: districtBox
                                    Layout.fillWidth: true
                                    model: ["ЦАО", "ЗАО", "СЗАО", "ЮЗАО", "САО", "СВАО", "ЮАО", "ВАО", "ЮВАО", "Новая Москва"]
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Состояние"; color: root.mutedColor }
                                ComboBox {
                                    id: conditionBox
                                    Layout.fillWidth: true
                                    model: ["Требует ремонта", "Косметический ремонт", "Евро / дизайнерский"]
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Label { text: "Тип дома"; color: root.mutedColor }
                                ComboBox {
                                    id: buildingTypeBox
                                    Layout.fillWidth: true
                                    model: ["Панель", "Кирпич", "Монолит"]
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                Label { text: "Дополнительно"; color: root.mutedColor }

                                RowLayout {
                                    spacing: 14
                                    CheckBox { id: parkingBox; text: "Паркинг" }
                                    CheckBox { id: balconyBox; text: "Балкон" }
                                    CheckBox { id: newBuildBox; text: "Новый дом" }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Button {
                                id: predictButton
                                text: root.predictionBusy ? "Считаем..." : "Рассчитать стоимость"
                                enabled: !root.predictionBusy

                                onClicked: {
                                    predictionViewModel.predictPrice(
                                                parseFloat(areaField.text),
                                                parseInt(roomsField.text),
                                                parseInt(floorField.text),
                                                parseInt(floorsTotalField.text),
                                                parseInt(metroField.text),
                                                parseInt(yearField.text),
                                                districtBox.currentText,
                                                conditionBox.currentText,
                                                buildingTypeBox.currentText,
                                                parkingBox.checked,
                                                balconyBox.checked,
                                                newBuildBox.checked)
                                }

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

                            Button {
                                text: "Очистить"
                                onClicked: {
                                    areaField.clear()
                                    roomsField.clear()
                                    floorField.clear()
                                    floorsTotalField.clear()
                                    metroField.clear()
                                    yearField.clear()
                                    districtBox.currentIndex = 0
                                    conditionBox.currentIndex = 1
                                    buildingTypeBox.currentIndex = 0
                                    parkingBox.checked = false
                                    balconyBox.checked = false
                                    newBuildBox.checked = false
                                }

                                background: Rectangle {
                                    radius: 18
                                    color: root.surfaceColor
                                    border.color: root.borderColor
                                }

                                contentItem: Label {
                                    text: parent.text
                                    color: root.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.bold: true
                                }
                            }

                            BusyIndicator {
                                running: root.predictionBusy
                                visible: running
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle {
                    width: root.compactLayout ? parent.width : parent.width * 0.45 - 9
                    radius: 28
                    color: root.surfaceColor
                    border.color: root.borderColor
                    implicitHeight: 520

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 22
                        spacing: 14

                        Label {
                            text: predictionViewModel.lastPrediction.headline
                            color: root.textColor
                            wrapMode: Text.Wrap
                            font.pixelSize: 21
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 150
                            radius: 22
                            color: predictionViewModel.lastPrediction.isError ? "#F9E6DB" : "#EAF5F1"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 8

                                Label {
                                    text: predictionViewModel.lastPrediction.totalPriceText
                                    color: predictionViewModel.lastPrediction.isError ? root.accentWarm : root.accentColor
                                    font.pixelSize: 30
                                    font.bold: true
                                    wrapMode: Text.Wrap
                                }

                                Label {
                                    text: predictionViewModel.lastPrediction.totalPriceFullText
                                    color: root.textColor
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Label {
                            text: predictionViewModel.lastPrediction.pricePerSquareMeterText
                            color: root.textColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            text: predictionViewModel.lastPrediction.segmentText
                            color: root.accentWarm
                            wrapMode: Text.Wrap
                            font.pixelSize: 15
                            Layout.fillWidth: true
                        }

                        Label {
                            text: predictionViewModel.lastPrediction.summary
                            color: root.mutedColor
                            wrapMode: Text.Wrap
                            font.pixelSize: 14
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.borderColor
                        }

                        Label {
                            text: "Ориентиры выборки"
                            color: root.textColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            text: "Выборка охватывает доступный, средний и повышенный ценовой сегменты Москвы 2023 года. Новые дома и дорогие округа отдельно усилены в данных."
                            color: root.mutedColor
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            Flow {
                width: parent.width
                spacing: 14

                Repeater {
                    model: predictionViewModel.marketHighlights

                    delegate: InsightCard {
                        width: root.compactLayout ? parent.width : (root.width - 42) / 4
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

            Rectangle {
                width: parent.width
                radius: 28
                color: root.surfaceColor
                border.color: root.borderColor
                implicitHeight: 430

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 14

                    Label {
                        text: "Визуализация выборки: площадь и цена"
                        color: root.textColor
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Label {
                        text: "Точки справа и выше обычно соответствуют более просторным и дорогим квартирам. Тёплый цвет показывает новые дома и недавние постройки."
                        color: root.mutedColor
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    ScatterPlot {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        points: predictionViewModel.marketScatter
                        gridColor: "#EEE4D6"
                        axisColor: root.borderColor
                        textColor: root.textColor
                        mutedColor: root.mutedColor
                        accentColor: root.accentColor
                        accentWarm: root.accentWarm
                    }
                }
            }
        }
    }

    Connections {
        target: predictionViewModel

        function onOperationInProgress(inProgress) {
            root.predictionBusy = inProgress
        }
    }
}
