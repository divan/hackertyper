#ifndef CODEDATA_H
#define CODEDATA_H

#include <QSettings>
#include <QDebug>
#include <QApplication>
#include <QFile>
#include <QTextStream>

class CodeData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
public:
    void initialize() {
        QSettings settings("divan","Hackertyper");
        _name = settings.value("Main/Code", "groups.c").toString();

        QFile file(":/groups.c");
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            qWarning() << "(WW) Cannot find file" << _name;
            return;
        }

        while (!file.atEnd()) {
            _data += file.readLine();
        }

        _pos = 0;
    }

    QString name() { return _name; }
    void setName(const QString name) {
        if (name != _name) {
            QSettings settings("divan", "Hackertyper");
            _name = name;
            settings.setValue("Main/Code", name);
            emit nameChanged();
        }
    }

public slots:
    Q_INVOKABLE QString getNextCode(int speed) {
        QString code = _data.mid(_pos, speed);
        _pos += speed;
        qDebug() << "getNextCode";
        return code;
    }

    Q_INVOKABLE void resetPosition() { _pos = 0; }

signals:
    void nameChanged();

private:
    QString _name;
    int _pos;
    QString _data;
};

#endif // CODEDATA_H
