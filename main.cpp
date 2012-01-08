#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
//#ifdef MEEGO_EDITION_HARMATTAN
    viewer->setMainQmlFile(QLatin1String("qml/hackertyper/main.qml"));
//#else
//    viewer->setMainQmlFile(QLatin1String("qml/hackertyper/main5.qml"));
//#endif
    viewer->showFullScreen();

    return app->exec();
}
