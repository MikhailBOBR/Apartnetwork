import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    visible: true
    width: 540
    height: 720
    title: "Предсказание цены на квартиру"

    StackLayout {
       id: stackLayout
       anchors.fill: parent
       anchors.margins: 30
       currentIndex: currentPage

       PredictionPage {
           id: predictionPage
       }

       TrainingPage {
           id: trainingPage
       }
   }

   property int currentPage: 0

   MenuBar {
       anchors.top: parent.top
       anchors.right: parent.right
       background: Rectangle {
           color: "#f0f0f0"  // Светло-серый цвет фона
       }
       Menu {
           title: "Навигация"
           MenuItem {
               text: "Предсказание"
               onTriggered: currentPage = 0
           }
           MenuItem {
               text: "Обучение"
               onTriggered: currentPage = 1
           }
       }
   }
}
