import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    width: parent.width
    height: parent.height

    property double bestMSE: Number.MAX_VALUE

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Label {
            id: bestMSELabel
            text: "Лучший MSE: ? (обучите модель)"
            font.bold: true
            Layout.alignment: Qt.AlignLeft
            padding: 10
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: parent.height - 100

            TextArea {
                id: logArea
                readOnly: true
                textFormat: TextEdit.RichText
                font.family: "Monospace"
                wrapMode: TextEdit.NoWrap
            }
        }

        Button {
            id: trainButton
            text: "Обучить"
            Layout.alignment: Qt.AlignHCenter
            enabled: true
            onClicked: {
                predictionViewModel.trainModel(1000, 0.001)
            }
        }
    }

    Connections {
        target: predictionViewModel
        onTrainingProgress: function(epoch, mse) {
            logArea.append("Эпоха: " + epoch + ", MSE: " + mse.toFixed(5))
            if (mse < bestMSE) {
                bestMSE = mse
                bestMSELabel.text = "Лучший MSE: " + bestMSE.toFixed(5)
            }
        }
        onTrainingStarted: function() {
            trainButton.enabled = false
            logArea.append("<font color='gray'>Обучение началось!</font>");
        }

        onTrainingFinished: function() {
            trainButton.enabled = true
            logArea.append("<font color='green'>Обучение окончено!</font>");
        }
    }
}
