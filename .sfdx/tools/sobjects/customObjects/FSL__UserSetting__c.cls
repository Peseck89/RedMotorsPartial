// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class FSL__UserSetting__c {
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
    global String FSL__Date_Horizon_Properties__c;
    global Double FSL__DaysInUtilizationView__c;
    global String FSL__DefaultLeftPanel__c;
    global Double FSL__Drag_Na_Duration__c;
    global String FSL__Drag_Na_Label__c;
    global String FSL__Drag_Na_Type__c;
    global String FSL__FavoriteTerritories__c;
    global Boolean FSL__Filter_Candidates__c;
    global String FSL__Filters__c;
    global FSL__GanttPalette__c FSL__Gantt_Palette__r;
    global Id FSL__Gantt_Palette__c;
    global FSL__Scheduling_Policy__c FSL__Gantt_Policy__r;
    global Id FSL__Gantt_Policy__c;
    global Double FSL__Gantt_View_Finish_Hour__c;
    global Double FSL__Gantt_View_Start_Hour__c;
    global Boolean FSL__Highlight_Weekeneds__c;
    global Boolean FSL__Include_Weekends__c;
    global String FSL__Invisible_Polygons__c;
    global Double FSL__Left_Panel_Width_Percentage__c;
    global Boolean FSL__Load_On_Today__c;
    global Boolean FSL__Lock_Gantt__c;
    global Double FSL__Longterm_Min_Absence_Duration__c;
    global Double FSL__Longterm_Min_Service_Duration__c;
    global Double FSL__Longterm_Num_Of_Months__c;
    global Boolean FSL__Map_Markers_Cluster__c;
    global String FSL__Map_Object_Markers__c;
    global String FSL__Map_Reports__c;
    global Boolean FSL__Match_Gantt_Dates__c;
    global String FSL__Resource_Filter__c;
    global String FSL__Resource_Row_Height__c;
    global Double FSL__Scheduling_horizon_limit__c;
    global String FSL__Selected_List_View__c;
    global String FSL__ServiceListColoring__c;
    global Double FSL__Services_List_Height_Percentage__c;
    global String FSL__Services_Per_Page__c;
    global Boolean FSL__ShowFavoriteTerritoriesTab__c;
    global Boolean FSL__Show_Only_MDT_In_Longterm__c;
    global Boolean FSL__Show_Orphan_Services__c;
    global String FSL__Skills_Logic_Operator__c;
    global String FSL__Toggled_Territories__c;
    global User FSL__User__r;
    global Id FSL__User__c;
    global String FSL__Utilization_Properties__c;
    global String FSL__View_Capacity_Type__c;
    global Boolean FSL__HorizontalScrolling__c;
    global String FSL__Absence_Overlap_Height__c;
    global String FSL__Filter_Resources_BySkills__c;
    global Boolean FSL__Show_Calendar_Weeks__c;
    global String FSL__Optimization_Request_Filter_Field__c;
    global Boolean FSL__HideSchedulingAgentIntro__c;
    global String FSL__LastGanttView__c;
    global Datetime FSL__LastViewedGanttDate__c;
    global String FSL__LastViewedList__c;
    global String FSL__FirstDayOfWeek__c;
    global Boolean FSL__MatchGanttServiceTerritories__c;
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
    global List<FSL__User_Setting_Territory__c> FSL__User_Setting_Territory_UserSettings__r;
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

    global FSL__UserSetting__c () 
    {
    }
}