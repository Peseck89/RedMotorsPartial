declare module "@salesforce/apex/ct_otRedis_ctrl.getWorkOrderData" {
  export default function getWorkOrderData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_otRedis_ctrl.saveDetalleAsesor" {
  export default function saveDetalleAsesor(param: {caseId: any, detalleAsesor: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_otRedis_ctrl.getAsset" {
  export default function getAsset(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_otRedis_ctrl.getTrabajos" {
  export default function getTrabajos(param: {woId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_otRedis_ctrl.getPresupuesto" {
  export default function getPresupuesto(param: {woId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_otRedis_ctrl.updateAccountComment" {
  export default function updateAccountComment(param: {accountId: any, comment: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_otRedis_ctrl.updateAssetComment" {
  export default function updateAssetComment(param: {assetId: any, comment: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_otRedis_ctrl.getWorkOrderLineItems" {
  export default function getWorkOrderLineItems(param: {casoId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_otRedis_ctrl.getCaseIdFromWorkOrder" {
  export default function getCaseIdFromWorkOrder(param: {workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_otRedis_ctrl.getWorkOrderDetails" {
  export default function getWorkOrderDetails(param: {woId: any}): Promise<any>;
}
