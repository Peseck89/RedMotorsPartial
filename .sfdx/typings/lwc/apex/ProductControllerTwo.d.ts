declare module "@salesforce/apex/ProductControllerTwo.getMOAccess" {
  export default function getMOAccess(): Promise<any>;
}
declare module "@salesforce/apex/ProductControllerTwo.getQolis" {
  export default function getQolis(param: {listTosave: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductControllerTwo.searchMOByQuote" {
  export default function searchMOByQuote(param: {productType: any, productName: any, searchCriteria: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductControllerTwo.searchProductxBodegaxQuote" {
  export default function searchProductxBodegaxQuote(param: {productType: any, productName: any, searchCriteria: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductControllerTwo.saveQuoteLineItems" {
  export default function saveQuoteLineItems(param: {listTosave: any, quoteId: any, saveOnline: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductControllerTwo.deleteQlis" {
  export default function deleteQlis(param: {listToDelete: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductControllerTwo.getAvailabilityByQuote" {
  export default function getAvailabilityByQuote(param: {listTosave: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductControllerTwo.getServereOrderResponse" {
  export default function getServereOrderResponse(param: {order: any}): Promise<any>;
}
