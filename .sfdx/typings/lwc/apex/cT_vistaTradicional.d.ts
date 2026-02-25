declare module "@salesforce/apex/cT_vistaTradicional.getWorkSteps" {
  export default function getWorkSteps(param: {statuses: any, territories: any, mechanicId: any, serviceType: any, workOrderNumber: any, caseNumber: any, plate: any, vin: any, creationDateFrom: any, creationDateTo: any, pageNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_vistaTradicional.getTalleres" {
  export default function getTalleres(): Promise<any>;
}
declare module "@salesforce/apex/cT_vistaTradicional.getTalleresForSelect" {
  export default function getTalleresForSelect(): Promise<any>;
}
declare module "@salesforce/apex/cT_vistaTradicional.getOrdenes" {
  export default function getOrdenes(): Promise<any>;
}
declare module "@salesforce/apex/cT_vistaTradicional.getContact" {
  export default function getContact(): Promise<any>;
}
declare module "@salesforce/apex/cT_vistaTradicional.updateRecordMeca" {
  export default function updateRecordMeca(param: {idRegistro: any, idMecanicoNuevo: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_vistaTradicional.updateRecordEnCurso" {
  export default function updateRecordEnCurso(param: {idRegistro: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_vistaTradicional.updateRecordComp" {
  export default function updateRecordComp(param: {idRegistro: any, fechaDeFin: any}): Promise<any>;
}
