import { LightningElement, api, wire, track } from 'lwc';
import getFeedItems from '@salesforce/apex/ChatterFeedController.getFeedItems';
import postComment from '@salesforce/apex/ChatterFeedController.postComment';
import postNewFeedItem from '@salesforce/apex/ChatterFeedController.postNewFeedItem';
import { refreshApex } from '@salesforce/apex';

export default class ChatterFeed extends LightningElement {
    @api recordId;
    @track feedItems = [];
    @track newComment = '';
    @track newPost = '';
    @track newAttachmentIds = [];
    wiredFeedItemsResult;

    @wire(getFeedItems, { recordId: '$recordId' })
    wiredFeedItems(result) {
        this.wiredFeedItemsResult = result;
        const { error, data } = result;
        if (data) {
            console.log('Feed Items:', data); // Log the feed items to verify the data structure
            this.feedItems = data.map(item => {
                return {
                    ...item,
                    Attachments: item.Attachments ? item.Attachments.map(attachment => ({
                        ...attachment,
                        Url: `/sfc/servlet.shepherd/version/download/${attachment.RecordId}`
                    })) : [],
                    Comments: item.Comments || []
                };
            });
        } else if (error) {
            console.error('Error:', error);
        }
    }

    handleCommentChange(event) {
        this.newComment = event.target.value;
    }

    handlePostChange(event) {
        this.newPost = event.target.value;
    }

    handlePostComment(event) {
        const feedItemId = event.target.dataset.id;
        postComment({ feedItemId: feedItemId, commentBody: this.newComment })
            .then(() => {
                this.newComment = '';
                return refreshApex(this.wiredFeedItemsResult);
            })
            .catch(error => {
                console.error('Error posting comment:', error);
            });
    }

    handlePostNew() {
        postNewFeedItem({ parentId: this.recordId, postBody: this.newPost, attachmentIds: this.newAttachmentIds })
            .then(() => {
                this.newPost = '';
                this.newAttachmentIds = [];
                return refreshApex(this.wiredFeedItemsResult);
            })
            .catch(error => {
                console.error('Error posting new feed item:', error);
            });
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach(file => {
            this.newAttachmentIds.push(file.documentId);
        });
    }

    get hasFeedItems() {
        return this.feedItems && this.feedItems.length > 0;
    }
    toggleCommentSection(event) {
        const itemId = event.target.dataset.id;
        const item = this.feedItems.find(feedItem => feedItem.Id === itemId);
        item.showNewComment = !item.showNewComment;
        this.feedItems = [...this.feedItems];
    }
}