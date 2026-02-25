declare module "@salesforce/apex/QuitarReservaUsadosController.getCurrentOpp" {
  export default function getCurrentOpp(param: {OppId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuitarReservaUsadosController.getModelosVehiculos" {
  export default function getModelosVehiculos(param: {OppId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuitarReservaUsadosController.getProduct" {
  export default function getProduct(param: {ProdId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuitarReservaUsadosController.getAnticipo" {
  export default function getAnticipo(param: {OppId: any, ProdId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuitarReservaUsadosController.makeEliminarReserva" {
  export default function makeEliminarReserva(param: {OppId: any, ProdId: any}): Promise<any>;
}
