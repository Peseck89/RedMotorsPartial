declare module "@salesforce/apex/WoliGridController2.getTipoTrabajoPorMO" {
  export default function getTipoTrabajoPorMO(param: {product2Id: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.getSoftlandPriceReferences" {
  export default function getSoftlandPriceReferences(param: {productCode: any, empresaFactura: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.getSoftlandLocations" {
  export default function getSoftlandLocations(param: {productCode: any, empresaFactura: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.searchProducts" {
  export default function searchProducts(param: {productType: any, queryValue: any, workOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.getWolis" {
  export default function getWolis(param: {listTosave: any, workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.saveWolis" {
  export default function saveWolis(param: {jsonString: any, workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.saveQuantities" {
  export default function saveQuantities(param: {jsonString: any, workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.deleteWolis" {
  export default function deleteWolis(param: {workorderIds: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.getTiposDeTrabajo" {
  export default function getTiposDeTrabajo(param: {workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.setPublicFileWO" {
  export default function setPublicFileWO(param: {contentIds: any, workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.consultarDisponibilidad" {
  export default function consultarDisponibilidad(param: {jsonString: any, workorder: any, workOrderNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.requestDespacho" {
  export default function requestDespacho(param: {workOrderNumber: any, notAvailableIds: any, selectedIDList: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.requestApartar" {
  export default function requestApartar(param: {workOrderNumber: any, notAvailableIds: any, selectedIDList: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.requestDevolucion" {
  export default function requestDevolucion(param: {workOrderNumber: any, devolutionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.sendPDF" {
  export default function sendPDF(param: {workorder: any, email: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.sendSC" {
  export default function sendSC(param: {departamento: any, prioridad: any, anticipo: any, quoteId: any, idsToSC: any}): Promise<any>;
}
declare module "@salesforce/apex/WoliGridController2.sendSCWO" {
  export default function sendSCWO(param: {departamento: any, prioridad: any, anticipo: any, workOrderId: any, idsToSC: any}): Promise<any>;
}
