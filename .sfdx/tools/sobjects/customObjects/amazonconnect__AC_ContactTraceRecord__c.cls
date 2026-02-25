// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class amazonconnect__AC_ContactTraceRecord__c {
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
    global String amazonconnect__AWSAccountId__c;
    global Double amazonconnect__AfterContactWorkDuration__c;
    global Datetime amazonconnect__AfterContactWorkEndTimestamp__c;
    global Datetime amazonconnect__AfterContactWorkStartTimestamp__c;
    global String amazonconnect__AgentARN__c;
    global Datetime amazonconnect__AgentConnectedToAgentTimestamp__c;
    global Double amazonconnect__AgentConnectionAttempts__c;
    global Double amazonconnect__AgentCustomerHoldDuration__c;
    global String amazonconnect__AgentHierarchyGroup__c;
    global String amazonconnect__AgentHierarchyGroups__c;
    global Double amazonconnect__AgentInteractionDuration__c;
    global Double amazonconnect__AgentLongestHoldDuration__c;
    global Double amazonconnect__AgentNumberOfHolds__c;
    global String amazonconnect__AgentRoutingProfileARN__c;
    global String amazonconnect__AgentRoutingProfileName__c;
    global String amazonconnect__AgentUsername__c;
    global String amazonconnect__Attributes__c;
    global String amazonconnect__Channel__c;
    global Datetime amazonconnect__ConnectedToSystemTimestamp__c;
    global amazonconnect__AC_ContactChannels__c amazonconnect__ContactChannel__r;
    global Id amazonconnect__ContactChannel__c;
    global String amazonconnect__ContactDetails__c;
    global String amazonconnect__ContactId__c;
    global String amazonconnect__CustomerEndpointAddress__c;
    global String amazonconnect__DisconnectReason__c;
    global Datetime amazonconnect__DisconnectTimestamp__c;
    global String amazonconnect__InitialContactId__c;
    global Datetime amazonconnect__InitiationTimestamp__c;
    global String amazonconnect__Initiation_Method__c;
    global String amazonconnect__InstanceARN__c;
    global Datetime amazonconnect__LastUpdateTimestamp__c;
    global String amazonconnect__NextContactId__c;
    global Double amazonconnect__NumberOfHolds__c;
    global amazonconnect__AC_PhoneCall__c amazonconnect__PhoneCall__r;
    global Id amazonconnect__PhoneCall__c;
    global String amazonconnect__PreviousContactId__c;
    global String amazonconnect__QueueARN__c;
    global Datetime amazonconnect__QueueDequeueTimestamp__c;
    global Double amazonconnect__QueueDuration__c;
    global Datetime amazonconnect__QueueEnqueueTimestamp__c;
    global String amazonconnect__QueueName__c;
    global String amazonconnect__RecordingDeletionReason__c;
    global String amazonconnect__RecordingLocation__c;
    global String amazonconnect__RecordingStatus__c;
    global String amazonconnect__References__c;
    global String amazonconnect__SystemEndpointAddress__c;
    global Datetime amazonconnect__TransferCompletedTimestamp__c;
    global String amazonconnect__TransferredToEndpoint__c;
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
    global List<amazonconnect__AC_ContactTraceRecord__Share> Shares;
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

    global amazonconnect__AC_ContactTraceRecord__c () 
    {
    }
}