#pragma once
#include <QObject>
#include "i_translation_access.hpp"
#include "i_translation_gateway.hpp"

namespace adapters::gateways
{

class TranslationGateway : public application::ITranslationGateway
{
    Q_OBJECT

public:
    TranslationGateway(ITranslationAccess* aiExplanationService);

    void getTranslation(const QString& authToken, const QString& text) override;

private:
    ITranslationAccess* m_translationAccess;
};

}