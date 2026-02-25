declare module "@salesforce/apex/RM_VN_Inventario_Ctrl.searchColors" {
  export default function searchColors(param: {selectedBrand: any, selectedYear: any, selectedModel: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_Inventario_Ctrl.searchTapicerias" {
  export default function searchTapicerias(param: {selectedBrand: any, selectedModel: any, selectedYear: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_Inventario_Ctrl.getRecords" {
  export default function getRecords(param: {brand: any, year: any, model: any, family: any, productCode: any, locationId: any, vin: any, internalColor: any, externalColor: any, tipoCombustible: any, reportado: any, numeroPedido: any, vehiculoTransito: any, pageNumber: any, skipPagination: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_Inventario_Ctrl.getTipoGasolina" {
  export default function getTipoGasolina(): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_Inventario_Ctrl.getLocations" {
  export default function getLocations(param: {marca: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_Inventario_Ctrl.agregaComentario" {
  export default function agregaComentario(param: {vehiculoId: any, comentario: any, reportado: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_Inventario_Ctrl.searchModels" {
  export default function searchModels(param: {searchTerm: any, rawSearchTerm: any, selectedIds: any, firedElement: any, objName: any, displayedObjName: any, icon: any, selectedFamily: any, selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_Inventario_Ctrl.searchFamilias" {
  export default function searchFamilias(param: {searchTerm: any, rawSearchTerm: any, selectedIds: any, firedElement: any, objName: any, displayedObjName: any, icon: any, selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_Inventario_Ctrl.searchNumeroPedidos" {
  export default function searchNumeroPedidos(param: {searchTerm: any, rawSearchTerm: any, selectedIds: any, firedElement: any, objName: any, displayedObjName: any, icon: any}): Promise<any>;
}
