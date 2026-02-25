declare module "@salesforce/apex/ChatterFeedController.getFeedItems" {
  export default function getFeedItems(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChatterFeedController.postComment" {
  export default function postComment(param: {feedItemId: any, commentBody: any}): Promise<any>;
}
declare module "@salesforce/apex/ChatterFeedController.postNewFeedItem" {
  export default function postNewFeedItem(param: {parentId: any, postBody: any, attachmentIds: any}): Promise<any>;
}
