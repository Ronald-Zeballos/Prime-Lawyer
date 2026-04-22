import '../models/app_language.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get isSpanish => language == AppLanguage.spanish;

  String get appName => 'Prime Lawyer';
  String get signInSubtitle => isSpanish
      ? 'Inicia sesión para continuar con la demo legal del MVP.'
      : 'Sign in to continue with the legal MVP demo.';
  String get demoCredentialsTitle =>
      isSpanish ? 'Credenciales demo' : 'Demo credentials';
  String get demoCredentialsDescription => isSpanish
      ? 'Puedes mantener el usuario administrador por defecto para la demo del MVP.'
      : 'You can keep the default admin user for the MVP demo.';
  String get emailLabel => isSpanish ? 'Correo' : 'Email';
  String get passwordLabel => isSpanish ? 'Contraseña' : 'Password';
  String get emailRequiredError =>
      isSpanish ? 'El correo es obligatorio.' : 'Email is required.';
  String get emailInvalidError => isSpanish
      ? 'El formato del correo parece inválido.'
      : 'Email format looks invalid.';
  String get passwordRequiredError =>
      isSpanish ? 'La contraseña es obligatoria.' : 'Password is required.';
  String get signingIn => isSpanish ? 'Ingresando...' : 'Signing in...';
  String get signIn => isSpanish ? 'Iniciar sesión' : 'Sign in';
  String get apiBaseUrlLabel => isSpanish ? 'URL base de API' : 'API base URL';
  String get apiConnectionTitle =>
      isSpanish ? 'Conexion API' : 'API connection';
  String get apiConnectionDescription => isSpanish
      ? 'La app intenta detectar automaticamente el backend local. Si quieres, tambien puedes fijar una URL manual.'
      : 'The app tries to detect the local backend automatically. You can still force a manual URL if needed.';
  String get apiBaseUrlHint => 'http://192.168.1.20:3000/api/v1';
  String get apiManualOverrideHint => isSpanish
      ? 'Deja este campo vacio si quieres seguir usando la deteccion automatica.'
      : 'Leave this field empty if you want to keep using automatic detection.';
  String get editApiBaseUrl => isSpanish ? 'Editar URL de API' : 'Edit API URL';
  String get saveApiBaseUrl => isSpanish ? 'Guardar URL' : 'Save URL';
  String get testApiConnection =>
      isSpanish ? 'Probar conexion' : 'Test connection';
  String get resetApiBaseUrl =>
      isSpanish ? 'Detectar automaticamente' : 'Detect automatically';
  String get apiBaseUrlSaved =>
      isSpanish ? 'URL de API actualizada.' : 'API URL updated.';
  String get apiBaseUrlReset => isSpanish
      ? 'La app volvio a deteccion automatica.'
      : 'The app is using automatic detection again.';
  String get apiBaseUrlRequiredError => isSpanish
      ? 'La URL base de API es obligatoria.'
      : 'API base URL is required.';
  String get apiBaseUrlInvalidError => isSpanish
      ? 'La URL base de API no es valida.'
      : 'API base URL is invalid.';
  String get apiCurrentModeAuto => isSpanish
      ? 'Modo actual: deteccion automatica'
      : 'Current mode: automatic detection';
  String get apiCurrentModeManual =>
      isSpanish ? 'Modo actual: URL manual' : 'Current mode: manual URL';
  String get apiAutoDetecting => isSpanish
      ? 'Buscando un backend local disponible...'
      : 'Looking for a reachable local backend...';
  String get realDeviceApiHint => isSpanish
      ? 'En telefono real la app intentara encontrar tu backend en la misma red Wi-Fi. Si falla, guarda una URL manual.'
      : 'On a physical phone the app will try to find your backend on the same Wi-Fi network. If it fails, save a manual URL.';
  String get apiConnectionSuccess => isSpanish
      ? 'Conexion con la API correcta.'
      : 'API connection is working.';
  String get apiTestingConnection => isSpanish
      ? 'Probando conexion con la API...'
      : 'Testing the API connection...';
  String get apiConnectionFailure => isSpanish
      ? 'No se pudo conectar con la API.'
      : 'Could not connect to the API.';
  String get ocrTextPreviewTitle =>
      isSpanish ? 'Preview OCR' : 'OCR preview';
  String ocrProcessedAt(String value) => isSpanish
      ? 'OCR procesado: $value'
      : 'OCR processed: $value';
  String get settingsTitle => isSpanish ? 'Configuración' : 'Settings';
  String get languageTitle => isSpanish ? 'Idioma' : 'Language';
  String get languageDescription => isSpanish
      ? 'Cambia el idioma visible de la app para la demo.'
      : 'Change the visible language of the app for the demo.';
  String get englishLabel => 'English';
  String get spanishLabel => 'Español';
  String get accountTitle => isSpanish ? 'Cuenta' : 'Account';
  String get profileSectionTitle => isSpanish ? 'Perfil' : 'Profile';
  String get profileSectionDescription => isSpanish
      ? 'Edita tu identidad visible dentro de la plataforma.'
      : 'Edit your visible identity inside the platform.';
  String get profileDisplayNameLabel =>
      isSpanish ? 'Nombre visible' : 'Display name';
  String get profileDisplayNameTooLong => isSpanish
      ? 'El nombre visible no puede superar 120 caracteres.'
      : 'Display name cannot exceed 120 characters.';
  String get profileBioLabel => isSpanish ? 'Bio' : 'Bio';
  String get profileBioHint => isSpanish
      ? 'Describe brevemente tu perfil o enfoque legal.'
      : 'Briefly describe your profile or legal focus.';
  String get profileBioTooLong => isSpanish
      ? 'La bio no puede superar 500 caracteres.'
      : 'Bio cannot exceed 500 characters.';
  String get saveProfileAction => isSpanish ? 'Guardar perfil' : 'Save profile';
  String get savingProfile =>
      isSpanish ? 'Guardando perfil...' : 'Saving profile...';
  String get profileSaved =>
      isSpanish ? 'Perfil actualizado.' : 'Profile updated.';
  String get profileTypeLabel => isSpanish ? 'Tipo' : 'Type';
  String get profilePlanLabel => isSpanish ? 'Plan' : 'Plan';
  String profileTokensLabel(int value) =>
      isSpanish ? 'Tokens disponibles: $value' : 'Tokens available: $value';
  String get profileUpgradeHint => isSpanish
      ? 'El upgrade de plan llegara en un siguiente sprint.'
      : 'Plan upgrade is coming in a later sprint.';
  String get profileRequiresSession => isSpanish
      ? 'Inicia sesion para ver y editar tu perfil.'
      : 'Sign in to view and edit your profile.';
  String get notSignedInYet =>
      isSpanish ? 'Todavía no iniciaste sesión.' : 'You are not signed in yet.';
  String signedInAs(String fullName, String role) => isSpanish
      ? 'Sesión iniciada como $fullName ($role).'
      : 'Signed in as $fullName ($role).';
  String get passwordChangeComingSoon => isSpanish
      ? 'Cambio de contraseña: llegará en una siguiente fase.'
      : 'Password change: coming in a later phase.';
  String get signOut => isSpanish ? 'Cerrar sesión' : 'Sign out';
  String get openSettings =>
      isSpanish ? 'Abrir configuración' : 'Open settings';
  String get welcomeBack => isSpanish ? 'Bienvenido' : 'Welcome back';
  String welcomeUser(String firstName) =>
      isSpanish ? 'Bienvenido, $firstName' : 'Welcome, $firstName';
  String get heroGuestMessage => isSpanish
      ? 'La sesión está activa y lista para las siguientes acciones legales.'
      : 'The session is active and ready for the next legal actions.';
  String heroUserMessage(String fullName, String role) => isSpanish
      ? 'Sesión iniciada como $fullName ($role). Tu panel ahora lee datos reales del backend del MVP.'
      : 'Signed in as $fullName ($role). Your dashboard is now reading live data from the MVP backend.';
  String clientsCount(int count) =>
      isSpanish ? '$count clientes' : '$count clients';
  String caseFilesCount(int count) =>
      isSpanish ? '$count expedientes' : '$count case files';
  String activeCasesCount(int count) =>
      isSpanish ? '$count casos activos' : '$count active cases';
  String get quickActionsTitle =>
      isSpanish ? 'Acciones rápidas' : 'Quick actions';
  String get manageClients =>
      isSpanish ? 'Gestionar clientes' : 'Manage clients';
  String get manageCaseFiles =>
      isSpanish ? 'Gestionar expedientes' : 'Manage case files';
  String resumeCaseFile(String internalCode) =>
      isSpanish ? 'Continuar $internalCode' : 'Resume $internalCode';
  String get dashboardTitle => isSpanish ? 'Panel principal' : 'Dashboard';
  String get workspaceTitle =>
      isSpanish ? 'Workspace legal' : 'Legal workspace';
  String get workspaceDescription => isSpanish
      ? 'Opera clientes, expedientes y documentos desde un solo lugar.'
      : 'Operate clients, case files and documents from one place.';
  String get currentSnapshot =>
      isSpanish ? 'Resumen actual' : 'Current snapshot';
  String get syncedWithBackend => isSpanish
      ? 'Sincronizado con el backend local del MVP'
      : 'Synced with the local MVP backend';
  String get refreshDashboard =>
      isSpanish ? 'Actualizar panel' : 'Refresh dashboard';
  String get sessionStatusReady =>
      isSpanish ? 'Listo para operar' : 'Ready to work';
  String get sessionStatusDescription => isSpanish
      ? 'JWT activo y modulos clave conectados.'
      : 'JWT active and key modules connected.';
  String get clientsMetricLabel => isSpanish ? 'Clientes' : 'Clients';
  String get clientsMetricCaption => isSpanish
      ? 'Personas y estudios registrados'
      : 'Registered people and firms';
  String get activeCasesMetricLabel =>
      isSpanish ? 'Casos activos' : 'Active cases';
  String get activeCasesMetricCaption =>
      isSpanish ? 'Abiertos o en curso' : 'Open or in progress';
  String get totalCaseFilesMetricLabel =>
      isSpanish ? 'Expedientes' : 'Case files';
  String get totalCaseFilesMetricCaption => isSpanish
      ? 'Asuntos registrados en el MVP'
      : 'Matters registered in the MVP';
  String get clientsActionDescription => isSpanish
      ? 'Altas, consulta y seguimiento legal.'
      : 'Create, review and track legal contacts.';
  String get caseFilesActionDescription => isSpanish
      ? 'Organiza expedientes y responsables.'
      : 'Organize case files and responsibles.';
  String get settingsActionTitle => isSpanish ? 'Preferencias' : 'Preferences';
  String get settingsActionDescription => isSpanish
      ? 'Idioma, sesion y opciones de la demo.'
      : 'Language, session and demo options.';
  String get openRecentDocumentsTitle => isSpanish ? 'Documentos' : 'Documents';
  String documentsActionDescription(String internalCode) => isSpanish
      ? 'Abrir documentos de $internalCode'
      : 'Open documents for $internalCode';
  String get documentsActionFallbackDescription => isSpanish
      ? 'Crea un expediente para registrar documentos.'
      : 'Create a case file to start registering documents.';
  String get recentActivityTitle =>
      isSpanish ? 'Actividad reciente' : 'Recent activity';
  String get navigationLabel => isSpanish ? 'Navegacion' : 'Navigation';
  String get overviewLabel => isSpanish ? 'Resumen' : 'Overview';
  String get secureSignOutDescription => isSpanish
      ? 'Cerrar sesion segura en este dispositivo.'
      : 'Securely sign out from this device.';
  String get viewAll => isSpanish ? 'Ver todo' : 'View all';
  String get noUserRoleFallback => isSpanish ? 'Equipo legal' : 'Legal team';
  String get recentClientsTitle =>
      isSpanish ? 'Clientes recientes' : 'Recent clients';
  String get noClientsTitle =>
      isSpanish ? 'Aún no hay clientes' : 'No clients yet';
  String get noClientsDescription => isSpanish
      ? 'Crea tu primer cliente y aparecerá aquí.'
      : 'Create your first client and it will appear here.';
  String get recentCaseFilesTitle =>
      isSpanish ? 'Expedientes recientes' : 'Recent case files';
  String get noCaseFilesTitle =>
      isSpanish ? 'Aún no hay expedientes' : 'No case files yet';
  String get noCaseFilesDescription => isSpanish
      ? 'Crea un expediente y el panel lo mostrará aquí.'
      : 'Create a case file and the dashboard will surface it here.';
  String get documentFieldLabel => isSpanish ? 'Documento' : 'Document';
  String get phoneLabel => isSpanish ? 'Teléfono' : 'Phone';
  String get addressLabel => isSpanish ? 'Dirección' : 'Address';
  String get notesLabel => isSpanish ? 'Observaciones' : 'Notes';
  String createdOn(String value) =>
      isSpanish ? 'Creado $value' : 'Created $value';
  String get createClientTitle => isSpanish ? 'Crear cliente' : 'Create client';
  String get firstNameLabel => isSpanish ? 'Nombres' : 'First name';
  String get firstNameRequiredError =>
      isSpanish ? 'Los nombres son obligatorios.' : 'First name is required.';
  String get lastNameLabel => isSpanish ? 'Apellidos' : 'Last name';
  String get lastNameRequiredError =>
      isSpanish ? 'Los apellidos son obligatorios.' : 'Last name is required.';
  String get documentNumberLabel =>
      isSpanish ? 'Número de documento' : 'Document number';
  String get documentNumberRequiredError => isSpanish
      ? 'El número de documento es obligatorio.'
      : 'Document number is required.';
  String get creating => isSpanish ? 'Creando...' : 'Creating...';
  String get createClientAction =>
      isSpanish ? 'Crear cliente' : 'Create client';
  String get clientsTitle => isSpanish ? 'Clientes' : 'Clients';
  String get refreshClients =>
      isSpanish ? 'Actualizar clientes' : 'Refresh clients';
  String get newClient => isSpanish ? 'Nuevo cliente' : 'New client';
  String get noClientsListTitle =>
      isSpanish ? 'No hay clientes todavía' : 'No clients yet';
  String get noClientsListDescription => isSpanish
      ? 'Crea tu primer cliente para iniciar el flujo legal del MVP.'
      : 'Create your first client to start the MVP legal flow.';
  String get caseFilesTitle => isSpanish ? 'Expedientes' : 'Case files';
  String get refreshCaseFiles =>
      isSpanish ? 'Actualizar expedientes' : 'Refresh case files';
  String get newCaseFile => isSpanish ? 'Nuevo expediente' : 'New case file';
  String get noCaseFilesListTitle =>
      isSpanish ? 'No hay expedientes todavía' : 'No case files yet';
  String get noCaseFilesListWithClientsDescription => isSpanish
      ? 'Crea tu primer expediente para continuar el flujo legal del MVP.'
      : 'Create your first case file to continue the legal MVP flow.';
  String get noCaseFilesListWithoutClientsDescription => isSpanish
      ? 'Primero crea al menos un cliente y luego registra un expediente.'
      : 'Create at least one client first, then register a case file.';
  String get createCaseFileTitle =>
      isSpanish ? 'Crear expediente' : 'Create case file';
  String get createClientBeforeCaseFile => isSpanish
      ? 'Crea al menos un cliente antes de registrar un expediente.'
      : 'Create at least one client before registering a case file.';
  String get clientLabel => isSpanish ? 'Cliente' : 'Client';
  String get clientRequiredError =>
      isSpanish ? 'El cliente es obligatorio.' : 'Client is required.';
  String get internalCodeLabel =>
      isSpanish ? 'Código interno' : 'Internal code';
  String get internalCodeRequiredError => isSpanish
      ? 'El código interno es obligatorio.'
      : 'Internal code is required.';
  String get subjectLabel => isSpanish ? 'Materia' : 'Subject';
  String get subjectRequiredError =>
      isSpanish ? 'La materia es obligatoria.' : 'Subject is required.';
  String get processTypeLabel => isSpanish ? 'Tipo de proceso' : 'Process type';
  String get processTypeRequiredError => isSpanish
      ? 'El tipo de proceso es obligatorio.'
      : 'Process type is required.';
  String get confidentialityLevelLabel =>
      isSpanish ? 'Nivel de confidencialidad' : 'Confidentiality level';
  String get createCaseFileAction =>
      isSpanish ? 'Crear expediente' : 'Create case file';
  String get caseFileDetailTitle =>
      isSpanish ? 'Detalle del expediente' : 'Case file detail';
  String get openCaseFileAction =>
      isSpanish ? 'Abrir expediente' : 'Open case file';
  String get openKnowledgeRepository => isSpanish
      ? 'Abrir repositorio colaborativo'
      : 'Open collaborative repository';
  String get caseFileUnavailable => isSpanish
      ? 'El expediente no está disponible.'
      : 'Case file not available.';
  String get processTypeDetailLabel =>
      isSpanish ? 'Tipo de proceso' : 'Process type';
  String get statusLabel => isSpanish ? 'Estado' : 'Status';
  String get confidentialityLabel =>
      isSpanish ? 'Confidencialidad' : 'Confidentiality';
  String get openedAtLabel => isSpanish ? 'Fecha de apertura' : 'Opened at';
  String get closedAtLabel => isSpanish ? 'Fecha de cierre' : 'Closed at';
  String get publishedAtLabel =>
      isSpanish ? 'Fecha de publicación' : 'Published at';
  String get notClosedYet => isSpanish ? 'Sin cierre' : 'Not closed';
  String get notPublishedYet =>
      isSpanish ? 'Sin publicar' : 'Not published yet';
  String get openDocuments => isSpanish ? 'Abrir documentos' : 'Open documents';
  String get documentsTitle => isSpanish ? 'Documentos' : 'Documents';
  String get refreshDocuments =>
      isSpanish ? 'Actualizar documentos' : 'Refresh documents';
  String caseFileNameLabel(String value) =>
      isSpanish ? 'Expediente: $value' : 'Case file: $value';
  String get noDocumentsTitle =>
      isSpanish ? 'Aún no hay documentos' : 'No documents yet';
  String get noDocumentsDescription => isSpanish
      ? 'Sube el primer documento de este expediente para completar el flujo del MVP.'
      : 'Upload the first document for this case file to complete the MVP flow.';
  String get upload => isSpanish ? 'Subir' : 'Upload';
  String get registerDocumentTitle =>
      isSpanish ? 'Registrar documento' : 'Register document';
  String get chooseDocumentSource => isSpanish
      ? 'Selecciona como quieres cargar el documento'
      : 'Choose how you want to add the document';
  String get documentsStoredAsPdfHint => isSpanish
      ? 'Las fotos o imagenes se convierten a PDF antes de subirlas.'
      : 'Photos or images are converted to PDF before upload.';
  String get chooseFile => isSpanish ? 'Elegir archivo' : 'Choose file';
  String get changeFile => isSpanish ? 'Cambiar archivo' : 'Change file';
  String get useCamera => isSpanish ? 'Usar camara' : 'Use camera';
  String get selectedDocumentTitle =>
      isSpanish ? 'Documento listo para subir' : 'Document ready to upload';
  String get openPdfAction => isSpanish ? 'Abrir PDF' : 'Open PDF';
  String get pdfOnlyLabel => isSpanish ? 'Solo PDF' : 'PDF only';
  String get analyzeDocument =>
      isSpanish ? 'Analizar documento' : 'Analyze document';
  String get analysisPreviewTitle =>
      isSpanish ? 'Analisis juridico' : 'Legal analysis';
  String get analysisPreviewBadge => isSpanish ? 'Preview IA' : 'AI preview';
  String get analysisPreviewInfoDescription => isSpanish
      ? 'Esta vista muestra un adelanto visual de lo que hara el analisis juridico del documento dentro del MVP.'
      : 'This view shows a visual preview of what document legal analysis will do in the MVP.';
  String get analysisPreviewInfoStepOne => isSpanish
      ? 'Tomar el expediente y el documento actual como contexto.'
      : 'Use the current case file and document as context.';
  String get analysisPreviewInfoStepTwo => isSpanish
      ? 'Buscar coincidencias por materia, tipo de proceso y metadata.'
      : 'Look for matches by matter, process type and metadata.';
  String get analysisPreviewInfoStepThree => isSpanish
      ? 'Sugerir expedientes parecidos y proximos pasos legales.'
      : 'Suggest similar case files and next legal steps.';
  String get analysisPreviewInfoStepFour => isSpanish
      ? 'Este MVP ya guarda OCR local y una fase posterior usara OpenAI para analisis semantico real.'
      : 'This MVP already stores local OCR text and a later phase will use OpenAI for real semantic analysis.';
  String get analysisPreviewContinueAction =>
      isSpanish ? 'Abrir preview de analisis' : 'Open analysis preview';
  String get consultLegalAi =>
      isSpanish ? 'Consultar IA legal' : 'Consult legal AI';
  String get askAiAboutCase =>
      isSpanish ? 'Consultar IA sobre este caso' : 'Ask AI about this case';
  String get askAiAboutDocument => isSpanish
      ? 'Consultar IA sobre este documento'
      : 'Ask AI about this document';
  String get legalAiConsultationTitle =>
      isSpanish ? 'Consulta legal contextual' : 'Contextual legal consultation';
  String get legalAiConsultationSubtitle => isSpanish
      ? 'La respuesta se construye solo con casos y documentos recuperados del usuario actual.'
      : 'The answer is built only from retrieved cases and documents from the current user.';
  String get legalAiContextualBadge =>
      isSpanish ? 'IA con contexto real' : 'AI with real context';
  String get legalAiQuestionCardTitle =>
      isSpanish ? 'Preparar consulta' : 'Prepare consultation';
  String get legalAiQuestionCardDescription => isSpanish
      ? 'Puedes hacer una pregunta general o anclarla a un caso y documento concretos para mejorar la respuesta.'
      : 'You can ask a general question or anchor it to a specific case and document for a stronger answer.';
  String get aiCaseContextLabel =>
      isSpanish ? 'Caso de contexto' : 'Case context';
  String get aiDocumentContextLabel =>
      isSpanish ? 'Documento de contexto' : 'Document context';
  String get aiNoSpecificCase =>
      isSpanish ? 'Sin caso específico' : 'No specific case';
  String get aiNoSpecificDocument =>
      isSpanish ? 'Sin documento específico' : 'No specific document';
  String get aiSelectCaseFirstHint => isSpanish
      ? 'Selecciona un caso si quieres filtrar documentos.'
      : 'Select a case if you want to filter documents.';
  String get aiLoadingDocuments =>
      isSpanish ? 'Cargando documentos...' : 'Loading documents...';
  String get aiDocumentContextHelper => isSpanish
      ? 'Opcional: afina la consulta con un documento puntual.'
      : 'Optional: refine the consultation with a specific document.';
  String get aiNoDocumentsForSelectedCase => isSpanish
      ? 'Este caso todavía no tiene documentos registrados.'
      : 'This case file does not have registered documents yet.';
  String aiProcessTypeAutoHint(String processType) => isSpanish
      ? 'Tipo de proceso aplicado automaticamente: $processType'
      : 'Process type applied automatically: $processType';
  String get aiQuestionLabel =>
      isSpanish ? 'Pregunta legal' : 'Legal question';
  String get aiQuestionHint => isSpanish
      ? 'Ejemplo: ¿Qué contexto recuperado habla de incumplimiento de contrato y cuáles son los próximos pasos sugeridos?'
      : 'Example: Which recovered context talks about contract breach and what are the suggested next steps?';
  String get aiQuestionRequiredError => isSpanish
      ? 'La pregunta legal es obligatoria.'
      : 'A legal question is required.';
  String get aiSuggestionSummary =>
      isSpanish ? 'Resumen contextual' : 'Context summary';
  String get aiSuggestionSummaryQuestion => isSpanish
      ? 'Resume el contexto legal recuperado para este caso.'
      : 'Summarize the recovered legal context for this matter.';
  String get aiSuggestionDocuments =>
      isSpanish ? 'Documentos a revisar' : 'Documents to review';
  String get aiSuggestionDocumentsQuestion => isSpanish
      ? 'Que documentos similares deberia revisar primero?'
      : 'Which similar documents should I review first?';
  String get aiSuggestionNextSteps =>
      isSpanish ? 'Próximos pasos' : 'Next steps';
  String get aiSuggestionNextStepsQuestion => isSpanish
      ? 'Que siguientes pasos recomienda el contexto recuperado?'
      : 'What next steps does the recovered context suggest?';
  String get aiSubmitQuestion =>
      isSpanish ? 'Consultar IA legal' : 'Ask legal AI';
  String get aiSubmittingQuestion => isSpanish
      ? 'Consultando IA...'
      : 'Consulting AI...';
  String get aiNoAnswerYetTitle =>
      isSpanish ? 'Aún no hay respuesta' : 'No answer yet';
  String get aiNoAnswerYetDescription => isSpanish
      ? 'Selecciona el contexto que quieras usar, escribe tu pregunta y la app responderá solo con información recuperada.'
      : 'Select the context you want to use, write your question, and the app will answer only with recovered information.';
  String get aiConsultationHistoryTitle => isSpanish
      ? 'Consultas recientes'
      : 'Recent consultations';
  String get aiConsultationHistoryDescription => isSpanish
      ? 'Puedes volver a abrir respuestas ya generadas durante esta sesión.'
      : 'You can reopen answers generated earlier in this session.';
  String get aiResponseTitle =>
      isSpanish ? 'Respuesta contextual' : 'Contextual answer';
  String get aiQuestionAskedLabel =>
      isSpanish ? 'Pregunta consultada' : 'Asked question';
  String get aiCopyAnswerAction =>
      isSpanish ? 'Copiar respuesta' : 'Copy answer';
  String get aiNewQuestionAction =>
      isSpanish ? 'Nueva consulta' : 'New question';
  String get aiAnswerCopied =>
      isSpanish ? 'Respuesta copiada al portapapeles.' : 'Answer copied to clipboard.';
  String get aiFollowUpSuggestionsTitle => isSpanish
      ? 'Preguntas sugeridas para continuar'
      : 'Suggested follow-up questions';
  String aiHistoryContextSummary(int caseCount, int documentCount) => isSpanish
      ? '$caseCount casos · $documentCount documentos'
      : '$caseCount cases · $documentCount documents';
  String aiConsultationReady(String groundingStatus) => isSpanish
      ? 'Consulta lista: ${aiGroundingStatus(groundingStatus)}.'
      : 'Consultation ready: ${aiGroundingStatus(groundingStatus)}.';
  String aiGroundingStatus(String value) {
    switch (value) {
      case 'GROUNDED':
        return isSpanish ? 'CON CONTEXTO' : 'GROUNDED';
      case 'PARTIAL':
        return isSpanish ? 'PARCIAL' : 'PARTIAL';
      case 'INSUFFICIENT_CONTEXT':
        return isSpanish ? 'CONTEXTO INSUFICIENTE' : 'INSUFFICIENT CONTEXT';
      default:
        return value;
    }
  }
  String aiQueryIdLabel(String value) =>
      isSpanish ? 'Consulta: $value' : 'Query: $value';
  String get aiSourceCaseTitle =>
      isSpanish ? 'Caso fuente' : 'Source case';
  String get aiSourceDocumentTitle =>
      isSpanish ? 'Documento fuente' : 'Source document';
  String get aiRecommendedNextStepsTitle =>
      isSpanish ? 'Siguientes pasos sugeridos' : 'Suggested next steps';
  String get aiFollowUpQuestionsTitle =>
      isSpanish ? 'Preguntas de seguimiento' : 'Follow-up questions';
  String get aiLimitationsTitle =>
      isSpanish ? 'Límites de esta respuesta' : 'Limits of this answer';
  String get aiUsedCasesTitle =>
      isSpanish ? 'Casos usados como contexto' : 'Cases used as context';
  String get aiUsedDocumentsTitle => isSpanish
      ? 'Documentos usados como contexto'
      : 'Documents used as context';
  String get aiNoContextCases => isSpanish
      ? 'No se usaron casos de contexto en esta respuesta.'
      : 'No context cases were used in this answer.';
  String get aiNoContextDocuments => isSpanish
      ? 'No se usaron documentos de contexto en esta respuesta.'
      : 'No context documents were used in this answer.';
  String aiContextRelation(String relation) {
    switch (relation) {
      case 'SOURCE_CASE':
        return isSpanish ? 'Caso fuente explícito' : 'Explicit source case';
      case 'SIMILAR_CASE':
        return isSpanish ? 'Caso similar recuperado' : 'Retrieved similar case';
      case 'SOURCE_DOCUMENT':
        return isSpanish
            ? 'Documento fuente explícito'
            : 'Explicit source document';
      case 'SIMILAR_DOCUMENT':
        return isSpanish
            ? 'Documento similar recuperado'
            : 'Retrieved similar document';
      default:
        return relation;
    }
  }
  String selectedCaseContextLabel(String internalCode) => isSpanish
      ? 'Caso: $internalCode'
      : 'Case: $internalCode';
  String selectedDocumentContextLabel(String documentName) => isSpanish
      ? 'Documento: $documentName'
      : 'Document: $documentName';
  String get aiOpenCaseAction =>
      isSpanish ? 'Abrir caso' : 'Open case';
  String get aiOpenDocumentsAction =>
      isSpanish ? 'Abrir documentos' : 'Open documents';
  String get analysisSummaryTitle =>
      isSpanish ? 'Resumen del caso' : 'Case summary';
  String get analysisHighlightsTitle =>
      isSpanish ? 'Hallazgos iniciales' : 'Initial findings';
  String get analysisLimitationsTitle =>
      isSpanish ? 'Limites actuales' : 'Current limits';
  String get analysisMatchesTitle =>
      isSpanish ? 'Coincidencias sugeridas' : 'Suggested matches';
  String get analysisNextStepsTitle =>
      isSpanish ? 'Siguientes pasos' : 'Next steps';
  String get analysisNoMatchesTitle =>
      isSpanish ? 'No hubo coincidencias fuertes' : 'No strong matches yet';
  String get analysisNoMatchesDescription => isSpanish
      ? 'Carga mas expedientes o mejora el detalle del asunto para enriquecer la busqueda futura.'
      : 'Add more case files or improve matter detail to enrich future search.';
  String get analysisOpenCaseAction =>
      isSpanish ? 'Abrir expediente' : 'Open case file';
  String get analysisOpenDocumentsAction =>
      isSpanish ? 'Abrir documentos del caso' : 'Open case documents';
  String get analysisSourceDocumentTitle =>
      isSpanish ? 'Documento fuente' : 'Source document';
  String get analysisDocumentMatchesTitle =>
      isSpanish ? 'Coincidencias de documentos' : 'Document matches';
  String get analysisNoDocumentMatchesTitle => isSpanish
      ? 'No hubo documentos relacionados fuertes'
      : 'No strong related documents yet';
  String get analysisNoDocumentMatchesDescription => isSpanish
      ? 'El análisis todavía no detectó documentos suficientemente cercanos en otros expedientes.'
      : 'The analysis did not surface strong enough related documents yet.';
  String analysisMatchedDocumentsCount(int count) => isSpanish
      ? 'Documentos coincidentes: $count'
      : 'Matched documents: $count';
  String get refreshAnalysisAction =>
      isSpanish ? 'Actualizar análisis' : 'Refresh analysis';
  String get analysisUnavailable => isSpanish
      ? 'El analisis no esta disponible ahora mismo.'
      : 'Analysis is not available right now.';
  String sizeBytes(int size) =>
      isSpanish ? 'Tamaño: $size bytes' : 'Size: $size bytes';
  String get removeSelection =>
      isSpanish ? 'Quitar selección' : 'Remove selection';
  String get uploading => isSpanish ? 'Subiendo...' : 'Uploading...';
  String get uploadDocument =>
      isSpanish ? 'Subir documento' : 'Upload document';
  String uploadedAt(String value) =>
      isSpanish ? 'Subido: $value' : 'Uploaded at: $value';
  String hashLabel(String value) => 'Hash: $value';

  String caseStatus(String status) {
    switch (status) {
      case 'OPEN':
        return isSpanish ? 'ABIERTO' : 'OPEN';
      case 'IN_PROGRESS':
        return isSpanish ? 'EN CURSO' : 'IN PROGRESS';
      case 'CLOSED':
        return isSpanish ? 'CERRADO' : 'CLOSED';
      case 'ARCHIVED':
        return isSpanish ? 'ARCHIVADO' : 'ARCHIVED';
      default:
        return status;
    }
  }

  String confidentialityLevel(String value) {
    switch (value) {
      case 'STANDARD':
        return isSpanish ? 'ESTÁNDAR' : 'STANDARD';
      case 'CONFIDENTIAL':
        return isSpanish ? 'CONFIDENCIAL' : 'CONFIDENTIAL';
      case 'HIGHLY_CONFIDENTIAL':
        return isSpanish ? 'ALTAMENTE CONFIDENCIAL' : 'HIGHLY CONFIDENTIAL';
      default:
        return value;
    }
  }

  String ocrStatus(String value) {
    switch (value) {
      case 'PENDING':
        return isSpanish ? 'PENDIENTE' : 'PENDING';
      case 'COMPLETED':
        return isSpanish ? 'COMPLETADO' : 'COMPLETED';
      case 'FAILED':
        return isSpanish ? 'FALLIDO' : 'FAILED';
      default:
        return value;
    }
  }

  String get noCaseFilesListDescription => isSpanish
      ? 'Crea tu primer caso para empezar a cargar documentos y analisis.'
      : 'Create your first case to start adding documents and analysis.';

  String get caseTitleLabel => isSpanish ? 'Titulo del caso' : 'Case title';
  String get caseTitleRequiredError => isSpanish
      ? 'El titulo del caso es obligatorio.'
      : 'Case title is required.';
  String get caseDescriptionLabel => isSpanish ? 'Descripcion' : 'Description';
  String get caseDescriptionHint => isSpanish
      ? 'Resume hechos, contexto y objetivo legal.'
      : 'Summarize facts, context and legal goal.';
  String get caseVisibilityLabel => isSpanish ? 'Visibilidad' : 'Visibility';
  String get knowledgeStatusLabel =>
      isSpanish ? 'Estado de conocimiento' : 'Knowledge status';
  String get knowledgeRepositoryTitle => isSpanish
      ? 'Repositorio colaborativo'
      : 'Collaborative repository';
  String get refreshKnowledgeRepository => isSpanish
      ? 'Actualizar repositorio'
      : 'Refresh repository';
  String get knowledgeRepositorySearchLabel => isSpanish
      ? 'Buscar casos publicados'
      : 'Search published cases';
  String get knowledgeRepositorySearchHint => isSpanish
      ? 'Escribe código, asunto o tipo de proceso'
      : 'Type an internal code, matter, or process type';
  String get knowledgeRepositoryEmptyTitle => isSpanish
      ? 'Aún no hay casos publicados'
      : 'No published cases yet';
  String get knowledgeRepositoryEmptyDescription => isSpanish
      ? 'Publica un expediente cerrado para iniciar la base de conocimiento compartida.'
      : 'Publish a closed case file to start the shared knowledge base.';
  String get knowledgeRepositoryPublishedBadge => isSpanish
      ? 'PUBLICADO'
      : 'PUBLISHED';
  String repositoryClosedOn(String value) => isSpanish
      ? 'Cerrado: $value'
      : 'Closed: $value';
  String repositoryPublishedOn(String value) => isSpanish
      ? 'Publicado: $value'
      : 'Published: $value';
  String get repositoryViewSummaryAction =>
      isSpanish ? 'Ver resumen' : 'View summary';
  String get openOwnedRepositoryCaseAction => isSpanish
      ? 'Abrir mi expediente'
      : 'Open my case file';
  String get repositorySharedCaseNotice => isSpanish
      ? 'Este caso ya forma parte del repositorio compartido y se muestra como referencia colaborativa.'
      : 'This case already belongs to the shared repository and is shown as collaborative reference.';
  String get knowledgeRepositorySectionTitle => isSpanish
      ? 'Repositorio colaborativo'
      : 'Collaborative repository';
  String get changeCaseStatusAction => isSpanish
      ? 'Cambiar estado'
      : 'Change status';
  String get changeCaseStatusDescription => isSpanish
      ? 'Selecciona el estado operativo actual del expediente.'
      : 'Select the current operational status for this case file.';
  String caseStatusUpdated(String status) => isSpanish
      ? 'Estado actualizado a $status.'
      : 'Status updated to $status.';
  String get caseStatusUpdateFailed => isSpanish
      ? 'No se pudo actualizar el estado del expediente.'
      : 'Could not update the case status.';
  String get publishCaseAction =>
      isSpanish ? 'Publicar caso' : 'Publish case';
  String get unpublishCaseAction => isSpanish
      ? 'Retirar del repositorio'
      : 'Remove from repository';
  String get closeCaseToPublishAction => isSpanish
      ? 'Cierra el caso para publicarlo'
      : 'Close the case before publishing';
  String get casePublishedToRepository => isSpanish
      ? 'Caso publicado en el repositorio colaborativo.'
      : 'Case published to the collaborative repository.';
  String get caseRemovedFromRepository => isSpanish
      ? 'Caso retirado del repositorio colaborativo.'
      : 'Case removed from the collaborative repository.';
  String get casePublicationFailed => isSpanish
      ? 'No se pudo publicar el caso ahora mismo.'
      : 'Could not publish the case right now.';
  String get caseUnpublishFailed => isSpanish
      ? 'No se pudo retirar el caso del repositorio.'
      : 'Could not remove the case from the repository.';
  String get caseAlreadyPublishedDescription => isSpanish
      ? 'Este expediente ya está visible dentro del repositorio colaborativo.'
      : 'This case file is already visible in the collaborative repository.';
  String casePublishedDescription(String date) => isSpanish
      ? 'Este expediente ya está publicado desde $date y puede seguir sirviendo como referencia compartida.'
      : 'This case file has been published since $date and can continue serving as shared reference.';
  String get caseEligibleForRepositoryDescription => isSpanish
      ? 'El expediente ya está cerrado y listo para publicarse como conocimiento compartido.'
      : 'This case file is closed and ready to be published as shared knowledge.';
  String get caseExcludedFromRepositoryDescription => isSpanish
      ? 'Este expediente quedó excluido del repositorio por su nivel de confidencialidad.'
      : 'This case file is excluded from the repository because of its confidentiality level.';
  String get caseNotReadyForRepositoryDescription => isSpanish
      ? 'Cierra o archiva el expediente para habilitar la publicación al repositorio.'
      : 'Close or archive the case file to enable repository publication.';

  String get contractMarketplaceTitle => isSpanish
      ? 'Marketplace de contratos'
      : 'Contract marketplace';
  String get refreshContractMarketplace => isSpanish
      ? 'Actualizar marketplace de contratos'
      : 'Refresh contract marketplace';
  String get openContractMarketplace => isSpanish
      ? 'Abrir marketplace de contratos'
      : 'Open contract marketplace';
  String get contractMarketplaceHeroTitle => isSpanish
      ? 'Plantillas listas para generar'
      : 'Templates ready to generate';
  String get contractMarketplaceHeroDescription => isSpanish
      ? 'Este MVP ya lista plantillas activas, abre formularios dinámicos y genera un PDF real. Cuando lleguen nuevas plantillas, solo habrá que cargar su schema.'
      : 'This MVP already lists active templates, opens dynamic forms, and generates a real PDF. When new templates arrive, we will only need to load their schema.';
  String get contractTemplatesSectionTitle => isSpanish
      ? 'Plantillas activas'
      : 'Active templates';
  String get contractTemplatesEmptyTitle => isSpanish
      ? 'No hay plantillas activas'
      : 'No active templates';
  String get contractTemplatesEmptyDescription => isSpanish
      ? 'El marketplace ya está listo; falta cargar las próximas plantillas.'
      : 'The marketplace is ready; upcoming templates still need to be loaded.';
  String get generatedContractsSectionTitle => isSpanish
      ? 'Contratos generados'
      : 'Generated contracts';
  String get noGeneratedContractsTitle => isSpanish
      ? 'Todavía no generaste contratos'
      : 'You have not generated contracts yet';
  String get noGeneratedContractsDescription => isSpanish
      ? 'Completa un formulario dinámico y aquí verás tus contratos listos para abrir.'
      : 'Complete a dynamic form and your ready-to-open contracts will show up here.';
  String get upcomingTemplatesTitle => isSpanish
      ? 'Próximas plantillas'
      : 'Upcoming templates';
  String get upcomingTemplatesDescription => isSpanish
      ? 'Dejamos el espacio preparado para que el equipo legal cargue nuevas plantillas sin rehacer el flujo.'
      : 'We left this area ready so the legal team can upload new templates without reworking the flow.';
  String get contractTemplatePendingUploadDescription => isSpanish
      ? 'Espacio listo para conectar la plantilla final apenas nos la compartan.'
      : 'This slot is ready to connect the final template as soon as the legal team shares it.';
  String get comingSoonLabel => isSpanish ? 'Próximamente' : 'Coming soon';
  String get openContractTemplateAction => isSpanish
      ? 'Abrir formulario'
      : 'Open form';
  String get openGeneratedContractAction => isSpanish
      ? 'Abrir PDF generado'
      : 'Open generated PDF';
  String contractFieldCountLabel(int count) => isSpanish
      ? '$count campos'
      : '$count fields';
  String contractGeneratedOn(String date) => isSpanish
      ? 'Generado: $date'
      : 'Generated: $date';
  String get contractTemplateFormTitle => isSpanish
      ? 'Formulario de contrato'
      : 'Contract form';
  String get contractTemplateUnavailable => isSpanish
      ? 'La plantilla de contrato no está disponible.'
      : 'This contract template is not available.';
  String get contractGenerateAction => isSpanish
      ? 'Generar contrato en PDF'
      : 'Generate PDF contract';
  String get contractGenerating => isSpanish
      ? 'Generando contrato...'
      : 'Generating contract...';
  String get contractGeneratedSuccess => isSpanish
      ? 'Contrato generado correctamente.'
      : 'Contract generated successfully.';
  String get contractPdfUnavailable => isSpanish
      ? 'El PDF del contrato no está disponible todavía.'
      : 'The contract PDF is not available yet.';
  String get contractSummarySectionTitle => isSpanish
      ? 'Resumen del contrato'
      : 'Contract summary';
  String get contractNotesSectionTitle => isSpanish
      ? 'Notas de la plantilla'
      : 'Template notes';
  String get contractSignaturesSectionTitle => isSpanish
      ? 'Firmas'
      : 'Signatures';
  String contractFieldRequired(String fieldLabel) => isSpanish
      ? '$fieldLabel es obligatorio.'
      : '$fieldLabel is required.';
  String get contractGeneralGroupLabel => isSpanish
      ? 'Información general'
      : 'General information';

  String caseVisibility(String value) {
    switch (value) {
      case 'PRIVATE':
        return isSpanish ? 'PRIVADO' : 'PRIVATE';
      case 'COMMUNITY':
        return isSpanish ? 'COMUNIDAD' : 'COMMUNITY';
      default:
        return value;
    }
  }

  String knowledgeStatus(String value) {
    switch (value) {
      case 'DRAFT':
        return isSpanish ? 'BORRADOR' : 'DRAFT';
      case 'ELIGIBLE':
        return isSpanish ? 'ELEGIBLE' : 'ELIGIBLE';
      case 'PUBLISHED':
        return isSpanish ? 'PUBLICADO' : 'PUBLISHED';
      case 'EXCLUDED':
        return isSpanish ? 'EXCLUIDO' : 'EXCLUDED';
      default:
        return value;
    }
  }

  String formatShortDate(DateTime value) {
    final monthNames = isSpanish
        ? const <int, String>{
            1: 'ene',
            2: 'feb',
            3: 'mar',
            4: 'abr',
            5: 'may',
            6: 'jun',
            7: 'jul',
            8: 'ago',
            9: 'sep',
            10: 'oct',
            11: 'nov',
            12: 'dic',
          }
        : const <int, String>{
            1: 'Jan',
            2: 'Feb',
            3: 'Mar',
            4: 'Apr',
            5: 'May',
            6: 'Jun',
            7: 'Jul',
            8: 'Aug',
            9: 'Sep',
            10: 'Oct',
            11: 'Nov',
            12: 'Dec',
          };

    final month = monthNames[value.month] ?? '${value.month}';
    final day = value.day.toString().padLeft(2, '0');

    return '$day $month ${value.year}';
  }

  String formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '${value.year}-$month-$day $hour:$minute';
  }

  String languageName(AppLanguage value) {
    switch (value) {
      case AppLanguage.english:
        return englishLabel;
      case AppLanguage.spanish:
        return spanishLabel;
    }
  }
}
