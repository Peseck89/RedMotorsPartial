public class FileContentService {

    public class FileInfo {
        public String url { get; set; }
        public String fileType { get; set; }
        public String relatedObjectId { get; set; }

        public FileInfo(String url, String fileType, String relatedObjectId) {
            this.url = url;
            this.fileType = fileType;
            this.relatedObjectId = relatedObjectId;
        }
    }
    
    public void deleteContentDistributions(List<Id> contentDocumentIds) {
        if (contentDocumentIds.isEmpty()) {
            return;
        }
    
        // Query the existing ContentDistributions related to the ContentDocumentIds
        List<ContentDistribution> distributionsToDelete = [
            SELECT Id
            FROM ContentDistribution
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
    
        // Delete the found ContentDistributions
        if (!distributionsToDelete.isEmpty()) {
            delete distributionsToDelete;
        }
    }    

    public void saveContentDistributions(List<Id> contentDocumentIds) {
        if (contentDocumentIds.isEmpty()) {
            return;
        }

        deleteContentDistributions(contentDocumentIds);

        List<ContentVersion> contentVersions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            AND IsLatest = true
        ];

        if (contentVersions.isEmpty()) {
            return;
        }

        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();

        for (ContentVersion cv : contentVersions) {
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Public File Link';
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser = true;
            cd.PreferencesLinkLatestVersion = true;
            cd.PreferencesNotifyOnVisit = false;
            cd.PreferencesPasswordRequired = false;
            contentDistributions.add(cd);
        }

        insert contentDistributions;
    }

    public Map<Id, List<FileInfo>> getFileUrls(List<Id> objectIds) {
        Map<Id, List<FileInfo>> fileInfoMap = new Map<Id, List<FileInfo>>();

        List<ContentDocumentLink> ctlinks = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :objectIds
        ];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink ctl : ctlinks) {
            contentDocumentIds.add(ctl.ContentDocumentId);
        }

        if (contentDocumentIds.isEmpty()) {
            return fileInfoMap;
        }

        List<ContentDistribution> contentDistributions = [
            SELECT ContentDocumentId, ContentDownloadUrl, ContentVersion.FileType
            FROM ContentDistribution
            WHERE ContentDocumentId IN :contentDocumentIds
        ];

        for (ContentDocumentLink ctl : ctlinks) {
            List<FileInfo> fileInfos = new List<FileInfo>();

            for (ContentDistribution cd : contentDistributions) {
                if (cd.ContentDocumentId == ctl.ContentDocumentId) {
                    FileInfo fileInfo = new FileInfo(cd.ContentDownloadUrl, cd.ContentVersion.FileType, ctl.LinkedEntityId);
                    fileInfos.add(fileInfo);
                }
            }

            if (!fileInfoMap.containsKey(ctl.LinkedEntityId)) {
                fileInfoMap.put(ctl.LinkedEntityId, fileInfos);
            } else {
                fileInfoMap.get(ctl.LinkedEntityId).addAll(fileInfos);
            }
        }

        return fileInfoMap;
    }

    public void saveJsonToObjects(Map<Id, List<FileInfo>> fileInfoMap, String objectType) {
        for (Id objectId : fileInfoMap.keySet()) {
            List<FileInfo> fileInfoList = fileInfoMap.get(objectId);
            String filesJson = JSON.serialize(fileInfoList);

            if(objectType == 'tiposDeTrabajoCaso__c') {
                tiposDeTrabajoCaso__c relatedObject = new tiposDeTrabajoCaso__c();
                relatedObject.id = objectId;
                relatedObject.filesJson__c = filesJson;
                update relatedObject;
            }
            if(objectType == 'Subtipo_de_trabajo_del_caso__c') {
                Subtipo_de_trabajo_del_caso__c relatedObject = new Subtipo_de_trabajo_del_caso__c();
                relatedObject.id = objectId;
                relatedObject.filesJson__c = filesJson;
                update relatedObject;
            }
        }
    }

    public void processContentFiles(List<Id> objectIds, String objectType) {
        List<ContentDocumentLink> ctlinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :objectIds
        ];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink link : ctlinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        saveContentDistributions(contentDocumentIds);

        Map<Id, List<FileInfo>> fileInfoMap = getFileUrls(objectIds);
        saveJsonToObjects(fileInfoMap, objectType);
    }

    // New method to generate nested JSON with parent and child file details
    public class FileJson {
        public String name;
        public String url;
        public String relatedObjectId;
        public String fileType;
        public List<FileJson> subTipoTrabajos;

        public FileJson(String name, String url, String relatedObjectId, String fileType) {
            this.name = name;
            this.url = url;
            this.relatedObjectId = relatedObjectId;
            this.fileType = fileType;
            this.subTipoTrabajos = new List<FileJson>();
        }
    }

    public String getNestedFileJson(String parentId) {
        // Query the parent and related child records
        List<tiposDeTrabajoCaso__c> parentRecords = [
            SELECT Tipotrabajo__r.Name, filesJson__c,
            (SELECT Name, filesJson__c FROM Subtipos_de_trabajos_del_caso__r)
            FROM tiposDeTrabajoCaso__c
            WHERE Id = :parentId
        ];
    
        if (parentRecords.isEmpty()) {
            return '[]'; // Return empty array if no records found
        }
    
        tiposDeTrabajoCaso__c parentRecord = parentRecords[0];
    
        // Parse the parent filesJson__c into List<FileJson> objects
        List<FileJson> parentFiles = (List<FileJson>) JSON.deserialize(parentRecord.filesJson__c, List<FileJson>.class);
    
        // Create the parent JSON object
        FileJson parentJson = new FileJson(
            parentRecord.Tipotrabajo__r.Name,
            null, // URL will be populated later as an array
            parentRecord.Id, // Related object ID
            null  // Initially set to null; we'll populate later
        );
    
        // Add all parent files to the parentJson's files list
        List<FileJson> filesList = new List<FileJson>();
        for (FileJson file : parentFiles) {
            filesList.add(new FileJson(
                null,  // Name can be set as null; it's not used in this context
                file.url,
                file.relatedObjectId,
                file.fileType
            ));
        }
        parentJson.subTipoTrabajos = filesList; // Populate the files list
    
        // Initialize the subTipoTrabajos array
        parentJson.subTipoTrabajos = new List<FileJson>();
    
        // Add child records to the "subTipoTrabajos" list
        for (Subtipo_de_trabajo_del_caso__c childRecord : parentRecord.Subtipos_de_trabajos_del_caso__r) {
            if(childRecord.filesJson__c != null){
                List<FileJson> childFiles = (List<FileJson>) JSON.deserialize(childRecord.filesJson__c, List<FileJson>.class);
                for (FileJson childFile : childFiles) {
                    FileJson childJson = new FileJson(
                        childRecord.Name, // Use the child record's name
                        childFile.url,
                        childFile.relatedObjectId,
                        childFile.fileType
                    );
                    parentJson.subTipoTrabajos.add(childJson); // Add to parentJson's subTipoTrabajos
                }
            }
        }
    
        // Create the final output structure
        Map<String, Object> output = new Map<String, Object>();
        output.put('relatedObjectId', parentJson.relatedObjectId);
        output.put('name', parentJson.name);
        output.put('files', filesList);
        output.put('subTipoTrabajos', parentJson.subTipoTrabajos);
    
        // Serialize the nested structure into JSON
        return JSON.serialize(output);
    }
    
    
    
}