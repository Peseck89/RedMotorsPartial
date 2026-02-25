declare module "@salesforce/apex/RM_VU_Inventario_Ctrl.getRecords" {
  export default function getRecords(param: {tipoVehiculo: any, brand: any, year: any, model: any, productCode: any, placa: any, internalColor: any, externalColor: any, tipoCombustible: any, pageNumber: any, skipPagination: any, priceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VU_Inventario_Ctrl.getTipoGasolina" {
  export default function getTipoGasolina(): Promise<any>;
}
declare module "@salesforce/apex/RM_VU_Inventario_Ctrl.getOpportunity" {
  export default function getOpportunity(param: {oppId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VU_Inventario_Ctrl.getPriceBooks" {
  export default function getPriceBooks(): Promise<any>;
}
declare module "@salesforce/apex/RM_VU_Inventario_Ctrl.getUsadoRecordTypeOptions" {
  export default function getUsadoRecordTypeOptions(): Promise<any>;
}
