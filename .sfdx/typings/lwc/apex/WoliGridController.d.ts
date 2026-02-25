declare module "@salesforce/apex/WoliGridController.showMonedaButton" {
  export default function showMonedaButton(param: {workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.getSoftlandPriceReferences" {
  export default function getSoftlandPriceReferences(param: {productCode: any, empresaFactura: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.getSoftlandLocations" {
  export default function getSoftlandLocations(param: {productCode: any, empresaFactura: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.searchProducts" {
  export default function searchProducts(param: {productType: any, queryValue: any, workOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.getWolis" {
  export default function getWolis(param: {listTosave: any, workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.saveWolis" {
  export default function saveWolis(param: {jsonString: any, workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.saveQuantities" {
  export default function saveQuantities(param: {jsonString: any, workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.deleteWolis" {
  export default function deleteWolis(param: {workorderIds: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.getTiposDeTrabajo" {
  export default function getTiposDeTrabajo(param: {workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.setPublicFileWO" {
  export default function setPublicFileWO(param: {contentIds: any, workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.consultarDisponibilidad" {
  export default function consultarDisponibilidad(param: {jsonString: any, workorder: any, workOrderNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.requestDespacho" {
  export default function requestDespacho(param: {workOrderNumber: any, notAvailableIds: any, selectedIDList: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.requestApartar" {
  export default function requestApartar(param: {workOrderNumber: any, notAvailableIds: any, selectedIDList: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.requestDevolucion" {
  export default function requestDevolucion(param: {workOrderNumber: any, devolutionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.sendPDF" {
  export default function sendPDF(param: {workorder: any, email: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.sendSC" {
  export default function sendSC(param: {departamento: any, prioridad: any, anticipo: any, quoteId: any, idsToSC: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController.sendSCWO" {
  export default function sendSCWO(param: {departamento: any, prioridad: any, anticipo: any, workOrderId: any, idsToSC: any}): Promise<any>;
}
