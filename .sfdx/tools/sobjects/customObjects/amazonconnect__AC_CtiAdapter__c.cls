// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class amazonconnect__AC_CtiAdapter__c {
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
    global Boolean amazonconnect__AudioDeviceSettings__c;
    global String amazonconnect__BottomPanel__c;
    global String amazonconnect__CallCenter__c;
    global String amazonconnect__CcpVersion__c;
    global String amazonconnect__ConnectInstance__c;
    global String amazonconnect__CustomChatRingtone__c;
    global String amazonconnect__CustomRingtone__c;
    global String amazonconnect__DebugLevel__c;
    global Boolean amazonconnect__EnableSoftphonePopout__c;
    global String amazonconnect__Instance__c;
    global Boolean amazonconnect__Medialess__c;
    global Boolean amazonconnect__PhoneTypeSettings__c;
    global Boolean amazonconnect__PresenceSyncEnabled__c;
    global String amazonconnect__Region__c;
    global Boolean amazonconnect__SoftphonePopoutEnabled__c;
    global String amazonconnect__SsoRelayState__c;
    global String amazonconnect__SsoUrl__c;
    global String amazonconnect__UserDefined__c;
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
    global List<amazonconnect__AC_CtiAdapter__Share> Shares;
    global List<amazonconnect__AC_CtiAttribute__c> amazonconnect__Attributes__r;
    global List<amazonconnect__AC_CtiScript__c> amazonconnect__Scripts__r;
    global List<amazonconnect__AC_Feature__c> amazonconnect__Features__r;
    global List<amazonconnect__AC_PresenceSyncRule__c> amazonconnect__PresenceSyncRules__r;
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

    global amazonconnect__AC_CtiAdapter__c () 
    {
    }
}