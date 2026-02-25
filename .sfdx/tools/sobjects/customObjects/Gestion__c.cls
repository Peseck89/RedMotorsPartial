// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class Gestion__c {
    global Id Id;
    global SObject Owner;
    global Id OwnerId;
    global Boolean IsDeleted;
    global String Name;
    global String CurrencyIsoCode;
    global RecordType RecordType;
    global Id RecordTypeId;
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
    global String Comentarios_Internos__c;
    global String Comentarios_por_parte_del_cliente__c;
    global String Comprobante_Pago__c;
    global String Datos_Activo__c;
    global String Email_Cliente__c;
    global String Estado__c;
    global Date Fecha_de_la_Proyeccion__c;
    global Date Fecha_ingreso_al_pais__c;
    global Date Fecha_salida_del_pais__c;
    global String Moneda__c;
    global String Motivo_reposicion__c;
    global Account Nombre_Completo__r;
    global Id Nombre_Completo__c;
    global String Nuevo_Correo_Electronico__c;
    global String Nuevo_Numero_de_Cuenta__c;
    global String Numero_Cedula_2__c;
    global String Numero_Cedula_3__c;
    global String Numero_Cedula_4__c;
    global String Numero_Cedula__c;
    global String Numero_Operacion__c;
    global String Pais_al_que_se_dirige__c;
    global Account Persona_autorizada_a_realizar_tramite__r;
    global Id Persona_autorizada_a_realizar_tramite__c;
    global String Persona_que_Manejaria_el_Activo_2__c;
    global String Persona_que_Manejarian_el_Activo__c;
    global String Placa__c;
    global String Reposicion_Placas__c;
    global Decimal Cuota_Mensual__c;
    global Date Fecha_Cancelacion__c;
    global String Canal__c;
    global Date Fecha_Pago__c;
    global String Tipo_Producto__c;
    global Boolean Placa_Temporal__c;
    global Decimal Amortizacion__c;
    global Decimal Seguro__c;
    global Decimal Intereses__c;
    global Decimal Cargos__c;
    global Decimal IVA__c;
    global Decimal Saldo_Total_Proyectado__c;
    global Decimal Saldo_Final__c;
    global Decimal Saldo_Inicial__c;
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

    global Gestion__c () 
    {
    }
}