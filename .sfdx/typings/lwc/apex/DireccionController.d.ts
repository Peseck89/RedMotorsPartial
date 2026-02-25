declare module "@salesforce/apex/DireccionController.obtenerDirecciones" {
  export default function obtenerDirecciones(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/DireccionController.guardarDireccion" {
  export default function guardarDireccion(param: {direccion: any}): Promise<any>;
}
declare module "@salesforce/apex/DireccionController.eliminarDireccion" {
  export default function eliminarDireccion(param: {direccionId: any}): Promise<any>;
}
declare module "@salesforce/apex/DireccionController.obtenerProvincias" {
  export default function obtenerProvincias(): Promise<any>;
}
declare module "@salesforce/apex/DireccionController.obtenerCantones" {
  export default function obtenerCantones(): Promise<any>;
}
declare module "@salesforce/apex/DireccionController.obtenerDistritos" {
  export default function obtenerDistritos(): Promise<any>;
}
declare module "@salesforce/apex/DireccionController.obtenerCantonesPorProvincia" {
  export default function obtenerCantonesPorProvincia(param: {provinciaId: any}): Promise<any>;
}
declare module "@salesforce/apex/DireccionController.obtenerDistritosPorCanton" {
  export default function obtenerDistritosPorCanton(param: {cantonId: any}): Promise<any>;
}
