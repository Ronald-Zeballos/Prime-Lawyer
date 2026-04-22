import { createHash, randomUUID, scryptSync } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { PDFDocument, StandardFonts } from 'pdf-lib';
import {
  CaseStatus,
  CaseVisibility,
  ConfidentialityLevel,
  ContractTemplate,
  DocumentSource,
  KnowledgeStatus,
  OCRStatus,
  PlanType,
  PrismaClient,
  UserRole,
  UserType,
} from '@prisma/client';

const prisma = new PrismaClient();

function hashPassword(password: string): string {
  const salt = 'prime-lawyer-demo-salt';
  const derivedKey = scryptSync(password, salt, 64).toString('hex');

  return `scrypt:${salt}:${derivedKey}`;
}

async function seedRoles(): Promise<void> {
  await prisma.role.upsert({
    where: { code: UserRole.NATURAL },
    update: { name: 'Natural User' },
    create: {
      id: randomUUID(),
      code: UserRole.NATURAL,
      name: 'Natural User',
    },
  });

  await prisma.role.upsert({
    where: { code: UserRole.ADMIN },
    update: { name: 'Administrator' },
    create: {
      id: randomUUID(),
      code: UserRole.ADMIN,
      name: 'Administrator',
    },
  });

  await prisma.role.upsert({
    where: { code: UserRole.LAWYER },
    update: { name: 'Lawyer' },
    create: {
      id: randomUUID(),
      code: UserRole.LAWYER,
      name: 'Lawyer',
    },
  });
}

async function seedUsers(): Promise<{
  adminUserId: string;
  lawyerUserId: string;
  naturalUserId: string;
}> {
  const adminRole = await prisma.role.findUniqueOrThrow({
    where: { code: UserRole.ADMIN },
  });
  const lawyerRole = await prisma.role.findUniqueOrThrow({
    where: { code: UserRole.LAWYER },
  });
  const naturalRole = await prisma.role.findUniqueOrThrow({
    where: { code: UserRole.NATURAL },
  });

  const adminUser = await prisma.user.upsert({
    where: { email: 'admin@demo.com' },
    update: {
      displayName: 'Prime Lawyer Admin',
      firstName: 'Demo',
      lastName: 'Admin',
      roleId: adminRole.id,
      type: UserType.ADMIN,
      plan: PlanType.ADMIN,
      tokensAvailable: 1000,
      isActive: true,
      passwordHash: hashPassword('Admin123*'),
    },
    create: {
      id: randomUUID(),
      email: 'admin@demo.com',
      displayName: 'Prime Lawyer Admin',
      firstName: 'Demo',
      lastName: 'Admin',
      roleId: adminRole.id,
      type: UserType.ADMIN,
      plan: PlanType.ADMIN,
      tokensAvailable: 1000,
      isActive: true,
      passwordHash: hashPassword('Admin123*'),
    },
  });
  const lawyerUser = await prisma.user.upsert({
    where: { email: 'lawyer@demo.com' },
    update: {
      displayName: 'Demo Lawyer',
      firstName: 'Demo',
      lastName: 'Lawyer',
      roleId: lawyerRole.id,
      type: UserType.LAWYER,
      plan: PlanType.LAWYER_PRO,
      tokensAvailable: 250,
      isActive: true,
      passwordHash: hashPassword('Lawyer123*'),
    },
    create: {
      id: randomUUID(),
      email: 'lawyer@demo.com',
      displayName: 'Demo Lawyer',
      firstName: 'Demo',
      lastName: 'Lawyer',
      roleId: lawyerRole.id,
      type: UserType.LAWYER,
      plan: PlanType.LAWYER_PRO,
      tokensAvailable: 250,
      isActive: true,
      passwordHash: hashPassword('Lawyer123*'),
    },
  });
  const naturalUser = await prisma.user.upsert({
    where: { email: 'user@demo.com' },
    update: {
      displayName: 'Demo User',
      firstName: 'Demo',
      lastName: 'User',
      roleId: naturalRole.id,
      type: UserType.NATURAL,
      plan: PlanType.FREE,
      tokensAvailable: 10,
      isActive: true,
      passwordHash: hashPassword('User123*'),
    },
    create: {
      id: randomUUID(),
      email: 'user@demo.com',
      displayName: 'Demo User',
      firstName: 'Demo',
      lastName: 'User',
      roleId: naturalRole.id,
      type: UserType.NATURAL,
      plan: PlanType.FREE,
      tokensAvailable: 10,
      isActive: true,
      passwordHash: hashPassword('User123*'),
    },
  });

  return {
    adminUserId: adminUser.id,
    lawyerUserId: lawyerUser.id,
    naturalUserId: naturalUser.id,
  };
}

