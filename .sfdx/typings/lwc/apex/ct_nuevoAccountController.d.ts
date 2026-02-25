declare module "@salesforce/apex/ct_nuevoAccountController.crearCuenta" {
  export default function crearCuenta(param: {accountData: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_nuevoAccountController.buscarActividadComercial" {
  export default function buscarActividadComercial(param: {searchKey: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_nuevoAccountController.crearCuentaJuridica" {
  export default function crearCuentaJuridica(param: {accountData: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_nuevoAccountController.actualizarCorreoYTelefono" {
  export default function actualizarCorreoYTelefono(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_nuevoAccountController.getAccountById" {
  export default function getAccountById(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_nuevoAccountController.actualizarCuenta" {
  export default function actualizarCuenta(param: {accountId: any, campos: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_nuevoAccountController.obtenerTiposDocumentoCuenta" {
  export default function obtenerTiposDocumentoCuenta(param: {tipoCuenta: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_nuevoAccountController.eliminarCuenta" {
  export default function eliminarCuenta(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_nuevoAccountController.validarCuentaExistente" {
  export default function validarCuentaExistente(param: {cedula: any, tipoCuenta: any}): Promise<any>;
}
declare module "@salesforce/apex/ct_nuevoAccountController.esPerfilAdministrador" {
  export default function esPerfilAdministrador(): Promise<any>;
}
