declare module "@salesforce/apex/QOApprovalPanelCtrl.load" {
  export default function load(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QOApprovalPanelCtrl.canView" {
  export default function canView(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QOApprovalPanelCtrl.canViewNo" {
  export default function canViewNo(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QOApprovalPanelCtrl.approve" {
  export default function approve(param: {workitemId: any, comments: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QOApprovalPanelCtrl.reject" {
  export default function reject(param: {workitemId: any, comments: any, recordId: any}): Promise<any>;
}
