#include "translation_service.hpp"
#include "error_code.hpp"


namespace application::services
{

TranslationService::TranslationService(
    ITranslationGateway * gateway) :
    m_translationGateway(gateway)
{
    connect(m_translationGateway, &ITranslationGateway::wordReady, this, &TranslationService::wordReady);
    connect(
        m_translationGateway, &ITranslationGateway::errorOccured, this,
        [this](int code)
        {
            if(code == static_cast<int>(
                           error_codes::ErrorCode::TranslationLimitReached))
            {
                emit limitReached();
            }
            else if(code ==
                    static_cast<int>(error_codes::ErrorCode::TranslateRequestTooLong))
            {
                emit requestTooLong();
            }
        });
}

void TranslationService::getTranslation(const QString& text)
{
    m_translationGateway->getTranslation(m_authenticationToken, text);
}

void TranslationService::setupUserData(const QString& token,
                                         const QString& email)
{
    Q_UNUSED(email);

    m_authenticationToken = token;
}

void TranslationService::clearUserData()
{
    m_authenticationToken.clear();
}

}