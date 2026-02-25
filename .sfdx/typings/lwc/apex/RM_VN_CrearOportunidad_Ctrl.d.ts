declare module "@salesforce/apex/RM_VN_CrearOportunidad_Ctrl.validarCuenta" {
  export default function validarCuenta(param: {cuentaId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_CrearOportunidad_Ctrl.crearCuenta" {
  export default function crearCuenta(param: {cuentaId: any, nombre: any, apellido: any, telefono: any, email: any, emailFact: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_CrearOportunidad_Ctrl.createOpportunity" {
  export default function createOpportunity(param: {contactoId: any, accountId: any, items: any, brand: any, year: any, strTipoDeCliente: any, strDepartamento: any, strCuentaFacturacion: any, strLeadSource: any, realizaTestDrive: any, strAniodelvehiculo: any, tipoDeUso: any, fechaPosibleCompra: any, formaDePago: any, plazoEnMeses: any, prima: any, entidad: any, numeroIdentificacion: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_CrearOportunidad_Ctrl.getTipoGasolina" {
  export default function getTipoGasolina(): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_CrearOportunidad_Ctrl.getRecordTypes" {
  export default function getRecordTypes(): Promise<any>;
}
