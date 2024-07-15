#pragma once
#include <QObject>
#include "adapters_export.hpp"
#include "i_translation_controller.hpp"
#include "i_translation_service.hpp"

namespace adapters::controllers
{

class ADAPTERS_EXPORT TranslationController : public ITranslationController
{
    Q_OBJECT

public:
    TranslationController(application::ITranslationService * service);

    void getTranslation(const QString& text) override;

private:
    application::ITranslationService * m_translationService;
};

}

