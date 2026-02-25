declare module "@salesforce/apex/CorreoController.obtenerCorreos" {
  export default function obtenerCorreos(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/CorreoController.guardarCorreo" {
  export default function guardarCorreo(param: {correo: any}): Promise<any>;
}
declare module "@salesforce/apex/CorreoController.eliminarCorreo" {
  export default function eliminarCorreo(param: {correoId: any}): Promise<any>;
}
declare module "@salesforce/apex/CorreoController.obtenerTiposDatosComunicacion" {
  export default function obtenerTiposDatosComunicacion(param: {accountId: any}): Promise<any>;
}
