// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class et4ae5__Configuration__c {
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
    global Boolean et4ae5__Aggregate_Tracking__c;
    global Boolean et4ae5__Allow_Personal_Reports__c;
    global String et4ae5__Auth_API_URL__c;
    global Boolean et4ae5__AwaitingBusinessUnits__c;
    global Double et4ae5__Days_Tracked__c;
    global String et4ae5__Deep_Link_Availability__c;
    global String et4ae5__Exclusion_Audience__c;
    global String et4ae5__Frequency__c;
    global Boolean et4ae5__Individual_Tracking__c;
    global String et4ae5__Integration_Type__c;
    global Datetime et4ae5__Last_Log_Request__c;
    global Boolean et4ae5__Link_Detail_Tracking__c;
    global Boolean et4ae5__MultiFrom__c;
    global Boolean et4ae5__MultiReplyTo__c;
    global String et4ae5__Parent_Account_MID__c;
    global String et4ae5__Password__c;
    global Boolean et4ae5__Restrict_Automation__c;
    global Boolean et4ae5__Retry__c;
    global String et4ae5__Root_Open_Rasta_API_URL__c;
    global String et4ae5__Root_Rest_API_URL__c;
    global String et4ae5__Root_SOAP_API_URL__c;
    global String et4ae5__Send_Types__c;
    global Boolean et4ae5__Sent_Events_Tracking__c;
    global String et4ae5__Support_Ticket_Recipient__c;
    global String et4ae5__Target_Audience__c;
    global String et4ae5__Username__c;
    global String et4ae5__automationObjects__c;
    global String et4ae5__replyToOptions__c;
    global String et4ae5__url_part__c;
    global String et4ae5__url_root__c;
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
    global List<et4ae5__Configuration__Share> Shares;
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

    global et4ae5__Configuration__c () 
    {
    }
}