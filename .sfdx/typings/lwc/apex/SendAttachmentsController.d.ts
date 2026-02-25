declare module "@salesforce/apex/SendAttachmentsController.getOpportunity" {
  export default function getOpportunity(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/SendAttachmentsController.getUserList" {
  export default function getUserList(): Promise<any>;
}
declare module "@salesforce/apex/SendAttachmentsController.getAttachments" {
  export default function getAttachments(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/SendAttachmentsController.sendEmail" {
  export default function sendEmail(param: {oppId: any, userNames: any, attachmentIds: any, ccEmailIdList: any}): Promise<any>;
}
