#ifndef APPLICATIONDATA_H
#define APPLICATIONDATA_H

#include <QSettings>
#include <QDebug>

class ApplicationData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int speed READ speed WRITE setSpeed NOTIFY speedChanged)
public:
    void initialize() {
        QSettings settings("divan","Hackertyper");
        _speed = settings.value("Main/Speed", 14).toInt();
        qDebug() << "Speed READ1: " << _speed;
    }

    int speed() { return _speed; qDebug() << "Speed READ: " << _speed; }
    void setSpeed(const int speed) {
        if (speed != _speed) {
            QSettings settings("divan", "Hackertyper");
            _speed = speed;
            settings.setValue("Main/Speed", speed);
            qDebug() << "Speed Set: " << speed;
            emit speedChanged();
        }
    }

signals:
    void speedChanged();

private:
    int _speed;
};



#endif // APPLICATIONDATA_H