type DemoClientSeed = {
  documentNumber: string;
  firstName: string;
  lastName: string;
  phone: string;
  email: string;
  address: string;
  notes: string;
};

async function seedClients(): Promise<Map<string, string>> {
  const demoClients: DemoClientSeed[] = [
    {
      documentNumber: 'CI-900001',
      firstName: 'Carla',
      lastName: 'Mendoza',
      phone: '+59170010001',
      email: 'carla.mendoza@demo.com',
      address: 'Av. Arce 1820, La Paz',
      notes: 'Propietaria con varios contratos de alquiler vigentes.',
    },
    {
      documentNumber: 'CI-900002',
      firstName: 'Luis',
      lastName: 'Rojas',
      phone: '+59170010002',
      email: 'luis.rojas@demo.com',
      address: 'Calle Aroma 455, Cochabamba',
      notes: 'Cliente laboral con historial de reclamos salariales.',
    },
    {
      documentNumber: 'CI-900003',
      firstName: 'Mariela',
      lastName: 'Suarez',
      phone: '+59170010003',
      email: 'mariela.suarez@demo.com',
      address: 'Zona Equipetrol, Santa Cruz',
      notes: 'Emprendedora con contratos de prestación de servicios.',
    },
    {
      documentNumber: 'CI-900004',
      firstName: 'Jorge',
      lastName: 'Quispe',
      phone: '+59170010004',
      email: 'jorge.quispe@demo.com',
      address: 'Av. Blanco Galindo km 6, Cochabamba',
      notes: 'Cliente con conflicto de cobro ejecutivo.',
    },
    {
      documentNumber: 'CI-900005',
      firstName: 'Ana',
      lastName: 'Paredes',
      phone: '+59170010005',
      email: 'ana.paredes@demo.com',
      address: 'Calle Junin 918, Sucre',
      notes: 'Consulta familiar reservada y altamente sensible.',
    },
  ];
  const clientIds = new Map<string, string>();

  for (const client of demoClients) {
    const savedClient = await prisma.client.upsert({
      where: { documentNumber: client.documentNumber },
      update: {
        firstName: client.firstName,
        lastName: client.lastName,
        phone: client.phone,
        email: client.email,
        address: client.address,
        notes: client.notes,
      },
      create: {
        id: randomUUID(),
        firstName: client.firstName,
        lastName: client.lastName,
        documentNumber: client.documentNumber,
        phone: client.phone,
        email: client.email,
        address: client.address,
        notes: client.notes,
      },
    });

    clientIds.set(client.documentNumber, savedClient.id);
  }

  return clientIds;
}

type DemoCaseSeed = {
  internalCode: string;
  clientDocumentNumber: string;
  title: string;
  subject: string;
  description: string;
  processType: string;
  status: CaseStatus;
  confidentialityLevel: ConfidentialityLevel;
  visibility: CaseVisibility;
  knowledgeStatus: KnowledgeStatus;
  openedAt: Date;
  closedAt: Date | null;
  publishedAt: Date | null;
  documentOriginalName: string;
  documentBody: string[];
};

