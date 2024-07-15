#pragma once
#include <QObject>
#include <QString>
#include "adapters_export.hpp"

namespace adapters
{

class ADAPTERS_EXPORT ITranslationAccess : public QObject
{
    Q_OBJECT

public:
    virtual ~ITranslationAccess() noexcept = default;

    virtual void getTranslation(const QString& authToken, const QString& query) = 0;

    signals:
        void wordReceived(const QString& word) const;
        void errorOccured(int errorCode) const;
};

}