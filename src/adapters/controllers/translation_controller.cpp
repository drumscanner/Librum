#include "translation_controller.hpp"

namespace adapters::controllers
{

TranslationController::TranslationController(
    application::ITranslationService* service) :
    m_translationService(service)
{
    connect(m_translationService,
            &application::ITranslationService::wordReady, this,
            &TranslationController::wordReady);

    connect(m_translationService,
            &application::ITranslationService::limitReached, this,
            &TranslationController::limitReached);

    connect(m_translationService,
            &application::ITranslationService::requestTooLong, this,
            &TranslationController::requestTooLong);
}

void TranslationController::getTranslation(const QString& text)
{
    m_translationService->getTranslation(text);
}

}