async function seedCaseFilesAndDocuments(params: {
  adminUserId: string;
  clientIds: Map<string, string>;
}): Promise<void> {
  const now = new Date();
  const demoCases: DemoCaseSeed[] = [
    {
      internalCode: 'ARR-2026-001',
      clientDocumentNumber: 'CI-900001',
      title: 'Incumplimiento de alquiler comercial',
      subject: 'Cobro de alquiler adeudado',
      description:
        'El arrendatario acumula tres meses de mora y se solicita estrategia de recuperación y resolución contractual.',
      processType: 'incumplimiento de contrato de alquiler',
      status: CaseStatus.OPEN,
      confidentialityLevel: ConfidentialityLevel.STANDARD,
      visibility: CaseVisibility.PRIVATE,
      knowledgeStatus: KnowledgeStatus.DRAFT,
      openedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 4),
      closedAt: null,
      publishedAt: null,
      documentOriginalName: 'requerimiento_pago_alquiler.pdf',
      documentBody: [
        'Requerimiento extrajudicial de pago por alquiler adeudado.',
        'Se deja constancia de tres mensualidades impagas y de la cláusula de resolución.',
        'El arrendador solicita pago inmediato o entrega del inmueble.',
      ],
    },
    {
      internalCode: 'ARR-2026-002',
      clientDocumentNumber: 'CI-900001',
      title: 'Cierre exitoso de desalojo voluntario',
      subject: 'Desalojo y entrega de inmueble',
      description:
        'Caso cerrado con acuerdo de entrega voluntaria después de notificación y negociación final.',
      processType: 'desalojo por incumplimiento de alquiler',
      status: CaseStatus.CLOSED,
      confidentialityLevel: ConfidentialityLevel.STANDARD,
      visibility: CaseVisibility.COMMUNITY,
      knowledgeStatus: KnowledgeStatus.PUBLISHED,
      openedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 26),
      closedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 11),
      publishedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 9),
      documentOriginalName: 'acuerdo_entrega_inmueble.pdf',
      documentBody: [
        'Acuerdo final de entrega voluntaria del inmueble arrendado.',
        'Se documenta cronograma de entrega de llaves y liquidación de deudas.',
        'El expediente quedó cerrado y publicado como referencia colaborativa.',
      ],
    },
    {
      internalCode: 'LAB-2026-003',
      clientDocumentNumber: 'CI-900002',
      title: 'Reclamo por beneficios sociales pendientes',
      subject: 'Demanda laboral por pago de beneficios',
      description:
        'Se prepara demanda por beneficios sociales y salarios devengados tras despido sin preaviso.',
      processType: 'reclamo laboral por beneficios sociales',
      status: CaseStatus.IN_PROGRESS,
      confidentialityLevel: ConfidentialityLevel.CONFIDENTIAL,
      visibility: CaseVisibility.PRIVATE,
      knowledgeStatus: KnowledgeStatus.DRAFT,
      openedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 8),
      closedAt: null,
      publishedAt: null,
      documentOriginalName: 'liquidacion_observada_beneficios.pdf',
      documentBody: [
        'Observación formal a la liquidación de beneficios sociales.',
        'Se cuestiona el cálculo de indemnización, aguinaldo y vacaciones.',
        'El trabajador solicita reliquidación y pago íntegro.',
      ],
    },
    {
      internalCode: 'COM-2026-004',
      clientDocumentNumber: 'CI-900004',
      title: 'Cobro ejecutivo cerrado por acuerdo',
      subject: 'Cobro de factura y reconocimiento de deuda',
      description:
        'Proceso archivado tras pago total y reconocimiento de deuda firmado.',
      processType: 'cobro ejecutivo mercantil',
      status: CaseStatus.ARCHIVED,
      confidentialityLevel: ConfidentialityLevel.STANDARD,
      visibility: CaseVisibility.COMMUNITY,
      knowledgeStatus: KnowledgeStatus.PUBLISHED,
      openedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 42),
      closedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 18),
      publishedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 16),
      documentOriginalName: 'reconocimiento_deuda_pagada.pdf',
      documentBody: [
        'Acta de reconocimiento de deuda y plan de pago cumplido.',
        'La contraparte pagó capital, intereses y costos antes de audiencia final.',
        'El caso quedó archivado y reutilizable para análisis de cobro ejecutivo.',
      ],
    },
    {
      internalCode: 'FAM-2026-005',
      clientDocumentNumber: 'CI-900005',
      title: 'Consulta reservada de acuerdo familiar',
      subject: 'Negociación privada de acuerdo de guarda',
      description:
        'Materia altamente confidencial con antecedentes familiares sensibles.',
      processType: 'acuerdo familiar de guarda',
      status: CaseStatus.CLOSED,
      confidentialityLevel: ConfidentialityLevel.HIGHLY_CONFIDENTIAL,
      visibility: CaseVisibility.PRIVATE,
      knowledgeStatus: KnowledgeStatus.EXCLUDED,
      openedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 15),
      closedAt: new Date(now.getTime() - 1000 * 60 * 60 * 24 * 5),
      publishedAt: null,
      documentOriginalName: 'borrador_acuerdo_familiar.pdf',
      documentBody: [
        'Borrador de acuerdo familiar con condiciones de guarda y visitas.',
        'Documento altamente sensible excluido del repositorio colaborativo.',
        'Se protege identidad y detalles personales de menores involucrados.',
      ],
    },
  ];

  for (const demoCase of demoCases) {
    const clientId = params.clientIds.get(demoCase.clientDocumentNumber);

    if (!clientId) {
      throw new Error(`Client ${demoCase.clientDocumentNumber} was not seeded.`);
    }

    const caseFile = await prisma.caseFile.upsert({
      where: { internalCode: demoCase.internalCode },
      update: {
        clientId,
        ownerUserId: params.adminUserId,
        title: demoCase.title,
        subject: demoCase.subject,
        description: demoCase.description,
        processType: demoCase.processType,
        status: demoCase.status,
        openedAt: demoCase.openedAt,
        closedAt: demoCase.closedAt,
        visibility: demoCase.visibility,
        knowledgeStatus: demoCase.knowledgeStatus,
        publishedAt: demoCase.publishedAt,
        confidentialityLevel: demoCase.confidentialityLevel,
        searchText: buildCaseSearchText(demoCase),
      },
      create: {
        id: randomUUID(),
        internalCode: demoCase.internalCode,
        clientId,
        ownerUserId: params.adminUserId,
        title: demoCase.title,
        subject: demoCase.subject,
        description: demoCase.description,
        processType: demoCase.processType,
        status: demoCase.status,
        openedAt: demoCase.openedAt,
        closedAt: demoCase.closedAt,
        visibility: demoCase.visibility,
        knowledgeStatus: demoCase.knowledgeStatus,
        publishedAt: demoCase.publishedAt,
        confidentialityLevel: demoCase.confidentialityLevel,
        searchText: buildCaseSearchText(demoCase),
      },
    });
    const pdfBytes = await buildPdfBytes({
      title: demoCase.title,
      lines: demoCase.documentBody,
    });
    const storagePath =
      `uploads/documents/${caseFile.id}/${demoCase.documentOriginalName}`;

    await writeStorageFile(storagePath, pdfBytes);

    await prisma.document.upsert({
      where: { storagePath },
      update: {
        caseFileId: caseFile.id,
        originalName: demoCase.documentOriginalName,
        fileType: 'application/pdf',
        hash: createHash('sha256').update(pdfBytes).digest('hex'),
        uploadSource: 'seed_script',
        source: DocumentSource.FILE_UPLOAD,
        ocrStatus: OCRStatus.COMPLETED,
        ocrText: demoCase.documentBody.join(' '),
        ocrProcessedAt: new Date(),
        uploadedById: params.adminUserId,
      },
      create: {
        id: randomUUID(),
        caseFileId: caseFile.id,
        originalName: demoCase.documentOriginalName,
        fileType: 'application/pdf',
        storagePath,
        hash: createHash('sha256').update(pdfBytes).digest('hex'),
        uploadSource: 'seed_script',
        source: DocumentSource.FILE_UPLOAD,
        ocrStatus: OCRStatus.COMPLETED,
        ocrText: demoCase.documentBody.join(' '),
        ocrProcessedAt: new Date(),
        uploadedById: params.adminUserId,
      },
    });
  }
}

