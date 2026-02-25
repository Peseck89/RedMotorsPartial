declare module "@salesforce/apex/CommunityCalendarController.createCaseDesasocia" {
  export default function createCaseDesasocia(param: {vehiculoId: any, motivoBaja: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.createCaseAsocia" {
  export default function createCaseAsocia(param: {vinVehiculo: any, codModelo: any, matricula: any, marca: any, vehiculoTipo: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getMarcasConfig" {
  export default function getMarcasConfig(param: {marcaSel: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.mandarMensaje" {
  export default function mandarMensaje(param: {cliente: any, placa: any, fecha: any, calendarId: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getPreguntas" {
  export default function getPreguntas(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.obtenerDatosUsuario" {
  export default function obtenerDatosUsuario(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.saberEsSincronica" {
  export default function saberEsSincronica(param: {marcaSel: any, servicioSelec: any, selectedService: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getHoraGlobal" {
  export default function getHoraGlobal(param: {marcaSel: any, servicioSelec: any, selectedService: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getSubServicios" {
  export default function getSubServicios(param: {marcaSel: any, servicioSelec: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getMarcasSubSer" {
  export default function getMarcasSubSer(param: {marcaSel: any, servicioSelec: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getAssetBuscado" {
  export default function getAssetBuscado(param: {cocheBuscado: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getMecanicosSucursal" {
  export default function getMecanicosSucursal(param: {marcaSel: any, servicioSelec: any, selectedService: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getAsesoresDeCalendario" {
  export default function getAsesoresDeCalendario(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getCalendarAvailabilityForService" {
  export default function getCalendarAvailabilityForService(param: {selectedService: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.convertListToMapOperatingHour" {
  export default function convertListToMapOperatingHour(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.convertListToMapServiceTAndCalendarId" {
  export default function convertListToMapServiceTAndCalendarId(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.generateFakeEventsForServiceT" {
  export default function generateFakeEventsForServiceT(param: {serviceTerritory: any, operatingHours: any, currentDate: any, events: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.generateFakeEventsForServiceTOneDay" {
  export default function generateFakeEventsForServiceTOneDay(param: {serviceTerritory: any, operatingHours: any, currentDate: any, events: any, startDateTime: any, endDateTime: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.generateNoAvailabilityDataWholeCompany" {
  export default function generateNoAvailabilityDataWholeCompany(param: {likeVariable: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.generateNoAvailabilityDataForSucursal" {
  export default function generateNoAvailabilityDataForSucursal(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.generateNoAvailabilityDataForSpecificService" {
  export default function generateNoAvailabilityDataForSpecificService(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.fetchUser" {
  export default function fetchUser(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getNextUserCitation" {
  export default function getNextUserCitation(param: {contactRelatedToUser: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getNextVehiculeIdCitation" {
  export default function getNextVehiculeIdCitation(param: {vehiculeId: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getUserAssets" {
  export default function getUserAssets(param: {contactId: any, modeoSel: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getOperartingHours" {
  export default function getOperartingHours(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getSetupInformation" {
  export default function getSetupInformation(param: {marcaSel: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getReportarFallo" {
  export default function getReportarFallo(param: {serviceSelected: any, marcaSel: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getCalendarsObjects" {
  export default function getCalendarsObjects(param: {serviceSelected: any, marcaSel: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.cancelCitation" {
  export default function cancelCitation(param: {citationId: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.createCaseComunidad" {
  export default function createCaseComunidad(param: {mensaje: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getSucursalCapacity" {
  export default function getSucursalCapacity(param: {sucursal: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getHourAvailability" {
  export default function getHourAvailability(param: {calendarId: any, horaSelc: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getHoursAvailability" {
  export default function getHoursAvailability(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getTerminosYCondi" {
  export default function getTerminosYCondi(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.setTerminosYCondi" {
  export default function setTerminosYCondi(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.releaseHoursAvailability" {
  export default function releaseHoursAvailability(param: {calendarId: any, horaSelc: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.validarEventoVacio" {
  export default function validarEventoVacio(param: {userId: any, usersToExclude: any, calendarId: any, whatId: any, daySelected: any, selectedStartHour: any, selectedEndHour: any, selectedVehicle: any, vehicleId: any, ownVehicleId: any, description: any, selectedServiceCenter: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.createCalendarEventW" {
  export default function createCalendarEventW(param: {KilimeEsti: any, userId: any, usersToExclude: any, calendarId: any, whatId: any, daySelected: any, selectedStartHour: any, selectedEndHour: any, selectedVehicle: any, vehicleId: any, ownVehicleId: any, description: any, selectedServiceCenter: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getUserActualInfo" {
  export default function getUserActualInfo(param: {userId: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getUserHistory" {
  export default function getUserHistory(param: {userId: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getUserHistoryActive" {
  export default function getUserHistoryActive(param: {userId: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getAvailability" {
  export default function getAvailability(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getWholeCompanyAvailability" {
  export default function getWholeCompanyAvailability(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getSucursalAvailability" {
  export default function getSucursalAvailability(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.getServiceAvailability" {
  export default function getServiceAvailability(): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.callExternalApi" {
  export default function callExternalApi(param: {servicio: any, sucursal: any, fecha: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.callExternalApiOcupied" {
  export default function callExternalApiOcupied(param: {servicio: any, sucursal: any, fecha: any}): Promise<any>;
}
declare module "@salesforce/apex/CommunityCalendarController.callExternalApiDates" {
  export default function callExternalApiDates(param: {sucursal: any, fecha: any}): Promise<any>;
}
