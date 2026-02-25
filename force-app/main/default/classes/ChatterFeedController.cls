public without sharing class ChatterFeedController {
    @AuraEnabled(cacheable=true)
    public static List<FeedItemWrapper> getFeedItems(Id recordId) {
        List<FeedItemWrapper> feedItemWrappers = new List<FeedItemWrapper>();
        
        // Consulta para obtener los feed items
        List<FeedItem> feedItems = [SELECT Id, Body, CreatedBy.Name, CreatedDate FROM FeedItem WHERE ParentId = :recordId];
        
        if (feedItems.isEmpty()) {
            System.debug('No feed items found for recordId: ' + recordId);
        }
        
        // Obtener los IDs de los feed items
        Set<Id> feedItemIds = new Set<Id>();
        for (FeedItem fi : feedItems) {
            feedItemIds.add(fi.Id);
        }
        
        // Consulta para obtener los attachments de los feed items
        Map<Id, List<FeedAttachment>> attachmentsMap = new Map<Id, List<FeedAttachment>>();
        for (FeedAttachment att : [SELECT Id,RecordId, FeedEntityId, Title FROM FeedAttachment WHERE FeedEntityId IN :feedItemIds]) {
            if (!attachmentsMap.containsKey(att.FeedEntityId)) {
                attachmentsMap.put(att.FeedEntityId, new List<FeedAttachment>());
            }
            attachmentsMap.get(att.FeedEntityId).add(att);
        }
        
        // Consulta para obtener los comentarios de los feed items
        Map<Id, List<FeedComment>> commentsMap = new Map<Id, List<FeedComment>>();
        for (FeedComment comment : [SELECT Id, FeedItemId, CommentBody,CreatedDate, CreatedBy.Name FROM FeedComment WHERE FeedItemId IN :feedItemIds]) {
            if (!commentsMap.containsKey(comment.FeedItemId)) {
                commentsMap.put(comment.FeedItemId, new List<FeedComment>());
            }
            commentsMap.get(comment.FeedItemId).add(comment);
        }
        
        // Construir los wrappers de feed items
        for (FeedItem fi : feedItems) {
            FeedItemWrapper fiw = new FeedItemWrapper();
            fiw.Id = fi.Id;
            fiw.Body = fi.Body;
            fiw.CreatedByName = fi.CreatedBy.Name;
            fiw.CreatedDate = fi.CreatedDate;
            fiw.Attachments = attachmentsMap.get(fi.Id) != null ? attachmentsMap.get(fi.Id) : new List<FeedAttachment>();
            fiw.Comments = commentsMap.get(fi.Id) != null ? commentsMap.get(fi.Id) : new List<FeedComment>();
            feedItemWrappers.add(fiw);
        }
        
        return feedItemWrappers;
    }
    
    @AuraEnabled
    public static void postComment(Id feedItemId, String commentBody) {
        FeedComment comment = new FeedComment();
        comment.FeedItemId = feedItemId;
        comment.CommentBody = commentBody;
        insert comment;
    }
    
    @AuraEnabled
    public static void postNewFeedItem(Id parentId, String postBody, List<Id> attachmentIds) {
        System.debug('parentId '+parentId);
        System.debug('postBody '+postBody);
        System.debug('attachmentIds '+attachmentIds);
        FeedItem newPost = new FeedItem();
        newPost.ParentId = parentId;
        newPost.Body = postBody;
        insert newPost;
        
        // Asegúrate de que el FeedItem se insertó correctamente
        if (newPost.Id != null && !attachmentIds.isEmpty()) {
            List<ContentDocument> listContentDocument = [Select Id,LatestPublishedVersionId from ContentDocument Where ID IN:attachmentIds];
            List<FeedAttachment> feedAList = new List<FeedAttachment>();
            for (ContentDocument cd : listContentDocument) {
                FeedAttachment fa = new FeedAttachment();
                fa.FeedEntityId = newPost.Id;
                fa.Type = 'Content';
                fa.RecordId = cd.LatestPublishedVersionId;
                feedAList.add(fa);
            }
            insert feedAList;
        }
    } 
    public class FeedItemWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Body;
        @AuraEnabled public String CreatedByName;
        @AuraEnabled public DateTime CreatedDate;
        @AuraEnabled public List<FeedAttachment> Attachments;
        @AuraEnabled public List<FeedComment> Comments;
    }
}