// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class dfsle__Envelope__c {
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
    global String dfsle__DFSTemplateId__c;
    global String dfsle__DocuSignId__c;
    /* Edit this email message Text (up to 10,000 characters) and it will appear in the notification to sign for
			your DocuSign Recipient.
		
    */
    global String dfsle__EmailMessage__c;
    /* Change this default email subject text and it will appear as the Subject Line in the notification to Sign
			for your DocuSign Recipients.
		
    */
    global String dfsle__EmailSubject__c;
    /* The configuration used to generate this envelope.
    */
    global dfsle__EnvelopeConfiguration__c dfsle__EnvelopeConfiguration__r;
    /* The configuration used to generate this envelope.
    */
    global Id dfsle__EnvelopeConfiguration__c;
    /* Indicate the number of days until this transaction is expired.
    */
    global Double dfsle__ExpireAfterDays__c;
    /* Indicate how many days prior to expiration you want an email message to alert recipients that a deadline
			approaches for completion. This is sent only to recipients who have not yet completed the transaction.
		
    */
    global Double dfsle__ExpireWarnDays__c;
    /* At times, you may need to encourage your recipients to complete an envelope more rapidly. After an envelope expires, DocuSign voids the envelope and sends a notification to both sender and recipient.
    */
    global Boolean dfsle__Expires__c;
    global String dfsle__Options__c;
    /* Indicate how many days should pass before the first reminder is sent
    */
    global Double dfsle__RemindAfterDays__c;
    /* Indicate how often (in days) the reminder should repeat until the transaction is complete.
    */
    global Double dfsle__RemindFrequencyDays__c;
    /* Check this box to have an email reminder sent to recipients of the envelope who have not yet completed
			their task.
		
    */
    global Boolean dfsle__Remind__c;
    global String dfsle__SenderPermissions__c;
    global User dfsle__Sender__r;
    global Id dfsle__Sender__c;
    /* Date and time sent
    */
    global Datetime dfsle__Sent__c;
    /* Salesforce source ID
    */
    global String dfsle__SourceId__c;
    global String dfsle__TransactionId__c;
    /* Check to show chatter during DocuSign signature workflow.
    */
    global Boolean dfsle__UpdateChatter__c;
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
    global List<dfsle__Document__c> dfsle__Documents__r;
    global List<dfsle__Envelope__Share> Shares;
    global List<dfsle__Recipient__c> dfsle__Recipients__r;
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

    global dfsle__Envelope__c () 
    {
    }
}