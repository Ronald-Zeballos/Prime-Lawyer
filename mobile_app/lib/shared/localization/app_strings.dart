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
      ? 'Configura a que backend local se conectara la app.'
      : 'Set which local backend the app should connect to.';
  String get apiBaseUrlHint => 'http://192.168.1.20:3000/api/v1';
  String get editApiBaseUrl =>
      isSpanish ? 'Editar URL de API' : 'Edit API URL';
  String get saveApiBaseUrl =>
      isSpanish ? 'Guardar URL' : 'Save URL';
  String get testApiConnection =>
      isSpanish ? 'Probar conexion' : 'Test connection';
  String get resetApiBaseUrl =>
      isSpanish ? 'Usar URL por defecto' : 'Use default URL';
  String get apiBaseUrlSaved => isSpanish
      ? 'URL de API actualizada.'
      : 'API URL updated.';
  String get apiBaseUrlReset => isSpanish
      ? 'Se restauro la URL por defecto.'
      : 'Default API URL restored.';
  String get apiBaseUrlRequiredError => isSpanish
      ? 'La URL base de API es obligatoria.'
      : 'API base URL is required.';
  String get apiBaseUrlInvalidError => isSpanish
      ? 'La URL base de API no es valida.'
      : 'API base URL is invalid.';
  String get realDeviceApiHint => isSpanish
      ? 'En telefono real no uses 10.0.2.2. Usa la IP local de tu computadora en la misma red Wi-Fi.'
      : 'On a physical phone do not use 10.0.2.2. Use your computer local IP on the same Wi-Fi network.';
  String get apiConnectionSuccess => isSpanish
      ? 'Conexion con la API correcta.'
      : 'API connection is working.';
  String get apiConnectionFailure => isSpanish
      ? 'No se pudo conectar con la API.'
      : 'Could not connect to the API.';
  String get settingsTitle => isSpanish ? 'Configuración' : 'Settings';
  String get languageTitle => isSpanish ? 'Idioma' : 'Language';
  String get languageDescription => isSpanish
      ? 'Cambia el idioma visible de la app para la demo.'
      : 'Change the visible language of the app for the demo.';
  String get englishLabel => 'English';
  String get spanishLabel => 'Español';
  String get accountTitle => isSpanish ? 'Cuenta' : 'Account';
  String get notSignedInYet => isSpanish
      ? 'Todavía no iniciaste sesión.'
      : 'You are not signed in yet.';
  String signedInAs(String fullName, String role) => isSpanish
      ? 'Sesión iniciada como $fullName ($role).'
      : 'Signed in as $fullName ($role).';
  String get passwordChangeComingSoon => isSpanish
      ? 'Cambio de contraseña: llegará en una siguiente fase.'
      : 'Password change: coming in a later phase.';
  String get signOut => isSpanish ? 'Cerrar sesión' : 'Sign out';
  String get openSettings => isSpanish ? 'Abrir configuración' : 'Open settings';
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
  String resumeCaseFile(String internalCode) => isSpanish
      ? 'Continuar $internalCode'
      : 'Resume $internalCode';
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
  String get settingsActionTitle =>
      isSpanish ? 'Preferencias' : 'Preferences';
  String get settingsActionDescription => isSpanish
      ? 'Idioma, sesion y opciones de la demo.'
      : 'Language, session and demo options.';
  String get openRecentDocumentsTitle =>
      isSpanish ? 'Documentos' : 'Documents';
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
  String get noUserRoleFallback =>
      isSpanish ? 'Equipo legal' : 'Legal team';
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
  String get createClientTitle =>
      isSpanish ? 'Crear cliente' : 'Create client';
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
  String get newCaseFile =>
      isSpanish ? 'Nuevo expediente' : 'New case file';
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
  String get processTypeLabel =>
      isSpanish ? 'Tipo de proceso' : 'Process type';
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
  String get notClosedYet => isSpanish ? 'Sin cierre' : 'Not closed';
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
  String get selectedDocumentTitle => isSpanish
      ? 'Documento listo para subir'
      : 'Document ready to upload';
  String get openPdfAction => isSpanish ? 'Abrir PDF' : 'Open PDF';
  String get pdfOnlyLabel => isSpanish ? 'Solo PDF' : 'PDF only';
  String get analyzeDocument =>
      isSpanish ? 'Analizar documento' : 'Analyze document';
  String get analysisPreviewTitle =>
      isSpanish ? 'Analisis juridico' : 'Legal analysis';
  String get analysisPreviewBadge =>
      isSpanish ? 'Preview IA' : 'AI preview';
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
      ? 'En una fase posterior leer OCR y usar OpenAI para analisis semantico real.'
      : 'In a later phase it will read OCR text and use OpenAI for real semantic analysis.';
  String get analysisPreviewContinueAction => isSpanish
      ? 'Abrir preview de analisis'
      : 'Open analysis preview';
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
  String get analysisNoMatchesTitle => isSpanish
      ? 'No hubo coincidencias fuertes'
      : 'No strong matches yet';
  String get analysisNoMatchesDescription => isSpanish
      ? 'Carga mas expedientes o mejora el detalle del asunto para enriquecer la busqueda futura.'
      : 'Add more case files or improve matter detail to enrich future search.';
  String get analysisOpenCaseAction =>
      isSpanish ? 'Abrir expediente' : 'Open case file';
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
