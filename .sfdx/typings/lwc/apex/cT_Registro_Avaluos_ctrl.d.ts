declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.searchVehicle" {
  export default function searchVehicle(param: {licensePlate: any, tipoVehiculo: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.saveAppraisal" {
  export default function saveAppraisal(param: {placa: any, observaciones: any, valorSugerido: any, vin: any, traccion: any, carroceria: any, numeroChasis: any, categoria: any, estilo: any, capacidadPersonas: any, anio: any, color: any, combustible: any, marca: any, modelo: any, propietario: any, moneda: any, motor: any, n_puertas: any, trasmision: any, gravamenes_o_multas: any, estilo_usado: any, cantidad_de_embargos: any, capacidad_de_personas: any, cilindraje: any, kilometraje: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.getAvaluoData" {
  export default function getAvaluoData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.updateAvaluo" {
  export default function updateAvaluo(param: {recordId: any, observaciones: any, valorJefeUsados: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.getPromedios" {
  export default function getPromedios(param: {avaluoId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.getPromediosByAttributes" {
  export default function getPromediosByAttributes(param: {marca: any, modelo: any, anio: any, traccion: any, combustible: any, trasmision: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.getPromediosConsul" {
  export default function getPromediosConsul(param: {marca: any, modelo: any, anio: any, traccion: any, combustible: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.getAvaluosValidos" {
  export default function getAvaluosValidos(param: {placa: any, tipoVehiculo: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.getOpportunityData" {
  export default function getOpportunityData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.updateAvaluoOpportunity" {
  export default function updateAvaluoOpportunity(param: {recordId: any, oportunidadId: any, kilometraje: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.getLinkedAvaluos" {
  export default function getLinkedAvaluos(param: {opportunityId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.checkReciboStatus" {
  export default function checkReciboStatus(param: {avaluoId: any}): Promise<any>;
}
declare module "@salesforce/apex/cT_Registro_Avaluos_ctrl.getCurrentUserProfileName" {
  export default function getCurrentUserProfileName(): Promise<any>;
}
