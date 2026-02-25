// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class et4ae5__Automated_Send__c {
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
    global String et4ae5__Action__c;
    global Boolean et4ae5__Active__c;
    global Datetime et4ae5__BackupWorkflow__c;
    global et4ae5__Business_Unit__c et4ae5__Business_Unit__r;
    global Id et4ae5__Business_Unit__c;
    /* The Contact/Lead Field is used to identify the intended recipient of the email. This must be a Lookup field to the Contact or Lead Object for the respective object used in the Triggered Send Definition. If creating a Triggered Send on the Contact or Lead
    */
    global String et4ae5__Contact_Lead_FIeld__c;
    global String et4ae5__ConversationId__c;
    global String et4ae5__Data_Extension_Id__c;
    global String et4ae5__Data_Extension_Name__c;
    global Datetime et4ae5__DateSent__c;
    global Datetime et4ae5__DateTime__c;
    global Date et4ae5__Date__c;
    global String et4ae5__EmailAssetId__c;
    global String et4ae5__EmailId__c;
    global String et4ae5__EmailName__c;
    /* Field Criteria can be used to further refine if a Triggered Send should be sent.  Criteria is evaluated when the selected Object Event occurs
    */
    global String et4ae5__Filter__c;
    global String et4ae5__FromEmail__c;
    global String et4ae5__FromName__c;
    global Double et4ae5__Hours_Delayed__c;
    global Boolean et4ae5__Individual_Tracking_Disabled__c;
    global String et4ae5__MemberId__c;
    global String et4ae5__NotificationRecipients__c;
    global Boolean et4ae5__Notify_Owner_On_Error__c;
    global Boolean et4ae5__Notify_Running_User_On_Error__c;
    global Double et4ae5__NumberSent__c;
    global Double et4ae5__NumberUnsubscribed__c;
    global Double et4ae5__NumberofExistingUndeliverables__c;
    global Double et4ae5__NumberofExistingUnsubscribes__c;
    global Double et4ae5__NumberofHardBounces__c;
    global Double et4ae5__NumberofSoftBounces__c;
    global Double et4ae5__NumberofSubscribersForwardingEmail__c;
    global Double et4ae5__NumberofTotalClicks__c;
    global Double et4ae5__NumberofTotalOpens__c;
    global Double et4ae5__NumberofUniqueClicks__c;
    global Double et4ae5__NumberofUniqueOpens__c;
    /* Object which the Triggered Send is based off of
    */
    global String et4ae5__Object__c;
    /* Field value selected that looks up to person accounts.
    */
    global String et4ae5__Person_Account_Lookup_Field__c;
    /* The string of text used to appear in the email's preheader. Note: This text contains backslashes (\) before all single quotes (') to ensure a secure experience. However, these backslashes do not appear in the email sent.
    */
    global String et4ae5__Preheader__c;
    global Boolean et4ae5__RecipientsOptedIn__c;
    global String et4ae5__SendClassificationId__c;
    global String et4ae5__SendClassificationName__c;
    global String et4ae5__SenderProfileId__c;
    global String et4ae5__SubjectBlob__c;
    /* The string of text used to appear in the email's subject line. Note: This text contains backslashes (\) before all single quotes (') to ensure a secure experience. However, these backslashes do not appear in the email sent.
    */
    global String et4ae5__Subject__c;
    global Boolean et4ae5__Subscribed_For_Tracking__c;
    global String et4ae5__Subscriber_Field__c;
    global Boolean et4ae5__TrackingOnly__c;
    global Boolean et4ae5__Use_All_Subscribers_List__c;
    global String et4ae5__etTriggeredSendDefId__c;
    global Boolean et4ae5__hasDelayedSends__c;
    global Double et4ae5__Bounce_Rate_del__c;
    global Double et4ae5__Click_Through_Rate__c;
    global Double et4ae5__Deliverability_Rate__c;
    global Double et4ae5__NumberNotClicked__c;
    global Double et4ae5__Number_Bounced__c;
    global Double et4ae5__Number_Delivered__c;
    global Double et4ae5__Number_Not_Opened__c;
    global Double et4ae5__Open_Rate__c;
    /* Object event that will trigger the evaluation of the Triggered Send.  Options are for when a new record for respective object is created, existing record is updated, or both created and updated
    */
    global String et4ae5__Trigger_send_when__c;
    global Double et4ae5__Unsubscribe_Rate__c;
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
    global List<et4ae5__AggregateLink__c> et4ae5__Aggregate_Link_Level_Details__r;
    global List<et4ae5__Automated_Send__History> Histories;
    global List<et4ae5__Automated_Send__Share> Shares;
    global List<et4ae5__IndividualEmailResult__c> et4ae5__Individual_Email_Results__r;
    global List<et4ae5__SendDefinition__c> et4ae5__EmailSends__r;
    global List<et4ae5__Triggered_Send_Execution__c> et4ae5__Triggered_Send_Executions__r;
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

    global et4ae5__Automated_Send__c () 
    {
    }
}