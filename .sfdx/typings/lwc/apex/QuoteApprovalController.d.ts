declare module "@salesforce/apex/QuoteApprovalController.hasPendingApproval" {
  export default function hasPendingApproval(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteApprovalController.validateQuoteData" {
  export default function validateQuoteData(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteApprovalController.submitForApproval" {
  export default function submitForApproval(param: {quoteId: any, comentarios: any}): Promise<any>;
}
