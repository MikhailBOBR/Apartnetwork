qt_add_library(content STATIC)

qt6_add_qml_module(content
    URI "content"
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    QML_FILES
        App.qml
        InsightCard.qml
        LineChart.qml
        PredictionPage.qml
        ScatterPlot.qml
        TrainingPage.qml
    RESOURCES
        fonts/fonts.txt
)
