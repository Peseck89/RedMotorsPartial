declare module "@salesforce/apex/CT_AsignaMecanicoClass.fetchAccounts" {
  export default function fetchAccounts(param: {workOrderNumber: any, caseNumber: any, workType: any}): Promise<any>;
}
declare module "@salesforce/apex/CT_AsignaMecanicoClass.asignarWorkSteps" {
  export default function asignarWorkSteps(param: {wsIds: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/CT_AsignaMecanicoClass.IniciaYAsignaWorkSteps" {
  export default function IniciaYAsignaWorkSteps(param: {wsIds: any, contactId: any}): Promise<any>;
}
