#ifndef CODEDATA_H
#define CODEDATA_H

#include <QSettings>
#include <QDebug>
#include <QApplication>
#include <QFile>
#include <QDir>

class CodeData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString file READ file WRITE setFile NOTIFY fileChanged)
public:
    void initialize() {
        // Populate files list
        QDir codeDir(":/code");
        codeDir.setFilter(QDir::Files | QDir::NoSymLinks);
        QFileInfoList list = codeDir.entryInfoList();
        foreach (QFileInfo f, list)
            _files << f.fileName();

        QSettings settings("divan", "Hackertyper");
        _file = settings.value("Main/Code", "groups.c").toString();
        readFile(_file);
    }

    QString file() { return _file; }
    void setFile(const QString file) {
        if (file != _file) {
            QSettings settings("divan", "Hackertyper");
            _file = file;
            settings.setValue("Main/Code", file);
            emit fileChanged();
            readFile(_file);
        }
    }

public slots:
    Q_INVOKABLE QString getNextCode(int speed) {
        QString code = _data.mid(_pos, speed);
        _pos += speed;
        return code;
    }

    Q_INVOKABLE void resetPosition() { _pos = 0; }
    Q_INVOKABLE QStringList getFiles() { return _files; }

signals:
    void fileChanged();

private:
    QString _file;
    int _pos;
    QString _data;
    QStringList _files;

    void readFile(const QString fileName)
    {
        QFile file(":/code/" + fileName);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            qWarning() << "(WW) Cannot find file" << fileName;
            return;
        }

        _data.clear();
        while (!file.atEnd()) {
            _data += file.readLine();
        }

        _pos = 0;
    }
};

#endif // CODEDATA_H
