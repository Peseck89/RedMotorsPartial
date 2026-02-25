// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class dfsle__Recipient__c {
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
    /* DocuSign Envelope
    */
    global dfsle__Envelope__c dfsle__Envelope__r;
    /* DocuSign Envelope
    */
    global Id dfsle__Envelope__c;
    /* Access Code
    */
    global String dfsle__AccessCode__c;
    global Boolean dfsle__DeliverBySms__c;
    global String dfsle__EmailMessage__c;
    global String dfsle__EmailSubject__c;
    global String dfsle__Email__c;
    global String dfsle__EnvelopeRecipientId__c;
    global String dfsle__HostEmail__c;
    global String dfsle__HostName__c;
    global Boolean dfsle__IdCheckRequired__c;
    global String dfsle__Language__c;
    global String dfsle__Note__c;
    global String dfsle__Options__c;
    global Boolean dfsle__ReadOnly__c;
    global Boolean dfsle__Required__c;
    global Double dfsle__RoleValue__c;
    /* Role
    */
    global String dfsle__Role__c;
    /* Routing Order
    */
    global Double dfsle__RoutingOrder__c;
    global Double dfsle__Sequence__c;
    global Boolean dfsle__SignNow__c;
    /* Signing Group ID
    */
    global Double dfsle__SigningGroupId__c;
    global String dfsle__SigningGroupName__c;
    global String dfsle__SmsPhoneNumber__c;
    global String dfsle__SourceId__c;
    /* Type
    */
    global String dfsle__Type__c;
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

    global dfsle__Recipient__c () 
    {
    }
}