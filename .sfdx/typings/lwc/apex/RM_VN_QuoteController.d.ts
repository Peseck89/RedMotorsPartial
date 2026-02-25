declare module "@salesforce/apex/RM_VN_QuoteController.getQuotes" {
  export default function getQuotes(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_QuoteController.addVehicle" {
  export default function addVehicle(param: {oppId: any, oppProdIntId: any, prodXBodegaId: any, existingQuoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_QuoteController.addLineItem" {
  export default function addLineItem(param: {quoteId: any, prodXBodId: any, qliId: any, esRegalia: any, esExtra: any, productType: any, productAlias: any, productQuantity: any, productUnitPrice: any}): Promise<any>;
}
