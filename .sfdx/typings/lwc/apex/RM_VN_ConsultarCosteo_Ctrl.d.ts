declare module "@salesforce/apex/RM_VN_ConsultarCosteo_Ctrl.getData" {
  export default function getData(param: {brand: any, year: any, model: any, bodegaId: any, vin: any, internalColor: any, externalColor: any, tipoCombustible: any, status: any, pageNumber: any, skipPagination: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_ConsultarCosteo_Ctrl.getDataError" {
  export default function getDataError(param: {pageNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_ConsultarCosteo_Ctrl.getDetalleCosto" {
  export default function getDetalleCosto(param: {vehiculoId: any}): Promise<any>;
}
