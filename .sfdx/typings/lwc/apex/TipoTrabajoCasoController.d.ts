declare module "@salesforce/apex/TipoTrabajoCasoController.accountValidation" {
  export default function accountValidation(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/TipoTrabajoCasoController.insertTipoDelCasoDeTrabajo" {
  export default function insertTipoDelCasoDeTrabajo(param: {caseId: any, workOrderId: any, aseguradoraId: any, centroCostoId: any, tipoDeCargo: any, sugerenciaTaller: any, comments: any, tipoDeTrabajo: any, aprobador: any, categoriaDePresupuesto: any}): Promise<any>;
}
declare module "@salesforce/apex/TipoTrabajoCasoController.getWorkOrders" {
  export default function getWorkOrders(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/TipoTrabajoCasoController.getWorkOrder" {
  export default function getWorkOrder(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/TipoTrabajoCasoController.getTipoTrabajo" {
  export default function getTipoTrabajo(param: {trabajoId: any}): Promise<any>;
}
declare module "@salesforce/apex/TipoTrabajoCasoController.getAseguradora" {
  export default function getAseguradora(param: {trabajoId: any}): Promise<any>;
}
declare module "@salesforce/apex/TipoTrabajoCasoController.existsWorkOrder" {
  export default function existsWorkOrder(param: {caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/TipoTrabajoCasoController.saveWorkLineItems" {
  export default function saveWorkLineItems(param: {listTosave: any, workorder: any, caseid: any, tipodetrabajoid: any, tipodetrabajocaso: any, origin: any, tipodecargo: any, centrodecosto: any, aseguradora: any, aliasGenerico: any}): Promise<any>;
}
