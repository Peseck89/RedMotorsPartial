declare module "@salesforce/apex/ct_casoredi_ctrl.getCaseData" {
  export default function getCaseData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getOwnerName" {
  export default function getOwnerName(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.saveCombustibleData" {
  export default function saveCombustibleData(param: {caseId: any, tipoCombustible: any, nivelCombustible: any, porcentajeCarga: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.savePriorityData" {
  export default function savePriorityData(param: {caseId: any, prioridad: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getAssetWarranty" {
  export default function getAssetWarranty(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getUltimoComentario" {
  export default function getUltimoComentario(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getOpp" {
  export default function getOpp(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.updateComentario" {
  export default function updateComentario(param: {recordId: any, comentario: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getHistorialFechas" {
  export default function getHistorialFechas(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.updateCaseFacturacion" {
  export default function updateCaseFacturacion(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.saveDetalleAsesor" {
  export default function saveDetalleAsesor(param: {caseId: any, detalleAsesor: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.saveNumeroGuia" {
  export default function saveNumeroGuia(param: {caseId: any, numGuia: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.saveColorGuia" {
  export default function saveColorGuia(param: {caseId: any, colorDeGuia: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.saveLavado" {
  export default function saveLavado(param: {caseId: any, ReqLavado: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.saveObjetoValor" {
  export default function saveObjetoValor(param: {caseId: any, objValor: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.saveObjetoValorText" {
  export default function saveObjetoValorText(param: {caseId: any, objValorText: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.saveRepuestos" {
  export default function saveRepuestos(param: {caseId: any, LlevarseRepuestos: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.updateCaseKilometraje" {
  export default function updateCaseKilometraje(param: {caseId: any, kilometraje: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.updateAssetComment" {
  export default function updateAssetComment(param: {assetId: any, comment: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getCaseOrders" {
  export default function getCaseOrders(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getAsset" {
  export default function getAsset(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getTrabajosOld" {
  export default function getTrabajosOld(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getTrabajos" {
  export default function getTrabajos(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getWO" {
  export default function getWO(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.updateCaseStatusDetail" {
  export default function updateCaseStatusDetail(param: {caseId: any, statusDetail: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_casoredi_ctrl.getWorkOrdersByCaseId" {
  export default function getWorkOrdersByCaseId(param: {caseId: any}): Promise<any>;
}
