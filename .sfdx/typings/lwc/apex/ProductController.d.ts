declare module "@salesforce/apex/ProductController.actualizaAseguradora" {
  export default function actualizaAseguradora(param: {recordId: any, aseguradoraId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.actualizaCentroCostos" {
  export default function actualizaCentroCostos(param: {recordId: any, centroCostosId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.consultaAseguradora" {
  export default function consultaAseguradora(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.consultaCentroDeCostos" {
  export default function consultaCentroDeCostos(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.getPriceAccess" {
  export default function getPriceAccess(): Promise<any>;
}
declare module "@salesforce/apex/ProductController.getBetaAccess" {
  export default function getBetaAccess(): Promise<any>;
}
declare module "@salesforce/apex/ProductController.getWolis" {
  export default function getWolis(param: {listTosave: any, workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.searchMO" {
  export default function searchMO(param: {productType: any, productName: any, workOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.searchProductxBodega" {
  export default function searchProductxBodega(param: {productType: any, productName: any, workOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.saveWorkLineItems" {
  export default function saveWorkLineItems(param: {listTosave: any, workorder: any, saveOnline: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.deleteWolis" {
  export default function deleteWolis(param: {listToDelete: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.syncOrderWithSoftland" {
  export default function syncOrderWithSoftland(param: {workorder: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.setSyncFlag" {
  export default function setSyncFlag(param: {workorder: any, validate: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.getAvailability" {
  export default function getAvailability(param: {listTosave: any, workorder: any, workOrderNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.getServereOrderResponse" {
  export default function getServereOrderResponse(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.lastSyncDate" {
  export default function lastSyncDate(param: {WorkorderId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.getLastResponses" {
  export default function getLastResponses(param: {orderNumber: any, compania: any, workOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.setSoftlandConfirmation" {
  export default function setSoftlandConfirmation(param: {updateType: any, value: any, workOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductController.getWorkOrderDataTableSetting" {
  export default function getWorkOrderDataTableSetting(param: {developerName: any}): Promise<any>;
}
