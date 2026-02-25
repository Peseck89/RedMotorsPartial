declare module "@salesforce/apex/ContactoPorCuentaController.guardarContactoPorCuenta" {
  export default function guardarContactoPorCuenta(param: {data: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactoPorCuentaController.eliminarContactoPorCuenta" {
  export default function eliminarContactoPorCuenta(param: {relacionId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactoPorCuentaController.obtenerContactos" {
  export default function obtenerContactos(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContactoPorCuentaController.obtenerTiposContacto" {
  export default function obtenerTiposContacto(): Promise<any>;
}
declare module "@salesforce/apex/ContactoPorCuentaController.verificarCorreoExistente" {
  export default function verificarCorreoExistente(param: {correo: any, accountId: any, contactoId: any}): Promise<any>;
}
