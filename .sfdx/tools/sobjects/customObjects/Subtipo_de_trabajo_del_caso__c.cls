// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class Subtipo_de_trabajo_del_caso__c {
    global Id Id;
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
    global Datetime LastViewedDate;
    global Datetime LastReferencedDate;
    global Double Cantidad_de_horas__c;
    global tiposDeTrabajoCaso__c Tipo_de_trabajo_del_caso__r;
    global Id Tipo_de_trabajo_del_caso__c;
    global Case Caso__r;
    global Id Caso__c;
    global WorkStep Paso_de_trabajo__r;
    global Id Paso_de_trabajo__c;
    global WorkOrder Orden_de_trabajo__r;
    global Id Orden_de_trabajo__c;
    global String id_paso__c;
    global Product2 Mano_de_Obra__r;
    global Id Mano_de_Obra__c;
    global WorkOrderLineItem Articulo_Mano_de_Obra__r;
    global Id Articulo_Mano_de_Obra__c;
    global String Mecanico__c;
    global Subtipo_de_trabajo_del_caso__c RM_SubtipoTrabajoCaso__r;
    global Id RM_SubtipoTrabajoCaso__c;
    global Double NumeroDeArchivosCargados__c;
    global Boolean updatedFlowSync__c;
    global Double NumeroDeFotosCargadas__c;
    global Double NumeroDeVideosCargados__c;
    global String Asesor__c;
    global String Propietario_del_veh_culo__c;
    global String Contacto_del_veh_culo__c;
    global String VIN__c;
    global String Kilometraje__c;
    global String Territorio_de_servicio__c;
    global String Fecha_y_hora_de_apertura_caso__c;
    global String Trabajo_a_realizar__c;
    global String filesJson__c;
    global Double UTS__c;
    global tiposDeTrabajo__c TipoDeTrabajo__r;
    global Id TipoDeTrabajo__c;
    global String Alias__c;
    global List<AttachedContentDocument> AttachedContentDocuments;
    global List<AttachedContentNote> AttachedContentNotes;
    global List<Attachment> Attachments;
    global List<CollaborationGroupRecord> RecordAssociatedGroups;
    global List<CombinedAttachment> CombinedAttachments;
    global List<ContactRequest> ContactRequests;
    global List<ContentDocumentLink> ContentDocumentLinks;
    global List<DuplicateRecordItem> DuplicateRecordItems;
    global List<EngagementTopic> EngagementInitiatedTopic;
    global List<EntitySubscription> FeedSubscriptionsForEntity;
    global List<EventRelation> EventRelations;
    global List<FlowOrchestrationWorkItem> FlowOrchestrationWorkItems;
    global List<NetworkActivityAudit> ParentEntities;
    global List<NetworkUserHistoryRecent> NetworkUserHistoryRecentToRecord;
    global List<Note> Notes;
    global List<NoteAndAttachment> NotesAndAttachments;
    global List<ProcessException> ProcessExceptions;
    global List<ProcessInstance> ProcessInstances;
    global List<ProcessInstanceHistory> ProcessSteps;
    global List<RecordAction> RecordActions;
    global List<RecordActionHistory> RecordActionHistories;
    global List<RecordAlert> RecordAlertParent;
    global List<RecordAlert> RecordAlertWhat;
    global List<Subtipo_de_trabajo_del_caso__Feed> Feeds;
    global List<Subtipo_de_trabajo_del_caso__History> Histories;
    global List<Subtipo_de_trabajo_del_caso__c> RM_SubtipoTrabajoCasos__r;
    global List<SurveySubject> SurveySubjectEntities;
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
    global List<PendingServiceRouting> WorkItem;
    global List<PendingServiceRoutingInteractionInfo> PrimaryRecord;
    global List<PendingServiceRoutingInteractionInfo> TargetObject;
    global List<ProcessExceptionEvent> AttachedTo;
    global List<TaskChangeEvent> What;
    global List<TaskRelationChangeEvent> Relation;
    global List<VideoCallChangeEvent> RelatedRecord;

    global Subtipo_de_trabajo_del_caso__c () 
    {
    }
}