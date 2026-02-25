declare module "@salesforce/apex/QuoteController.getWorkOrderRelated" {
  export default function getWorkOrderRelated(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteController.getDefaults" {
  export default function getDefaults(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteController.changeCurrencygtQLIs" {
  export default function changeCurrencygtQLIs(param: {workOrder: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteController.getQuoteLineItems" {
  export default function getQuoteLineItems(param: {workOrder: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteController.saveWorkLineItems" {
  export default function saveWorkLineItems(param: {listTosave: any, workOrder: any, quoteId: any, oppId: any, enviarACaso: any}): Promise<any>;
}
