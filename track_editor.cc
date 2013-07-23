#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>

#include <grid_operator.h>

int main(int argc, char ** argv)
{
    QGuiApplication applicaiton(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterType<GridOperator>("TrackEditor", 1, 0, "GridOperator");
    engine.load(QUrl("qrc:///TrackEditor.qml"));
    return applicaiton.exec();
}