async function seedContractTemplates(): Promise<ContractTemplate[]> {
  const templates: ContractTemplate[] = [];

  templates.push(
    await prisma.contractTemplate.upsert({
      where: { slug: 'lease-agreement-basic' },
      update: {
        name: 'Contrato de alquiler residencial',
        description:
          'Plantilla MVP para generar un contrato de alquiler editable y listo para PDF.',
        schemaJson: {
          version: 1,
          category: 'Arrendamientos',
          documentTitle:
            'Contrato de alquiler entre {{landlordName}} y {{tenantName}}',
          summary:
            'Contrato base generado para el inmueble ubicado en {{propertyAddress}} con canon mensual de {{monthlyRent}} Bs.',
          fields: [
            {
              key: 'city',
              type: 'text',
              label: 'Ciudad de firma',
              required: true,
              placeholder: 'La Paz',
              group: 'Encabezado',
            },
            {
              key: 'signatureDate',
              type: 'date',
              label: 'Fecha de firma',
              required: true,
              group: 'Encabezado',
            },
            {
              key: 'landlordName',
              type: 'text',
              label: 'Nombre del arrendador',
              required: true,
              group: 'Partes',
            },
            {
              key: 'tenantName',
              type: 'text',
              label: 'Nombre del arrendatario',
              required: true,
              group: 'Partes',
            },
            {
              key: 'propertyAddress',
              type: 'textarea',
              label: 'Dirección del inmueble',
              required: true,
              group: 'Inmueble',
            },
            {
              key: 'monthlyRent',
              type: 'number',
              label: 'Canon mensual (Bs)',
              required: true,
              group: 'Condiciones económicas',
            },
            {
              key: 'depositAmount',
              type: 'number',
              label: 'Depósito de garantía (Bs)',
              required: true,
              group: 'Condiciones económicas',
            },
            {
              key: 'termMonths',
              type: 'number',
              label: 'Duración en meses',
              required: true,
              group: 'Vigencia',
            },
            {
              key: 'startDate',
              type: 'date',
              label: 'Fecha de inicio',
              required: true,
              group: 'Vigencia',
            },
            {
              key: 'paymentDay',
              type: 'select',
              label: 'Día de pago mensual',
              required: true,
              group: 'Condiciones económicas',
              options: [
                { value: '5', label: '5 de cada mes' },
                { value: '10', label: '10 de cada mes' },
                { value: '15', label: '15 de cada mes' },
              ],
            },
            {
              key: 'allowsPets',
              type: 'boolean',
              label: '¿Se permiten mascotas?',
              required: true,
              group: 'Cláusulas especiales',
            },
            {
              key: 'specialClauses',
              type: 'textarea',
              label: 'Cláusulas adicionales',
              required: false,
              group: 'Cláusulas especiales',
              placeholder: 'Ejemplo: mantenimiento, uso de garaje, penalidades.',
            },
          ],
          sections: [
            {
              heading: 'Comparecientes',
              body:
                'En la ciudad de {{city}}, en fecha {{signatureDate}}, suscriben el presente contrato {{landlordName}}, en calidad de ARRENDADOR, y {{tenantName}}, en calidad de ARRENDATARIO.',
            },
            {
              heading: 'Objeto',
              body:
                'El ARRENDADOR concede en alquiler el inmueble ubicado en {{propertyAddress}}, para uso residencial y conforme a las condiciones detalladas en este instrumento.',
            },
            {
              heading: 'Canon y garantía',
              body:
                'El canon mensual será de {{monthlyRent}} Bs., pagadero el día {{paymentDay}}. El ARRENDATARIO entrega un depósito de garantía de {{depositAmount}} Bs.',
            },
            {
              heading: 'Vigencia',
              body:
                'La vigencia del contrato será de {{termMonths}} meses, computables desde el {{startDate}}, salvo renovación o resolución anticipada conforme a ley y contrato.',
            },
            {
              heading: 'Cláusulas especiales',
              body:
                'Se permiten mascotas: {{allowsPets}}. Observaciones adicionales: {{specialClauses}}.',
            },
          ],
          signatureLines: [
            { label: 'Arrendador', valueKey: 'landlordName' },
            { label: 'Arrendatario', valueKey: 'tenantName' },
          ],
          notes: [
            'Plantilla MVP lista para reemplazar texto por versión final del estudio.',
            'Cuando lleguen nuevas plantillas, basta con cargar un nuevo schemaJson compatible.',
          ],
        },
        priceCents: 1999,
        currency: 'USD',
        isActive: true,
      },
      create: {
        id: randomUUID(),
        slug: 'lease-agreement-basic',
        name: 'Contrato de alquiler residencial',
        description:
          'Plantilla MVP para generar un contrato de alquiler editable y listo para PDF.',
        schemaJson: {
          version: 1,
          category: 'Arrendamientos',
          documentTitle:
            'Contrato de alquiler entre {{landlordName}} y {{tenantName}}',
          summary:
            'Contrato base generado para el inmueble ubicado en {{propertyAddress}} con canon mensual de {{monthlyRent}} Bs.',
          fields: [
            {
              key: 'city',
              type: 'text',
              label: 'Ciudad de firma',
              required: true,
              placeholder: 'La Paz',
              group: 'Encabezado',
            },
            {
              key: 'signatureDate',
              type: 'date',
              label: 'Fecha de firma',
              required: true,
              group: 'Encabezado',
            },
            {
              key: 'landlordName',
              type: 'text',
              label: 'Nombre del arrendador',
              required: true,
              group: 'Partes',
            },
            {
              key: 'tenantName',
              type: 'text',
              label: 'Nombre del arrendatario',
              required: true,
              group: 'Partes',
            },
            {
              key: 'propertyAddress',
              type: 'textarea',
              label: 'Dirección del inmueble',
              required: true,
              group: 'Inmueble',
            },
            {
              key: 'monthlyRent',
              type: 'number',
              label: 'Canon mensual (Bs)',
              required: true,
              group: 'Condiciones económicas',
            },
            {
              key: 'depositAmount',
              type: 'number',
              label: 'Depósito de garantía (Bs)',
              required: true,
              group: 'Condiciones económicas',
            },
            {
              key: 'termMonths',
              type: 'number',
              label: 'Duración en meses',
              required: true,
              group: 'Vigencia',
            },
            {
              key: 'startDate',
              type: 'date',
              label: 'Fecha de inicio',
              required: true,
              group: 'Vigencia',
            },
            {
              key: 'paymentDay',
              type: 'select',
              label: 'Día de pago mensual',
              required: true,
              group: 'Condiciones económicas',
              options: [
                { value: '5', label: '5 de cada mes' },
                { value: '10', label: '10 de cada mes' },
                { value: '15', label: '15 de cada mes' },
              ],
            },
            {
              key: 'allowsPets',
              type: 'boolean',
              label: '¿Se permiten mascotas?',
              required: true,
              group: 'Cláusulas especiales',
            },
            {
              key: 'specialClauses',
              type: 'textarea',
              label: 'Cláusulas adicionales',
              required: false,
              group: 'Cláusulas especiales',
              placeholder: 'Ejemplo: mantenimiento, uso de garaje, penalidades.',
            },
          ],
          sections: [
            {
              heading: 'Comparecientes',
              body:
                'En la ciudad de {{city}}, en fecha {{signatureDate}}, suscriben el presente contrato {{landlordName}}, en calidad de ARRENDADOR, y {{tenantName}}, en calidad de ARRENDATARIO.',
            },
            {
              heading: 'Objeto',
              body:
                'El ARRENDADOR concede en alquiler el inmueble ubicado en {{propertyAddress}}, para uso residencial y conforme a las condiciones detalladas en este instrumento.',
            },
            {
              heading: 'Canon y garantía',
              body:
                'El canon mensual será de {{monthlyRent}} Bs., pagadero el día {{paymentDay}}. El ARRENDATARIO entrega un depósito de garantía de {{depositAmount}} Bs.',
            },
            {
              heading: 'Vigencia',
              body:
                'La vigencia del contrato será de {{termMonths}} meses, computables desde el {{startDate}}, salvo renovación o resolución anticipada conforme a ley y contrato.',
            },
            {
              heading: 'Cláusulas especiales',
              body:
                'Se permiten mascotas: {{allowsPets}}. Observaciones adicionales: {{specialClauses}}.',
            },
          ],
          signatureLines: [
            { label: 'Arrendador', valueKey: 'landlordName' },
            { label: 'Arrendatario', valueKey: 'tenantName' },
          ],
          notes: [
            'Plantilla MVP lista para reemplazar texto por versión final del estudio.',
            'Cuando lleguen nuevas plantillas, basta con cargar un nuevo schemaJson compatible.',
          ],
        },
        priceCents: 1999,
        currency: 'USD',
        isActive: true,
      },
    }),
  );

  await prisma.contractTemplate.upsert({
    where: { slug: 'service-agreement-pending-upload' },
    update: {
      name: 'Contrato de prestación de servicios',
      description:
        'Placeholder listo para activarse cuando llegue la plantilla oficial.',
      schemaJson: {
        version: 1,
        category: 'Servicios',
        documentTitle: 'Plantilla pendiente',
        summary: 'Pendiente de carga por el equipo legal.',
        fields: [
          {
            key: 'placeholder',
            type: 'text',
            label: 'Placeholder',
            required: false,
          },
        ],
        sections: [
          {
            heading: 'Pendiente',
            body: 'Esta plantilla se activará cuando el estudio entregue el texto final.',
          },
        ],
        signatureLines: [],
        notes: ['Placeholder para futuras plantillas.'],
      },
      priceCents: 1499,
      currency: 'USD',
      isActive: false,
    },
    create: {
      id: randomUUID(),
      slug: 'service-agreement-pending-upload',
      name: 'Contrato de prestación de servicios',
      description:
        'Placeholder listo para activarse cuando llegue la plantilla oficial.',
      schemaJson: {
        version: 1,
        category: 'Servicios',
        documentTitle: 'Plantilla pendiente',
        summary: 'Pendiente de carga por el equipo legal.',
        fields: [
          {
            key: 'placeholder',
            type: 'text',
            label: 'Placeholder',
            required: false,
          },
        ],
        sections: [
          {
            heading: 'Pendiente',
            body: 'Esta plantilla se activará cuando el estudio entregue el texto final.',
          },
        ],
        signatureLines: [],
        notes: ['Placeholder para futuras plantillas.'],
      },
      priceCents: 1499,
      currency: 'USD',
      isActive: false,
    },
  });

  return templates;
}

