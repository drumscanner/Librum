#pragma once
#include <QByteArray>
#include <QObject>
#include <QString>
#include "application_export.hpp"

namespace application
{

class APPLICATION_EXPORT ITranslationGateway : public QObject
{
    Q_OBJECT

public:
    virtual ~ITranslationGateway() noexcept = default;

    virtual void getTranslation(const QString& authToken, const QString& text) = 0;

    signals:
        void wordReady(const QString& translation);
        void errorOccured(const int code);
};

}  // namespace application