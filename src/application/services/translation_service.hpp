#pragma once
#include "i_translation_service.hpp"
#include "i_translation_gateway.hpp"

namespace application::services
{

class TranslationService : public ITranslationService {
    Q_OBJECT

public:
    TranslationService(ITranslationGateway* translationGateway);

    void getTranslation(const QString& text) override;

    public slots:
    void setupUserData(const QString& token, const QString& email) override;
    void clearUserData() override;

private:
    ITranslationGateway* m_translationGateway;

    QString m_authenticationToken;
};

}



