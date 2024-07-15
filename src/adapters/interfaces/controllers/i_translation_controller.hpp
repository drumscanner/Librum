#pragma once
#include <QObject>
#include <QString>
#include "adapters_export.hpp"

namespace adapters
{

class ADAPTERS_EXPORT ITranslationController : public QObject
{
    Q_OBJECT

public:
    virtual ~ITranslationController() noexcept = default;

    Q_INVOKABLE virtual void getTranslation(const QString& text) = 0;

    signals:
        void wordReady(const QString& word);
        void limitReached();
        void requestTooLong();
};

}