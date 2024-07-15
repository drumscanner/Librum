#pragma once
#include <QByteArray>
#include <QDateTime>
#include <QDebug>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <QSettings>
#include "i_translation_access.hpp"

namespace infrastructure::persistence
{

class TranslationAccess : public adapters::ITranslationAccess
{
    Q_OBJECT

public:
    TranslationAccess();

    void getTranslation(const QString& authToken, const QString& query) override;

private:
    QNetworkRequest createRequest(QUrl url, QString authToken) const;
    QDateTime m_lastRequestStartTime;

    QNetworkAccessManager m_networkAccessManager;
    QString domain;
};

}  // namespace infrastructure::persistence
