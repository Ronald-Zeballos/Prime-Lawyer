import { Injectable } from '@nestjs/common';
import {
  BuildContextualLegalAnswerCommand,
  ContextualLegalAnswerBuilder,
} from '../../application/ports/contextual-legal-answer-builder.port';
import {
  ContextualLegalAnswerDraftDto,
  ContextualLegalAnswerLanguage,
  ContextualLegalGroundingStatus,
} from '../../application/dto/contextual-legal-answer.dto';

@Injectable()
export class HeuristicContextualLegalAnswerBuilderService
  implements ContextualLegalAnswerBuilder
{
  build(
    command: BuildContextualLegalAnswerCommand,
  ): ContextualLegalAnswerDraftDto {
    const language = this.detectLanguage(command.question);
    const contextStrength = this.resolveGroundingStatus(command);

    if (contextStrength === 'INSUFFICIENT_CONTEXT') {
      return this.buildInsufficientContextResponse(language);
    }

    const themes = this.extractThemes(command);
    const processType =
      command.sourceCaseFile?.processType ??
      command.retrieval.caseMatches[0]?.processType ??
      command.retrieval.documentMatches[0]?.processType ??
      null;
    const strongestCase = command.usedContextCases[0] ?? null;
    const strongestDocument = command.usedContextDocuments[0] ?? null;
    const answer = language === 'es'
      ? this.buildSpanishAnswer(
          command,
          contextStrength,
          processType,
          themes,
          strongestCase?.title ?? null,
          strongestDocument?.originalName ?? null,
        )
      : this.buildEnglishAnswer(
          command,
          contextStrength,
          processType,
          themes,
          strongestCase?.title ?? null,
          strongestDocument?.originalName ?? null,
        );

    return {
      language,
      groundingStatus: contextStrength,
      answer,
      disclaimer: language === 'es'
        ? 'Respuesta MVP acotada solo al contexto recuperado. No agrega hechos ni conclusiones fuera de los casos y documentos encontrados.'
        : 'MVP response limited strictly to the recovered context. It does not add facts or conclusions beyond the matched cases and documents.',
      limitations: language === 'es'
        ? this.buildSpanishLimitations(command, contextStrength)
        : this.buildEnglishLimitations(command, contextStrength),
      recommendedNextSteps: language === 'es'
        ? this.buildSpanishNextSteps(command, processType, themes)
        : this.buildEnglishNextSteps(command, processType, themes),
      followUpQuestions: language === 'es'
        ? this.buildSpanishFollowUps(command, processType)
        : this.buildEnglishFollowUps(command, processType),
    };
  }

  private buildInsufficientContextResponse(
    language: ContextualLegalAnswerLanguage,
  ): ContextualLegalAnswerDraftDto {
    return language === 'es'
      ? {
          language,
          groundingStatus: 'INSUFFICIENT_CONTEXT',
          answer:
            'No pude responder con contexto real porque la busqueda no encontro casos o documentos suficientemente relacionados. Para esta etapa del MVP, la consulta legal solo responde con evidencia recuperada.',
          disclaimer:
            'La respuesta queda bloqueada por falta de contexto recuperado.',
          limitations: [
            'No se recuperaron coincidencias fuertes para sustentar una respuesta.',
            'La pregunta necesita mas detalle legal, un caso fuente o un documento fuente.',
          ],
          recommendedNextSteps: [
            'Indica un caseFileId o documentId como contexto principal.',
            'Usa terminos mas especificos del proceso, hecho o documento.',
            'Sube o reprocesa documentos para que el OCR aporte texto buscable.',
          ],
          followUpQuestions: [
            'Que caso del usuario deberia usarse como contexto principal?',
            'Que documento contiene los hechos o clausulas clave?',
            'Cual es el tipo de proceso que quieres consultar?',
          ],
        }
      : {
          language,
          groundingStatus: 'INSUFFICIENT_CONTEXT',
          answer:
            'I could not provide a grounded legal answer because the search did not recover sufficiently related cases or documents. At this MVP stage, legal consultation only answers from retrieved evidence.',
          disclaimer:
            'The response is intentionally blocked when contextual retrieval is too weak.',
          limitations: [
            'No strong matches were recovered to support a response.',
            'The question needs more legal detail, a source case, or a source document.',
          ],
          recommendedNextSteps: [
            'Provide a caseFileId or documentId as the primary context.',
            'Use more specific terms for the process, facts, or document type.',
            'Upload or reprocess documents so OCR adds searchable text.',
          ],
          followUpQuestions: [
            'Which user case should be used as the primary context?',
            'Which document contains the key facts or clauses?',
            'What process type should guide the consultation?',
          ],
        };
  }

  private resolveGroundingStatus(
    command: BuildContextualLegalAnswerCommand,
  ): ContextualLegalGroundingStatus {
    if (
      !command.sourceCaseFile &&
      !command.sourceDocument &&
      command.usedContextCases.length === 0 &&
      command.usedContextDocuments.length === 0
    ) {
      return 'INSUFFICIENT_CONTEXT';
    }

    const strongestRetrievedScore = Math.max(
      command.retrieval.caseMatches[0]?.score ?? 0,
      command.retrieval.documentMatches[0]?.score ?? 0,
    );

    if (
      command.sourceCaseFile ||
      command.sourceDocument ||
      strongestRetrievedScore >= 55
    ) {
      return 'GROUNDED';
    }

    if (strongestRetrievedScore >= 24) {
      return 'PARTIAL';
    }

    return 'INSUFFICIENT_CONTEXT';
  }

  private buildSpanishAnswer(
    command: BuildContextualLegalAnswerCommand,
    groundingStatus: ContextualLegalGroundingStatus,
    processType: string | null,
    themes: string[],
    strongestCaseTitle: string | null,
    strongestDocumentName: string | null,
  ): string {
    const themeSentence = themes.length > 0
      ? `Los temas que mas se repiten en el contexto recuperado son: ${themes.join(', ')}.`
      : 'El contexto recuperado no aporta suficientes temas repetidos como para ampliar mas la respuesta.';
    const processSentence = processType
      ? `El proceso dominante en las coincidencias recuperadas es ${processType}.`
      : 'No se pudo fijar un tipo de proceso dominante con la evidencia recuperada.';
    const sourceSentence = command.sourceCaseFile
      ? `El caso fuente es ${command.sourceCaseFile.internalCode} - ${command.sourceCaseFile.title}.`
      : strongestCaseTitle
        ? `La coincidencia principal proviene del caso "${strongestCaseTitle}".`
        : 'No hubo un caso fuente explicito en la consulta.';
    const documentSentence = strongestDocumentName
      ? `El documento mas util como apoyo fue "${strongestDocumentName}".`
      : 'No hubo un documento con peso suficiente para ampliar la respuesta.';
    const cautionSentence = groundingStatus === 'PARTIAL'
      ? 'La base recuperada es util pero todavia parcial, asi que conviene tratar esta salida como orientacion inicial.'
      : 'La respuesta se mantiene estrictamente dentro de los hechos y patrones visibles en los casos y documentos recuperados.';

    return [
      `Segun el contexto recuperado, la pregunta se relaciona principalmente con ${processType ?? 'el conjunto de casos coincidentes'} y no con conocimiento inventado fuera del repositorio.`,
      sourceSentence,
      processSentence,
      themeSentence,
      documentSentence,
      cautionSentence,
    ].join(' ');
  }

  private buildEnglishAnswer(
    command: BuildContextualLegalAnswerCommand,
    groundingStatus: ContextualLegalGroundingStatus,
    processType: string | null,
    themes: string[],
    strongestCaseTitle: string | null,
    strongestDocumentName: string | null,
  ): string {
    const themeSentence = themes.length > 0
      ? `The recurring themes in the recovered context are: ${themes.join(', ')}.`
      : 'The recovered context did not produce enough recurring themes to expand the answer further.';
    const processSentence = processType
      ? `The dominant process type across the retrieved matches is ${processType}.`
      : 'No dominant process type could be established from the recovered evidence.';
    const sourceSentence = command.sourceCaseFile
      ? `The source case is ${command.sourceCaseFile.internalCode} - ${command.sourceCaseFile.title}.`
      : strongestCaseTitle
        ? `The strongest match comes from the case "${strongestCaseTitle}".`
        : 'No explicit source case was provided for the consultation.';
    const documentSentence = strongestDocumentName
      ? `The most helpful supporting document was "${strongestDocumentName}".`
      : 'No document carried enough weight to expand the answer.';
    const cautionSentence = groundingStatus === 'PARTIAL'
      ? 'The recovered base is helpful but still partial, so this should be treated as an initial orientation.'
      : 'The answer stays strictly inside the facts and patterns visible in the recovered cases and documents.';

    return [
      `Based on the recovered context, the question aligns mainly with ${processType ?? 'the matched case set'} and not with unsupported legal invention.`,
      sourceSentence,
      processSentence,
      themeSentence,
      documentSentence,
      cautionSentence,
    ].join(' ');
  }

  private buildSpanishLimitations(
    command: BuildContextualLegalAnswerCommand,
    groundingStatus: ContextualLegalGroundingStatus,
  ): string[] {
    const limitations = [
      'La respuesta usa recuperacion heuristica por metadata, OCR y señales basicas; todavia no usa embeddings.',
      'Los documentos se citan por coincidencia recuperada, no por interpretacion juridica exhaustiva.',
    ];

    if (!command.sourceCaseFile && !command.sourceDocument) {
      limitations.push(
        'La consulta no incluyo un caso o documento fuente, asi que depende solo de similitud recuperada.',
      );
    }

    if (groundingStatus === 'PARTIAL') {
      limitations.push(
        'Las coincidencias encontradas son utiles pero no lo bastante fuertes como para tomar esta salida como criterio final.',
      );
    }

    return limitations;
  }

  private buildEnglishLimitations(
    command: BuildContextualLegalAnswerCommand,
    groundingStatus: ContextualLegalGroundingStatus,
  ): string[] {
    const limitations = [
      'The response uses heuristic retrieval from metadata, OCR text, and basic signals; it does not use embeddings yet.',
      'Documents are cited through recovered similarity, not through exhaustive legal interpretation.',
    ];

    if (!command.sourceCaseFile && !command.sourceDocument) {
      limitations.push(
        'No source case or document was provided, so the answer depends only on recovered similarity.',
      );
    }

    if (groundingStatus === 'PARTIAL') {
      limitations.push(
        'The matches are helpful but not strong enough to treat this output as a final legal criterion.',
      );
    }

    return limitations;
  }

  private buildSpanishNextSteps(
    command: BuildContextualLegalAnswerCommand,
    processType: string | null,
    themes: string[],
  ): string[] {
    const nextSteps = [
      'Revisa primero los casos y documentos citados en usedContextCases y usedContextDocuments.',
      'Si esta consulta corresponde a un caso activo, vuelve a ejecutarla indicando caseFileId o documentId para anclar mejor el contexto.',
    ];

    if (this.matchesAny(themes, ['alquiler', 'arrendamiento', 'renta', 'desalojo'])) {
      nextSteps.push(
        'Contrasta contrato, comprobantes de pago y comunicaciones de mora antes de decidir la siguiente accion.',
      );
    } else if (this.matchesAny(themes, ['despido', 'laboral', 'beneficios'])) {
      nextSteps.push(
        'Ordena contrato laboral, carta de despido y boletas de pago para reforzar la comparacion contextual.',
      );
    } else if (processType) {
      nextSteps.push(
        `Ordena la evidencia principal y la cronologia del proceso ${processType} para mejorar la siguiente consulta.`,
      );
    }

    return nextSteps;
  }

  private buildEnglishNextSteps(
    command: BuildContextualLegalAnswerCommand,
    processType: string | null,
    themes: string[],
  ): string[] {
    const nextSteps = [
      'Review the cases and documents cited in usedContextCases and usedContextDocuments first.',
      'If this consultation belongs to an active case, run it again with caseFileId or documentId to anchor the context more precisely.',
    ];

    if (this.matchesAny(themes, ['lease', 'rent', 'eviction', 'arrendamiento', 'alquiler'])) {
      nextSteps.push(
        'Compare the lease, payment evidence, and default notices before choosing the next action.',
      );
    } else if (this.matchesAny(themes, ['dismissal', 'laboral', 'despido', 'benefits'])) {
      nextSteps.push(
        'Organize the employment contract, termination notice, and payroll evidence to strengthen the contextual comparison.',
      );
    } else if (processType) {
      nextSteps.push(
        `Organize the main evidence and timeline for the ${processType} process before the next consultation.`,
      );
    }

    return nextSteps;
  }

  private buildSpanishFollowUps(
    command: BuildContextualLegalAnswerCommand,
    processType: string | null,
  ): string[] {
    const followUps = [
      'Que hechos del caso actual coinciden exactamente con las coincidencias recuperadas?',
      'Que documento deberia abrirse o reprocesarse para mejorar el contexto?',
    ];

    if (!command.sourceCaseFile) {
      followUps.push('Que caseFileId deberia quedar fijado como contexto principal?');
    }

    if (!processType) {
      followUps.push('Cual es el tipo de proceso mas cercano para filtrar mejor la busqueda?');
    }

    return followUps.slice(0, 3);
  }

  private buildEnglishFollowUps(
    command: BuildContextualLegalAnswerCommand,
    processType: string | null,
  ): string[] {
    const followUps = [
      'Which facts from the current matter match the recovered context exactly?',
      'Which document should be opened or reprocessed to improve grounding?',
    ];

    if (!command.sourceCaseFile) {
      followUps.push('Which caseFileId should become the primary context?');
    }

    if (!processType) {
      followUps.push('What is the closest process type to narrow the search better?');
    }

    return followUps.slice(0, 3);
  }

  private extractThemes(command: BuildContextualLegalAnswerCommand): string[] {
    const counts = new Map<string, number>();
    const corpus = [
      command.question,
      command.sourceCaseFile?.title ?? '',
      command.sourceCaseFile?.descriptionSnippet ?? '',
      command.sourceDocument?.originalName ?? '',
      command.sourceDocument?.snippet ?? '',
      ...command.usedContextCases.map(
        (contextCase) => `${contextCase.title} ${contextCase.snippet ?? ''}`,
      ),
      ...command.usedContextDocuments.map(
        (contextDocument) =>
          `${contextDocument.originalName} ${contextDocument.snippet ?? ''}`,
      ),
    ].join(' ');

    for (const token of this.tokenize(corpus)) {
      counts.set(token, (counts.get(token) ?? 0) + 1);
    }

    return [...counts.entries()]
      .sort((left, right) => right[1] - left[1] || left[0].localeCompare(right[0]))
      .slice(0, 5)
      .map(([token]) => token);
  }

  private tokenize(value: string): string[] {
    const stopWords = new Set([
      'the',
      'and',
      'for',
      'with',
      'from',
      'that',
      'this',
      'into',
      'case',
      'document',
      'source',
      'explicit',
      'consultation',
      'provided',
      'same',
      'open',
      'private',
      'draft',
      'para',
      'con',
      'por',
      'del',
      'las',
      'los',
      'una',
      'uno',
      'que',
      'como',
      'caso',
      'documento',
      'fuente',
      'explicito',
      'consulta',
      'sobre',
      'proceso',
      'legal',
      'mvp',
      'ocr',
    ]);

    return value
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9\s]/g, ' ')
      .split(/\s+/)
      .map((token) => token.trim())
      .filter(
        (token) =>
          token.length >= 4 &&
          !stopWords.has(token) &&
          !/\d/.test(token),
      );
  }

  private detectLanguage(
    question: string,
  ): ContextualLegalAnswerLanguage {
    const normalizedQuestion = ` ${question.toLowerCase()} `;
    const spanishSignals = [
      ' que ',
      ' como ',
      ' contrato',
      ' alquiler',
      ' despido',
      ' documento',
      ' caso',
      ' puedo',
      ' debo',
      ' civil',
      ' laboral',
      ' consulta',
    ];

    return spanishSignals.some((signal) => normalizedQuestion.includes(signal))
      ? 'es'
      : 'en';
  }

  private matchesAny(tokens: string[], candidates: string[]): boolean {
    return candidates.some((candidate) => tokens.includes(candidate));
  }
}
