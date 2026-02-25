declare module "@salesforce/apex/CT_AsignaMecanico.getWorkSteps" {
  export default function getWorkSteps(param: {caseId: any, mechanicId: any, tallerId: any, status: any, action: any, showParentTasks: any, tipoCargo: any, pageNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/CT_AsignaMecanico.createTiempoImproductivo" {
  export default function createTiempoImproductivo(param: {wsIds: any, description: any}): Promise<any>;
}
declare module "@salesforce/apex/CT_AsignaMecanico.checkTaskRunning" {
  export default function checkTaskRunning(param: {taskId: any}): Promise<any>;
}
declare module "@salesforce/apex/CT_AsignaMecanico.updateWorkSteps" {
  export default function updateWorkSteps(param: {wsIds: any, action: any, status: any, mechanicId: any}): Promise<any>;
}
declare module "@salesforce/apex/CT_AsignaMecanico.assignWorkSteps" {
  export default function assignWorkSteps(param: {wsIds: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/CT_AsignaMecanico.assignAndStartWorkSteps" {
  export default function assignAndStartWorkSteps(param: {wsIds: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/CT_AsignaMecanico.getTerritories" {
  export default function getTerritories(): Promise<any>;
}
declare module "@salesforce/apex/CT_AsignaMecanico.getTipoCargo" {
  export default function getTipoCargo(): Promise<any>;
}
