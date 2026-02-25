declare module "@salesforce/apex/QuitarReservaController.getCurrentOpp" {
  export default function getCurrentOpp(param: {OppId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuitarReservaController.getModelosVehiculos" {
  export default function getModelosVehiculos(param: {OppId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuitarReservaController.getProduct" {
  export default function getProduct(param: {ProdId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuitarReservaController.getAnticipo" {
  export default function getAnticipo(param: {OppId: any, ProdId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuitarReservaController.makeEliminarReserva" {
  export default function makeEliminarReserva(param: {OppId: any, ProdId: any}): Promise<any>;
}
