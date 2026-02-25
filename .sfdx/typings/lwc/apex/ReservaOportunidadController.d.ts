declare module "@salesforce/apex/ReservaOportunidadController.getCurrentOpp" {
  export default function getCurrentOpp(param: {OppId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReservaOportunidadController.getModelosVehiculos" {
  export default function getModelosVehiculos(param: {OppId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReservaOportunidadController.getProduct" {
  export default function getProduct(param: {ProdId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReservaOportunidadController.getAnticipo" {
  export default function getAnticipo(param: {OppId: any, ProdId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReservaOportunidadController.makeReserva" {
  export default function makeReserva(param: {OppId: any, ProdId: any}): Promise<any>;
}
