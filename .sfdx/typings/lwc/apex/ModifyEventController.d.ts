declare module "@salesforce/apex/ModifyEventController.fetchRecords" {
  export default function fetchRecords(param: {searchString: any, value: any}): Promise<any>;
}
declare module "@salesforce/apex/ModifyEventController.fetchEventDetail" {
  export default function fetchEventDetail(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ModifyEventController.updateEventDetail" {
  export default function updateEventDetail(param: {recordId: any, Activo: any, tipoCargoCliente: any, tipoCargoAseguradora: any, tipoCargoGarantia: any, tipoCargoBci: any}): Promise<any>;
}
