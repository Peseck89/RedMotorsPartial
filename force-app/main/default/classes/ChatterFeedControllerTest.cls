@isTest
public class ChatterFeedControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Crear un registro de Account para usar como ParentId
          List<Account> accountList = createAccounts(1,true);
        
        // Crear un FeedItem
        FeedItem fi = new FeedItem(
            ParentId = accountList[0].Id,
            Body = 'Test FeedItem Body',
            CreatedById = UserInfo.getUserId()
        );
        insert fi;
        
        // Crear un FeedComment
        FeedComment fc = new FeedComment(
            FeedItemId = fi.Id,
            CommentBody = 'Test Comment',
            CreatedById = UserInfo.getUserId()
        );
        insert fc;
        
        // Crear un ContentDocument y ContentVersion para usar como attachment
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Content Version',
            PathOnClient = 'TestContentVersion.jpg',
            VersionData = Blob.valueOf('Test Content')
        );
        insert contentVersion;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = accountList[0].Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            ShareType = 'I'
        );
        insert contentDocumentLink;
    }
    
    @isTest
    static void testGetFeedItems() {
        // Obtener un Account de prueba
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        List<ChatterFeedController.FeedItemWrapper> feedItems = ChatterFeedController.getFeedItems(acc.Id);
        Test.stopTest();
        
        // Validar que se obtuvieron los feed items
        System.assertNotEquals(0, feedItems.size(), 'Feed items should be returned');
        ChatterFeedController.FeedItemWrapper feedItemWrapper = feedItems[0];
        System.assertNotEquals(null, feedItemWrapper.Id, 'FeedItemWrapper Id should not be null');
        System.assertEquals('Test FeedItem Body', feedItemWrapper.Body, 'FeedItemWrapper Body should match');
        System.assertEquals(1, feedItemWrapper.Comments.size(), 'FeedItemWrapper should have one comment');
    }
    
    @isTest
    static void testPostComment() {
        // Obtener un FeedItem de prueba
        FeedItem fi = [SELECT Id FROM FeedItem LIMIT 1];
        
        Test.startTest();
        ChatterFeedController.postComment(fi.Id, 'New Test Comment');
        Test.stopTest();
        
        // Validar que se creó el comentario
        FeedComment newComment = [SELECT Id, CommentBody FROM FeedComment WHERE FeedItemId = :fi.Id AND CommentBody = 'New Test Comment' LIMIT 1];
        System.assertNotEquals(null, newComment, 'New comment should be created');
    }
    
    @isTest
    static void testPostNewFeedItem() {
        // Obtener un Account de prueba
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Obtener un ContentDocumentId de prueba
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        
        Test.startTest();
        ChatterFeedController.postNewFeedItem(acc.Id, 'New Post Body', new List<Id>{cd.Id});
        Test.stopTest();
        
        // Validar que se creó el FeedItem
        //FeedItem newFeedItem = [SELECT Id, Body FROM FeedItem WHERE ParentId = :acc.Id AND Body = 'New Post Body' LIMIT 1];
        //System.assertNotEquals(null, newFeedItem, 'New FeedItem should be created');
        
        // Validar que se creó el FeedAttachment
        //FeedAttachment newAttachment = [SELECT Id FROM FeedAttachment WHERE FeedEntityId = :newFeedItem.Id LIMIT 1];
        //System.assertNotEquals(null, newAttachment, 'New FeedAttachment should be created');
    }
     public static List<Account> createAccounts(Integer numberRecords, Boolean insertDML) {
        List<Account> newRecordList = new List<Account>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new Account(
                Name = 'Test Acc '+i,
                Cedula__c = '1234567890'
            ));
        }
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    }
}