declare module "@salesforce/apex/RM_CT_Gestion_Tareas_Ctrl.getData" {
  export default function getData(param: {caseNumber: any, caseId: any, territoryId: any, offsetSize: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_Gestion_Tareas_Ctrl.reprocesarTrabajo" {
  export default function reprocesarTrabajo(param: {ttcId: any, sttcId: any, mechanicId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_Gestion_Tareas_Ctrl.reprocesarSubTrabajo" {
  export default function reprocesarSubTrabajo(param: {sttcId: any, mechanicId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_Gestion_Tareas_Ctrl.asignarMechanico" {
  export default function asignarMechanico(param: {workStepId: any, mechanicId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_Gestion_Tareas_Ctrl.reasignarMechanico" {
  export default function reasignarMechanico(param: {workStepId: any, mechanicId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_Gestion_Tareas_Ctrl.updateWorkStepStatus" {
  export default function updateWorkStepStatus(param: {workStepId: any, status: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_Gestion_Tareas_Ctrl.deleteTrabajo" {
  export default function deleteTrabajo(param: {ttcId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_Gestion_Tareas_Ctrl.deleteSubtrabajo" {
  export default function deleteSubtrabajo(param: {sttcId: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_CT_Gestion_Tareas_Ctrl.searchCases" {
  export default function searchCases(param: {searchTerm: any, selectedIds: any, firedElement: any, objName: any, displayedObjName: any, icon: any}): Promise<any>;
}
