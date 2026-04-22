import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window

    visible: true
    width: 1280
    height: 860
    minimumWidth: 980
    minimumHeight: 720
    title: "Оценка стоимости квартир в Москве — 2023"

    property color backgroundColor: "#F6F0E6"
    property color surfaceColor: "#FFF9F1"
    property color borderColor: "#E4D8C8"
    property color textColor: "#21313A"
    property color mutedColor: "#6B7280"
    property color accentColor: "#1B6B65"
    property color accentWarm: "#D97D54"

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FBF7F1" }
            GradientStop { position: 1.0; color: window.backgroundColor }
        }

        Rectangle {
            x: parent.width - 280
            y: -60
            width: 360
            height: 360
            radius: 180
            color: "#EFD8C0"
            opacity: 0.45
        }

        Rectangle {
            x: -120
            y: parent.height - 220
            width: 320
            height: 320
            radius: 160
            color: "#DDEFE6"
            opacity: 0.55
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 18

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 126
            radius: 28
            color: window.surfaceColor
            border.color: window.borderColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 22

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Label {
                        text: "Оценка стоимости квартир в Москве"
                        color: window.textColor
                        font.pixelSize: 30
                        font.bold: true
                    }

                    Label {
                        text: "Нейросетевое приложение с выборкой, откалиброванной под рынок 2023 года, визуализацией и тестовым контуром."
                        color: window.mutedColor
                        wrapMode: Text.Wrap
                        font.pixelSize: 15
                    }
                }

                ColumnLayout {
                    spacing: 10

                    Rectangle {
                        radius: 16
                        color: "#E6F3EE"
                        implicitWidth: 212
                        implicitHeight: 38

                        Label {
                            anchors.centerIn: parent
                            text: "Москва 2023 • встроенная выборка"
                            color: window.accentColor
                            font.bold: true
                        }
                    }

                    Rectangle {
                        radius: 16
                        color: "#F9E6DB"
                        implicitWidth: 212
                        implicitHeight: 38

                        Label {
                            anchors.centerIn: parent
                            text: "Автор: Кашпирев М.Д."
                            color: window.accentWarm
                            font.bold: true
                        }
                    }
                }
            }
        }

        TabBar {
            id: tabs
            Layout.fillWidth: true
            currentIndex: 0
            spacing: 10

            background: Rectangle {
                color: "transparent"
            }

            TabButton { text: "Прогноз" }
            TabButton { text: "Обучение и аналитика" }
        }

        StackLayout {
            id: pages
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabs.currentIndex

            PredictionPage {
                surfaceColor: window.surfaceColor
                borderColor: window.borderColor
                textColor: window.textColor
                mutedColor: window.mutedColor
                accentColor: window.accentColor
                accentWarm: window.accentWarm
            }

            TrainingPage {
                surfaceColor: window.surfaceColor
                borderColor: window.borderColor
                textColor: window.textColor
                mutedColor: window.mutedColor
                accentColor: window.accentColor
                accentWarm: window.accentWarm
            }
        }
    }
}
