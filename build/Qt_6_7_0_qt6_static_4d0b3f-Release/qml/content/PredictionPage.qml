import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    width: parent.width
    height: parent.height

    ScrollView {
        anchors.fill: parent
        GridLayout {
            columns: 2
            columnSpacing: 10
            rowSpacing: 10
            width: parent.width

            Label {
                text: "Площадь:"
            }
            TextField {
                id: area
            }

            Label {
                text: "Количество спален:"
            }
            TextField {
                id: bedrooms
            }

            Label {
                text: "Количество ванных комнат:"
            }
            TextField {
                id: bathrooms
            }

            Label {
                text: "Количество этажей:"
            }
            TextField {
                id: stories
            }

            Label {
                text: "Выход на главную дорогу:"
            }
            CheckBox {
                id: mainroad
            }

            Label {
                text: "Наличие гостевой комнаты:"
            }
            CheckBox {
                id: guestroom
            }

            Label {
                text: "Наличие подвала:"
            }
            CheckBox {
                id: basement
            }

            Label {
                text: "Наличие водонагревателя:"
            }
            CheckBox {
                id: hotwaterheating
            }

            Label {
                text: "Наличие кондиционера:"
            }
            CheckBox {
                id: airconditioning
            }

            Label {
                text: "Количество парковочных мест:"
            }
            TextField {
                id: parking
            }

            Label {
                text: "Престижный район:"
            }
            CheckBox {
                id: prefarea
            }

            Label {
                text: "Состояние мебели:"
            }
            ComboBox {
                id: furnishingstatus
                model: ["Не меблирована", "Частично меблирована", "Полностью меблирована"]
            }

            Item { Layout.columnSpan: 2 }

            Button {
                id: predictButton
                text: "Предсказать цену"
                onClicked: {
                    predictionViewModel.predictPrice(
                        parseFloat(area.text), parseInt(bedrooms.text), parseInt(bathrooms.text),
                        parseInt(stories.text), mainroad.checked, guestroom.checked, basement.checked,
                        hotwaterheating.checked, airconditioning.checked, parseInt(parking.text),
                        prefarea.checked, furnishingstatus.currentText
                    )
                }
            }

            ProgressBar {
                id: progressBar
                visible: false
                width: 200
                indeterminate: true
            }

            Label {
                id: predictionResult
                text: ""
                font.pointSize: 16
            }
        }
        Connections {
            target: predictionViewModel
            onPredictionReady: function(result) {
                predictionResult.text = "Цена: " + result
                progressBar.visible = false
                predictButton.enabled = true
            }

            onOperationInProgress: function(inProgress) {
                progressBar.visible = inProgress
                predictButton.enabled = !inProgress
            }
        }
    }
}
