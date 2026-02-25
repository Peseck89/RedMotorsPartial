declare module "@salesforce/apex/WOApprovalPanelCtrl.load" {
  export default function load(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/WOApprovalPanelCtrl.canView" {
  export default function canView(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/WOApprovalPanelCtrl.canViewNo" {
  export default function canViewNo(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/WOApprovalPanelCtrl.approve" {
  export default function approve(param: {workitemId: any, comments: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/WOApprovalPanelCtrl.reject" {
  export default function reject(param: {workitemId: any, comments: any, recordId: any}): Promise<any>;
}
