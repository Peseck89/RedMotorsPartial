declare module "@salesforce/apex/TrabajoController.getWorkOrder" {
  export default function getWorkOrder(param: {casoId: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoController.getTrabajos" {
  export default function getTrabajos(param: {casoId: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoController.saveTrabajo" {
  export default function saveTrabajo(param: {trabajo: any, casoId: any, workOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoController.deleteSubtrabajo" {
  export default function deleteSubtrabajo(param: {subtrabajoId: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoController.deleteTrabajo" {
  export default function deleteTrabajo(param: {trabajoId: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoController.getUTSTipoTrabajo" {
  export default function getUTSTipoTrabajo(param: {idTipoTrabajo: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoController.saveSubtrabajos" {
  export default function saveSubtrabajos(param: {trabajoId: any, tipoDeTrabajoId: any, subtrabajos: any, caseId: any, workOrderId: any, prioridad: any, tipodecargo: any, aseguradora: any, centrodecosto: any}): Promise<any>;
}
