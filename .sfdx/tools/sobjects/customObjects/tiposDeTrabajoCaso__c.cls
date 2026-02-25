// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class tiposDeTrabajoCaso__c {
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
    global tiposDeTrabajo__c Tipotrabajo__r;
    global Id Tipotrabajo__c;
    global Case Caso__r;
    global Id Caso__c;
    global String ComentarioTTC__c;
    global Date FechaAlta__c;
    global String Status__c;
    global String Taller__c;
    global String Tipo_de_cargo__c;
    global Double Horaa__c;
    global String Nombre_TTC__c;
    global WorkPlan Plan_de_trabajo__r;
    global Id Plan_de_trabajo__c;
    global Boolean Plan_creado__c;
    global Double Total_de_horas__c;
    global WorkStep Paso_de_trabajo__r;
    global Id Paso_de_trabajo__c;
    global Account Taller_Sucursal__r;
    global Id Taller_Sucursal__c;
    global String id_taller_formula__c;
    global Double BMW_TotalDeHoras__c;
    global String Comment__c;
    global Double CT_Total_Subtareas_FM__c;
    global Double Ordenamiento__c;
    global String RM_ModoTrabajo__c;
    global tiposDeTrabajoCaso__c RM_TipoTrabajoCaso__r;
    global Id RM_TipoTrabajoCaso__c;
    global WorkOrder RM_WorkOrder__r;
    global Id RM_WorkOrder__c;
    global Account RM_Aseguradora__r;
    global Id RM_Aseguradora__c;
    global CentroCosto__c RM_CentroCosto__r;
    global Id RM_CentroCosto__c;
    global Boolean RM_EsTrabajoAdicional__c;
    global Double NumeroDeArchivosCargados__c;
    global Double NumeroDeFotosCargadas__c;
    global Double NumeroDeVideosCargados__c;
    global String Asesor__c;
    global String Propietario_del_veh_culo__c;
    global String Contacto_del_veh_culo__c;
    global String VIN__c;
    global String Kilometraje__c;
    global String Territorio_de_servicio__c;
    global String Fecha_y_hora_de_apertura_caso__c;
    global String Aprobador__c;
    global String Categor_a_de_presupuesto__c;
    global String Estado_aprobaci_n_service__c;
    global Boolean Enviar_a_service__c;
    global String filesJson__c;
    global String NombreDeTrabajo__c;
    global Double UTS__c;
    global Double UTSDelTipoDeTrabajo__c;
    global Double TotalDeUTS__c;
    global String Alias_Articulo__c;
    global Double UTS_Real__c;
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
    global List<Subtipo_de_trabajo_del_caso__c> Subtipos_de_trabajos_del_caso__r;
    global List<SurveySubject> SurveySubjectEntities;
    global List<TaskRelation> TaskRelations;
    global List<TopicAssignment> TopicAssignments;
    global List<UserDefinedLabelAssignment> UserDefinedLabelAssignments;
    global List<VideoCall> VideoRelatedRecords;
    global List<VoiceCall> RelatedRecords;
    global List<WorkOrderLineItem> Work_Order_Line_Items__r;
    global List<WorkPlan> Planes_de_trabajo__r;
    global List<WorkPlanTemplateEntry> Entradas_de_plantillas_de_planes_de_trab__r;
    global List<WorkStep> Pasos_de_trabajo__r;
    global List<tiposDeTrabajoCaso__Feed> Feeds;
    global List<tiposDeTrabajoCaso__History> Histories;
    global List<tiposDeTrabajoCaso__c> RM_TipoTrabajoCasos__r;
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

    global tiposDeTrabajoCaso__c () 
    {
    }
}