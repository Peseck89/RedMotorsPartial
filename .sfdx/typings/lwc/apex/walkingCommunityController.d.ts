declare module "@salesforce/apex/walkingCommunityController.getModelos" {
  export default function getModelos(): Promise<any>;
}
declare module "@salesforce/apex/walkingCommunityController.getFamilia" {
  export default function getFamilia(param: {marca: any}): Promise<any>;
}
declare module "@salesforce/apex/walkingCommunityController.getVehiculos" {
  export default function getVehiculos(param: {familia: any, marca: any}): Promise<any>;
}
declare module "@salesforce/apex/walkingCommunityController.getCedula" {
  export default function getCedula(param: {cedula: any}): Promise<any>;
}
declare module "@salesforce/apex/walkingCommunityController.getImagenes" {
  export default function getImagenes(param: {familia: any, marca: any}): Promise<any>;
}
declare module "@salesforce/apex/walkingCommunityController.createTrafico" {
  export default function createTrafico(param: {nombre: any, apellido: any, correo: any, telefono: any, tiempoAprox: any, familia: any, modelo: any, marca: any, cedula: any, sucursal: any, otroMedio: any}): Promise<any>;
}
declare module "@salesforce/apex/walkingCommunityController.getFieldDependencies" {
  export default function getFieldDependencies(param: {objectName: any, controllingField: any, dependentField: any}): Promise<any>;
}
