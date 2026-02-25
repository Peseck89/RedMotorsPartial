declare module "@salesforce/apex/RM_VN_InventarioFantasia_Ctrl.getRecords" {
  export default function getRecords(param: {brand: any, familly: any, year: any, pageNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_InventarioFantasia_Ctrl.getBrands" {
  export default function getBrands(): Promise<any>;
}
declare module "@salesforce/apex/RM_VN_InventarioFantasia_Ctrl.searchFamilyByBrand" {
  export default function searchFamilyByBrand(param: {searchTerm: any, brand: any, selectedIds: any, firedElement: any, objName: any, displayedObjName: any, icon: any}): Promise<any>;
}
