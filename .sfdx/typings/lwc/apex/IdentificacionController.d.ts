declare module "@salesforce/apex/IdentificacionController.obtenerIdentificaciones" {
  export default function obtenerIdentificaciones(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/IdentificacionController.guardarIdentificacion" {
  export default function guardarIdentificacion(param: {identificacion: any}): Promise<any>;
}
declare module "@salesforce/apex/IdentificacionController.eliminarIdentificacion" {
  export default function eliminarIdentificacion(param: {identificacionId: any}): Promise<any>;
}
declare module "@salesforce/apex/IdentificacionController.obtenerTiposDocumento" {
  export default function obtenerTiposDocumento(): Promise<any>;
}
declare module "@salesforce/apex/IdentificacionController.obtenerTiposDocumentoCuenta" {
  export default function obtenerTiposDocumentoCuenta(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/IdentificacionController.crearIdentificacionInicial" {
  export default function crearIdentificacionInicial(param: {accountId: any, tipoDocumentoId: any, pais: any, numeroIdentificacion: any}): Promise<any>;
}