function buildCaseSearchText(demoCase: DemoCaseSeed): string {
  return [
    demoCase.internalCode,
    demoCase.title,
    demoCase.subject,
    demoCase.description,
    demoCase.processType,
  ].join(' | ');
}

async function buildPdfBytes(params: {
  title: string;
  lines: string[];
}): Promise<Uint8Array> {
  const pdfDocument = await PDFDocument.create();
  const page = pdfDocument.addPage();
  const boldFont = await pdfDocument.embedFont(StandardFonts.HelveticaBold);
  const regularFont = await pdfDocument.embedFont(StandardFonts.Helvetica);
  let currentY = page.getHeight() - 56;

  page.drawText(params.title, {
    x: 48,
    y: currentY,
    size: 16,
    font: boldFont,
  });
  currentY -= 28;

  for (const line of params.lines) {
    page.drawText(line, {
      x: 48,
      y: currentY,
      size: 11,
      font: regularFont,
      maxWidth: page.getWidth() - 96,
      lineHeight: 16,
    });
    currentY -= 34;
  }

  return pdfDocument.save();
}

async function writeStorageFile(
  storagePath: string,
  bytes: Uint8Array,
): Promise<void> {
  const absolutePath = resolve(process.cwd(), storagePath);

  await mkdir(dirname(absolutePath), { recursive: true });
  await writeFile(absolutePath, Buffer.from(bytes));
}

async function main(): Promise<void> {
  await seedRoles();
  const users = await seedUsers();
  const clientIds = await seedClients();

  await seedCaseFilesAndDocuments({
    adminUserId: users.adminUserId,
    clientIds,
  });
  await seedContractTemplates();

  console.log('Seed completed');
}

main()
  .catch((error) => {
    console.error('Seed failed', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
