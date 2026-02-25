declare module "@salesforce/apex/TrabajoQuoteController.archivarTarea" {
  export default function archivarTarea(param: {quoteId: any, tareaId: any, recordatorio: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoQuoteController.updateTareaPrioridad" {
  export default function updateTareaPrioridad(param: {quoteId: any, tareaId: any, prioridad: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoQuoteController.getTrabajos" {
  export default function getTrabajos(param: {quoteId: any, tareaId: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoQuoteController.saveTrabajo" {
  export default function saveTrabajo(param: {trabajo: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoQuoteController.deleteSubtrabajo" {
  export default function deleteSubtrabajo(param: {subtrabajoId: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoQuoteController.deleteTrabajo" {
  export default function deleteTrabajo(param: {trabajoId: any, quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoQuoteController.getUTSTipoTrabajo" {
  export default function getUTSTipoTrabajo(param: {idTipoTrabajo: any}): Promise<any>;
}
declare module "@salesforce/apex/TrabajoQuoteController.saveSubtrabajos" {
  export default function saveSubtrabajos(param: {tareaId: any, trabajoId: any, tipoDeTrabajoId: any, subtrabajos: any, quoteId: any, prioridad: any, tipodecargo: any}): Promise<any>;
}
