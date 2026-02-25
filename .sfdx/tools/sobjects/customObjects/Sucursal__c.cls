// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class Sucursal__c {
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
    global Datetime LastViewedDate;
    global Datetime LastReferencedDate;
    global User DirectordeVentasBMW__r;
    global Id DirectordeVentasBMW__c;
    global User DirectordeVentasKTM__r;
    global Id DirectordeVentasKTM__c;
    global User DirectordeVentasKawasaki__r;
    global Id DirectordeVentasKawasaki__c;
    global User DirectordeVentasMini__r;
    global Id DirectordeVentasMini__c;
    global User DirectordeVentasMotorrad__r;
    global Id DirectordeVentasMotorrad__c;
    global User DirectordeVentasPolaris__r;
    global Id DirectordeVentasPolaris__c;
    global User Gerente_de_SucursalMotorrad__r;
    global Id Gerente_de_SucursalMotorrad__c;
    global User GerentedeSucursalBMW__r;
    global Id GerentedeSucursalBMW__c;
    global User GerentedeSucursalKTM__r;
    global Id GerentedeSucursalKTM__c;
    global User GerentedeSucursalKawasaki__r;
    global Id GerentedeSucursalKawasaki__c;
    global User GerentedeSucursalMini__r;
    global Id GerentedeSucursalMini__c;
    global User GerentedeSucursalPolaris__r;
    global Id GerentedeSucursalPolaris__c;
    global User JefedeSucursalMotorrad__r;
    global Id JefedeSucursalMotorrad__c;
    global User JefesdeSucursalKTM__r;
    global Id JefesdeSucursalKTM__c;
    global User JefesdeSucursalKawasaki__r;
    global Id JefesdeSucursalKawasaki__c;
    global User JefesdeSucursalMini__r;
    global Id JefesdeSucursalMini__c;
    global User JefesdeSucursalPolaris__r;
    global Id JefesdeSucursalPolaris__c;
    global User JefeseSucursalBMW__r;
    global Id JefeseSucursalBMW__c;
    global String Marca__c;
    global User DirectordeVentasHarley__r;
    global Id DirectordeVentasHarley__c;
    global User GerentedeSucursalHarley__r;
    global Id GerentedeSucursalHarley__c;
    global User JefedeSucursalHarley__r;
    global Id JefedeSucursalHarley__c;
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
    global List<Opportunity> OportunidadesSucursales__r;
    global List<ProcessException> ProcessExceptions;
    global List<ProcessInstance> ProcessInstances;
    global List<ProcessInstanceHistory> ProcessSteps;
    global List<RecordAction> RecordActions;
    global List<RecordActionHistory> RecordActionHistories;
    global List<RecordAlert> RecordAlertParent;
    global List<RecordAlert> RecordAlertWhat;
    global List<Sucursal__History> Histories;
    global List<SurveySubject> SurveySubjectEntities;
    global List<TaskRelation> TaskRelations;
    global List<TopicAssignment> TopicAssignments;
    global List<UserDefinedLabelAssignment> UserDefinedLabelAssignments;
    global List<Vendedores__c> Vendedores__r;
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

    global Sucursal__c () 
    {
    }
}