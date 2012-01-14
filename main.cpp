#include <QtGui/QApplication>
#include <QtDeclarative>
#include "qmlapplicationviewer.h"
#include "applicationdata.h"
#include "codedata.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());
    ApplicationData data;
    data.initialize();
    CodeData code;
    code.initialize();

    viewer->rootContext()->setContextProperty("codeData", &code);
    viewer->rootContext()->setContextProperty("applicationData", &data);
    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer->setMainQmlFile(QLatin1String("qml/hackertyper/main.qml"));
    viewer->showFullScreen();

    return app->exec();
}
