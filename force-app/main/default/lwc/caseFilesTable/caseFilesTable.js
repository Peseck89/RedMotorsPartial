import { LightningElement, api, wire, track } from 'lwc';
import getRelatedFiles from '@salesforce/apex/CaseFilesController.getRelatedFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseFilesTable extends LightningElement {
    @api recordId;
    files = [];
    @track isModalOpen = false;
    selectedFileId;

    @wire(getRelatedFiles, { caseId: '$recordId' })
    wiredFiles({ error, data }) {
        if (data) {
            this.files = data.map(file => {
                if (file.ContentDocument.FileType !== 'PDF') {
                    return {
                        id: file.ContentDocumentId,
                        preview: `/sfc/servlet.shepherd/version/download/${file.ContentDocument.LatestPublishedVersionId}`,
                        title: file.ContentDocument.Title,
                        fileType: file.ContentDocument.FileType
                    };
                } else {
                    return {
                        id: file.ContentDocumentId,
                        preview: `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${file.ContentDocument.LatestPublishedVersionId}`,
                        title: file.ContentDocument.Title,
                        fileType: file.ContentDocument.FileType
                    };
                }
            });

        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading files',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    handleImageClick(event) {
        this.selectedFileId = event.target.dataset.id;
        this.isModalOpen = true;
        console.log('Image clicked:', this.selectedFileId);
        console.log('Modal Open:', this.isModalOpen);
    }

    handleModalClose() {
        this.isModalOpen = false;
        console.log('Modal Closed:', this.isModalOpen);
    }
}