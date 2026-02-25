// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class estudioArticulo15__c {
    global Id Id;
    global SObject Owner;
    global Id OwnerId;
    global Boolean IsDeleted;
    global String Name;
    global String CurrencyIsoCode;
    global Datetime CreatedDate;
    global User CreatedBy;
    global Id CreatedById;
    global Datetime LastModifiedDate;
    global User LastModifiedBy;
    global Id LastModifiedById;
    global Datetime SystemModstamp;
    global Date LastActivityDate;
    global Datetime LastViewedDate;
    global Datetime LastReferencedDate;
    /* Estudio de buró relacionado al estudio de articulo 15.
    */
    global Encabezado__c EstudioBuro__r;
    /* Estudio de buró relacionado al estudio de articulo 15.
    */
    global Id EstudioBuro__c;
    global String Factor__c;
    /* Actividades de negocio.
    */
    global actividadesNegocios__c actividadesNegocio__r;
    /* Actividades de negocio.
    */
    global Id actividadesNegocio__c;
    /* Cliente relacionado al estudio.
    */
    global Account cliente__r;
    /* Cliente relacionado al estudio.
    */
    global Id cliente__c;
    global String colorRiesgo__c;
    /* Puntaje para el valor de comportamiento.
    */
    global Double comportamiento__c;
    /* Puntaje para la estructura de la propiedad.
    */
    global Double estructuraPropiedad__c;
    global Double montoCotizacion__c;
    global String nivelRiesgoActual__c;
    /* OF relacionada al estudio. De aquí se obtienen datos relevantes para el cálculo de riesgo.
    */
    global Oportunidad_de_Financiamiento__c oportunidadFinanciamiento__r;
    /* OF relacionada al estudio. De aquí se obtienen datos relevantes para el cálculo de riesgo.
    */
    global Id oportunidadFinanciamiento__c;
    /* Origen de los recursos según si la actividad es es efectuada en el país o en el extranjero.
    */
    global Double origenRecursos__c;
    /* Peso recibido por factor cliente.
    */
    global Double pesoFactorCliente__c;
    /* Peso por factor jurisdicción.
    */
    global Double pesoFactorJurisdiccion__c;
    /* Peso recibido por el factor producto.
    */
    global Double pesoFactorproducto__c;
    /* Peso obtenido para rango.
    */
    global Double pesoObtenido__c;
    /* Peso total de acuerdo a los pesos calculados de factor jurisdicción, factor producto y factor cliente. Promediado.
    */
    global Double pesoTotal__c;
    /* Profesión en el caso de físicos.
    */
    global actividadesNegocios__c profesionFisicos__r;
    /* Profesión en el caso de físicos.
    */
    global Id profesionFisicos__c;
    global Double score__c;
    global String tipoCliente__c;
    /* Bajo (1) :Exposición de hasta US$100.000.

Medio (2): Exposición de entre US$100.000,01 hasta US$150.000.

Alto (3): Exposición de más de US$150.000.
    */
    global Double tipoMontoFrecuenciaTransacciones__c;
    /* Información proveniente del lago de datos. 

Bajo (1): Prendario, Crédito Personal, Leasing Financiero, Leasing Operativo en Función Financiero

Alto (3): Renting
    */
    global Double tipoProducto__c;
    global List<ActionPlan> ActionPlans;
    global List<ActivityHistory> ActivityHistories;
    global List<AttachedContentDocument> AttachedContentDocuments;
    global List<AttachedContentNote> AttachedContentNotes;
    global List<Attachment> Attachments;
    global List<CollaborationGroupRecord> RecordAssociatedGroups;
    global List<CombinedAttachment> CombinedAttachments;
    global List<ContactRequest> ContactRequests;
    global List<ContentDocumentLink> ContentDocumentLinks;
    global List<DuplicateRecordItem> DuplicateRecordItems;
    global List<EmailMessage> Emails;
    global List<EngagementTopic> EngagementInitiatedTopic;
    global List<EntitySubscription> FeedSubscriptionsForEntity;
    global List<Event> Events;
    global List<EventRelation> EventRelations;
    global List<FlowOrchestrationWorkItem> FlowOrchestrationWorkItems;
    global List<NetworkActivityAudit> ParentEntities;
    global List<NetworkUserHistoryRecent> NetworkUserHistoryRecentToRecord;
    global List<Note> Notes;
    global List<NoteAndAttachment> NotesAndAttachments;
    global List<OpenActivity> OpenActivities;
    global List<ProcessException> ProcessExceptions;
    global List<ProcessInstance> ProcessInstances;
    global List<ProcessInstanceHistory> ProcessSteps;
    global List<RecordAction> RecordActions;
    global List<RecordActionHistory> RecordActionHistories;
    global List<RecordAlert> RecordAlertParent;
    global List<RecordAlert> RecordAlertWhat;
    global List<SurveySubject> SurveySubjectEntities;
    global List<Task> Tasks;
    global List<TaskRelation> TaskRelations;
    global List<TopicAssignment> TopicAssignments;
    global List<UserDefinedLabelAssignment> UserDefinedLabelAssignments;
    global List<VideoCall> VideoRelatedRecords;
    global List<VoiceCall> RelatedRecords;
    global List<estudioArticulo15__History> Histories;
    global List<AIInsightValue> SobjectLookupValue;
    global List<AIRecordInsight> Target;
    global List<AgentWork> WorkItem;
    global List<ContentDistribution> RelatedRecord;
    global List<ContentDocumentLinkChangeEvent> LinkedEntity;
    global List<ContentVersion> FirstPublishLocation;
    global List<EmailMessageChangeEvent> RelatedTo;
    global List<EngagementTopicChangeEvent> Topic;
    global List<EventChangeEvent> What;
    global List<EventRelationChangeEvent> Relation;
    global List<FeedComment> Parent;
    global List<FlowExecutionErrorEvent> ContextRecord;
    global List<FlowRecordRelation> RelatedRecord;
    global List<NetworkFeedResponseMetric> ParentRecord;
    global List<OutgoingEmail> RelatedTo;
    global List<PendingServiceRouting> WorkItem;
    global List<PendingServiceRoutingInteractionInfo> PrimaryRecord;
    global List<PendingServiceRoutingInteractionInfo> TargetObject;
    global List<ProcessExceptionEvent> AttachedTo;
    global List<TaskChangeEvent> What;
    global List<TaskRelationChangeEvent> Relation;
    global List<VideoCallChangeEvent> RelatedRecord;

    global estudioArticulo15__c () 
    {
    }
}