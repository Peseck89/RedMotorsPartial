// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class FSL__Work_Rule__c {
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
    global Datetime LastViewedDate;
    global Datetime LastReferencedDate;
    global Boolean FSL__Active__c;
    /* Compare a numeric service property with a numeric resource property
    */
    global String FSL__Boolean_Operator__c;
    /* Determines the length of the breaks created. 
Leave this field empty if you don't want to create breaks.
    */
    global Double FSL__Break_Duration__c;
    /* Determines the minimum break start time (in the format: {HH:MM}) to create breaks. 
Leave this field empty if you don't want to create breaks.
    */
    global String FSL__Break_Start__c;
    /* The object containing the custom field that's used for the count.
    */
    global String FSL__CountObject__c;
    /* The time resolution for the count.
    */
    global String FSL__CountTimeResolution__c;
    /* The type of item counted in the work rule.
    */
    global String FSL__CountType__c;
    /* When checked, compare the Minimum Crew Size field on the Work Order or Work Order Line Item to the actual available Service Crew Members. 
Otherwise, compare the Minimum Crew Size to the Crew Size field on the Service Crew.
    */
    global Boolean FSL__Crew_Resources_Availability__c;
    /* The API name of the custom field on the count object.
    */
    global String FSL__CustomFieldName__c;
    /* A limit for the count. A limit on the service resource overrides this value.
    */
    global Double FSL__DefaultLimit__c;
    global String FSL__Description__c;
    global Boolean FSL__Enable_Overtime__c;
    /* The junction object used to link service resources to the object that the service appointment matching field references
    */
    global String FSL__Enhanced_Match_Linking_Object__c;
    global Double FSL__Evaluation_Order__c;
    /* If checked, gap between services will be based on the minimum gap field, without travel calculations.
    */
    global Boolean FSL__Is_Fixed_Gap__c;
    global Boolean FSL__Match_Constant_Boolean_Value__c;
    global Boolean FSL__Match_Skill_Level__c;
    global String FSL__Maximum_Travel_From_Home_Type__c;
    /* Determines what distance or how many minutes the resource can travel from home to reach a service
    */
    global Double FSL__Maximum_Travel_From_Home__c;
    /* Determines the minimum gap between services. If fixed gap is enabled, determines the gap between the services.
    */
    global Double FSL__Minimum_Gap__c;
    global String FSL__Object_Group_Field__c;
    global Boolean FSL__Pass_Empty_Values__c;
    global String FSL__Resource_Group_Field__c;
    /* A numeric field on the service resource to count against.
    */
    global String FSL__Resource_Property__c;
    /* The service appointment lookup field that you're matching
    */
    global String FSL__Service_Appointment_Matching_Field__c;
    /* The reference field on the linking object that is matched with the service appointment matching field
    */
    global String FSL__Service_Linking_Object_Reference_Field__c;
    global String FSL__Service_Property__c;
    global String FSL__Service_Schedule_Time_Property__c;
    global String FSL__Service_Time_Operator__c;
    global String FSL__Service_Time_Property__c;
    global String FSL__Start_of_Day__c;
    /* Determines how many minutes prior to the resource's calendar start of day will be available for travel (on the resource's expense).
When empty, any amount of travel prior to start of work day is valid.
    */
    global Double FSL__Travel_From_Home__c;
    /* Determines how many minutes following the resource's calendar end of day will be available for travel (on the resource's expense).
When empty, any amount of travel following the end of work day is valid.
    */
    global Double FSL__Travel_To_Home__c;
    /* The Date-Time field name on the Linking Object which represents its end time
    */
    global String FSL__WorkRule_End_DateTime_Field__c;
    /* The Date-Time field name on the Linking Object which represents its start time
    */
    global String FSL__WorkRule_Start_DateTime_Field__c;
    global Boolean FSL__Working_Location_Enable_Primary__c;
    global Boolean FSL__isTimephased__c;
    /* Enter a number if you want to limit the number of additional service resources that can be added to the crew. Leave empty if any number of service resources can be added.
    */
    global Double FSL__Crew_Max_Extra_Resources__c;
    global String FSL__Matching_Skills_Operator__c;
    global String FSL__Skill_Type__c;
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
    global List<FSL__Scheduling_Policy_Work_Rule__c> FSL__Scheduling_Policy_Work_Rule__r;
    global List<FSL__Work_Rule_Entry__c> FSL__Work_Rule_Entry__r;
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

    global FSL__Work_Rule__c () 
    {
    }
}