declare module "@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.getData" {
  export default function getData(param: {territoryId: any, pageSize: any, pageNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.getTerritoriesByUserId" {
  export default function getTerritoriesByUserId(param: {userId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.getTerritoriesByContactId" {
  export default function getTerritoriesByContactId(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.getTipoValues" {
  export default function getTipoValues(): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.crearActividad" {
  export default function crearActividad(param: {mechanicId: any, tallerId: any, tipo: any}): Promise<any>;
}
