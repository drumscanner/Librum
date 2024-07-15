#include "translation_gateway.hpp"

namespace adapters::gateways
{

TranslationGateway::TranslationGateway(
    ITranslationAccess* service) :
    m_translationAccess(service)
{
    connect(m_translationAccess, &ITranslationAccess::wordReceived, this,
            &TranslationGateway::wordReady);

    connect(m_translationAccess, &ITranslationAccess::errorOccured, this,
            &TranslationGateway::errorOccured);
}

void TranslationGateway::getTranslation(const QString& authToken,
                                          const QString& text)
{
    m_translationAccess->getTranslation(authToken, text);
}

} 