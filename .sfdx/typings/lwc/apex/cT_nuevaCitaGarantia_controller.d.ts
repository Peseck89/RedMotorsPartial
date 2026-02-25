declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getKilometros" {
  export default function getKilometros(param: {cocheId: any, cocheVin: any, kilometros: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getActives" {
  export default function getActives(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getDataAsesor" {
  export default function getDataAsesor(param: {asesorId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getDataActivos" {
  export default function getDataActivos(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.guardarAsset" {
  export default function guardarAsset(param: {numeroPlaca: any, tipoVehi: any, marca: any, modelo: any, numeroChasis: any, motor: any, color: any, anio: any, kilometros: any, accountSelected: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getCalendario" {
  export default function getCalendario(): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getDataCalendario" {
  export default function getDataCalendario(param: {calendarId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getAsesores" {
  export default function getAsesores(param: {calendario: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getCedula" {
  export default function getCedula(param: {cedula: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getSeguroDetails" {
  export default function getSeguroDetails(param: {cocheId: any, cocheVin: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getAsset" {
  export default function getAsset(param: {cocheId: any, cocheVin: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateDataAccount" {
  export default function updateDataAccount(param: {cuentaId: any, telCuenta: any, identificacioCuenta: any, correoCuenta: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateAccount" {
  export default function updateAccount(param: {cocheId: any, cocheVin: any, cuentaId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateContactData" {
  export default function updateContactData(param: {contactId: any, nombreC: any, apellidoC: any, phoneC: any, tipoI: any, emailC: any, cedulaCont: any, cocheId: any, cocheVin: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateContact" {
  export default function updateContact(param: {cocheId: any, cocheVin: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.actualizarHorarios" {
  export default function actualizarHorarios(param: {recordId: any, fecha: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.createContact" {
  export default function createContact(param: {cocheId: any, cocheVin: any, cuenta: any, nombreContacto: any, apellidoContacto: any, telefonoContacto: any, correoContacto: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.createAccount" {
  export default function createAccount(param: {nombreCuenta: any, apellido: any, cedula: any, telefono: any, fechaNacimiento: any, correoElectronico: any, nombreEncargado: any, telefonoEncargado: any, esEmpresarial: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.otrosEventos" {
  export default function otrosEventos(param: {cocheId: any, cocheVin: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getDependentMap" {
  export default function getDependentMap(param: {controlField: any, depentField: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getServiceT" {
  export default function getServiceT(param: {calendarioSel: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.buscarDuplicado" {
  export default function buscarDuplicado(param: {asesorId: any, sucursal: any, fechaHoraSolicitada: any, esteEvento: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.createEvent" {
  export default function createEvent(param: {contactId: any, cocheId: any, asesorId: any, sucursal: any, fechaHoraSolicitada: any, kilometros: any, serviceTerritoryBuscar: any, origenCita: any, comentarios: any, ignorarDuplicado: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateEventOrigen" {
  export default function updateEventOrigen(param: {idShadow: any, origenCorrecto: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getUrlEvent" {
  export default function getUrlEvent(param: {idShadow: any, esteRecord: any, origenCorrecto: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getCurrentUser" {
  export default function getCurrentUser(): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.verifyContactData" {
  export default function verifyContactData(param: {contactId: any, accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.getCampaniasByAssetId" {
  export default function getCampaniasByAssetId(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.confirmarCampanias" {
  export default function confirmarCampanias(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_nuevaCitaGarantia_controller.obtenerDisponibilidadProximosDias" {
  export default function obtenerDisponibilidadProximosDias(param: {fechaInicial: any}): Promise<any>;
}
