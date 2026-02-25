declare module "@salesforce/apex/TipoCargoApprovalController.hasPendingCentroCostoApproval" {
  export default function hasPendingCentroCostoApproval(param: {workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/TipoCargoApprovalController.getInternalTiposCargo" {
  export default function getInternalTiposCargo(param: {workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/TipoCargoApprovalController.submitForApproval" {
  export default function submitForApproval(param: {workOrderId: any, selectedTipoCargoIds: any, comment: any}): Promise<any>;
}
