declare module "@salesforce/apex/AssetGarantiaController.buscarVehiculos" {
  export default function buscarVehiculos(param: {placa: any}): Promise<any>;
}
declare module "@salesforce/apex/AssetGarantiaController.validarGarantia" {
  export default function validarGarantia(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/AssetGarantiaController.obtenerDetalleCompleto" {
  export default function obtenerDetalleCompleto(param: {assetId: any}): Promise<any>;
}
declare module "@salesforce/apex/AssetGarantiaController.crearEvento" {
  export default function crearEvento(param: {cocheId: any}): Promise<any>;
}
