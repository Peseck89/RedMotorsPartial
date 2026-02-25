declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.createAccount" {
  export default function createAccount(param: {nombreCuenta: any, apellido: any, cedula: any, telefono: any, fechaNacimiento: any, correoElectronico: any, nombreEncargado: any, telefonoEncargado: any, esEmpresarial: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateAccount" {
  export default function updateAccount(param: {recordId: any, cuentaId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateDataAccount" {
  export default function updateDataAccount(param: {cuentaId: any, telCuenta: any, identificacioCuenta: any, correoCuenta: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.createContact" {
  export default function createContact(param: {recordId: any, cuenta: any, nombreContacto: any, apellidoContacto: any, telefonoContacto: any, correoContacto: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateContactData" {
  export default function updateContactData(param: {contactId: any, nombreC: any, apellidoC: any, phoneC: any, emailC: any, cedulaCont: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateContactOtro" {
  export default function updateContactOtro(param: {recordId: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateContact" {
  export default function updateContact(param: {recordId: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateAssetkilometraje" {
  export default function updateAssetkilometraje(param: {assetId: any, kilometraje: any, caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.isCurrentUserAdmin" {
  export default function isCurrentUserAdmin(): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.getHistorialVehiculo" {
  export default function getHistorialVehiculo(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateKilometraje" {
  export default function updateKilometraje(param: {historialId: any, nuevoKm: any, assetId: any, caseId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateFacturacion" {
  export default function updateFacturacion(param: {recordId: any, correoFact: any, phoneFact: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.cambiarFacturacion" {
  export default function cambiarFacturacion(param: {recordId: any, accId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.cambiarFacturacionCaso" {
  export default function cambiarFacturacionCaso(param: {recordId: any, accId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateFacturacionCaso" {
  export default function updateFacturacionCaso(param: {recordId: any, correoFact: any, phoneFact: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_ChangeData_copy_ctrl.updateAssetAddress" {
  export default function updateAssetAddress(param: {assetId: any, caseId: any, state: any, city: any, street: any}): Promise<any>;
}
