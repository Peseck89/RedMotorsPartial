declare module "@salesforce/apex/communityManageWorks_ctrl.getWorkOrderLineItemsGroupedByTipoTrabajo" {
  export default function getWorkOrderLineItemsGroupedByTipoTrabajo(param: {casoId: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.getCases" {
  export default function getCases(): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.getQuotes" {
  export default function getQuotes(): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.getCasesHistory" {
  export default function getCasesHistory(): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.getMarcasConfig" {
  export default function getMarcasConfig(param: {casoId: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.cambiarEstado" {
  export default function cambiarEstado(param: {tipoTrabajoCasoId: any, estado: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.callExternalApi" {
  export default function callExternalApi(): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.revisarCorreo" {
  export default function revisarCorreo(param: {correo: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.obtenerStages" {
  export default function obtenerStages(param: {casoId: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.quoteInfo" {
  export default function quoteInfo(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.getContactFromAccount" {
  export default function getContactFromAccount(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.getQuoteTrabajosGrouped" {
  export default function getQuoteTrabajosGrouped(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.aprobarRechazarQuoteLineItems" {
  export default function aprobarRechazarQuoteLineItems(param: {quoteId: any, quoteLineItemIds: any, estado: any, aprobado: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.enviarEmailTareasAprobadas" {
  export default function enviarEmailTareasAprobadas(param: {quoteId: any, tareasNecesarioJSON: any, tareasRecomendadoJSON: any, tareasSugeridoJSON: any, currencyIso: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.aprobarRechazarTareas" {
  export default function aprobarRechazarTareas(param: {quoteId: any, tareaNames: any, estado: any, aprobado: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.getEstadoTareas" {
  export default function getEstadoTareas(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.caseInfo" {
  export default function caseInfo(param: {casoId: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.obtenerPaso" {
  export default function obtenerPaso(param: {casoId: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.obtenerDatosUsuario" {
  export default function obtenerDatosUsuario(): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.actualizarDatosUsuario" {
  export default function actualizarDatosUsuario(param: {firstName: any, lastName: any, telefono: any, correo: any, contra: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.obtenerAssets" {
  export default function obtenerAssets(): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.getSeguroDetails" {
  export default function getSeguroDetails(): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.cambiarContra" {
  export default function cambiarContra(param: {contra: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.createCaseDesasocia" {
  export default function createCaseDesasocia(param: {vehiculoId: any, motivoBaja: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.createCaseComunidad" {
  export default function createCaseComunidad(param: {mensaje: any}): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.fetchUser" {
  export default function fetchUser(): Promise<any>;
}
declare module "@salesforce/apex/communityManageWorks_ctrl.nestedJsonUrlByTipoTrabajo" {
  export default function nestedJsonUrlByTipoTrabajo(param: {objectId: any}): Promise<any>;
}
