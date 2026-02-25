declare module "@salesforce/apex/QuoliGridController.searchProducts" {
  export default function searchProducts(param: {queryValue: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.getQuolis" {
  export default function getQuolis(param: {listTosave: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.saveQuolis" {
  export default function saveQuolis(param: {jsonString: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.deleteQuolis" {
  export default function deleteQuolis(param: {quoteIds: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.saveQuantities" {
  export default function saveQuantities(param: {jsonString: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.setPublicFile" {
  export default function setPublicFile(param: {contentIds: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.getDepartamentos" {
  export default function getDepartamentos(): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.consultarDisponibilidad" {
  export default function consultarDisponibilidad(param: {jsonString: any, quoteId: any, quoteNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.requestDespacho" {
  export default function requestDespacho(param: {quoteNumber: any, notAvailableIds: any, selectedIDList: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.requestApartar" {
  export default function requestApartar(param: {quoteNumber: any, notAvailableIds: any, selectedIDList: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.requestDevolucion" {
  export default function requestDevolucion(param: {quoteNumber: any, devolutionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoliGridController.sendPDF" {
  export default function sendPDF(param: {quoteId: any, email: any}): Promise<any>;
}
