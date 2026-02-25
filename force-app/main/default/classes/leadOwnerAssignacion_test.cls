@isTest (SeeAllData=true)
public class leadOwnerAssignacion_test {
 	@isTest
    public static void testLead() {
       	List<Lead> lstLead = [Select id,LeadSource,Email,CreatedDate,OwnerId,Owner.isActive,Marca__c,Ignorar_asignacion__c,Sucursal__c,RecordTypeId From Lead Where Marca__c != null and Sucursal__c != null and LeadSource = 'Página Web' And CreatedDate > 2024-06-21T17:11:10.000+0000 LIMIT 1	];
        
       	Configuraci_nes_Sucursal__c confSuc = new Configuraci_nes_Sucursal__c();
        confSuc.Canal__c = 'Página Web';
        confSuc.Marca__c = lstLead[0].Marca__c;
        confSuc.Sucursal__c  = lstLead[0].Sucursal__c;
        confSuc.Estado_asignaci_n__c  = 'Activo';
        insert confSuc;

        List<User> lstUser = [Select Id,ProfileId From User Where Profile.Name Like '%Asesor%' and IsActive = true Limit 1];

        Configuraci_nes_Asesor_x_Sucursal__c confAsSuc = new Configuraci_nes_Asesor_x_Sucursal__c();
        confAsSuc.NumeroControl__c  = 1;
        confAsSuc.Estado__c = 'Activo';
        confAsSuc.buscar_asesor__c = lstUser[0].id;
		confAsSuc.Buscar_Sucursal__c = confSuc.Id;
        insert confAsSuc;
        leadOwnerAssignacion.setOwner(lstLead);
    }
    @isTest
    public static void testLead2() {
       	List<Lead> lstLead = [Select id,LeadSource,Email,CreatedDate,OwnerId,Marca__c,Owner.isActive,Sucursal__c,Ignorar_asignacion__c,RecordTypeId From Lead Where Marca__c != null and Sucursal__c != null and LeadSource = 'Página Web' And CreatedDate > 2024-06-21T17:11:10.000+0000 LIMIT 1	];
        
       	Configuraci_nes_Sucursal__c confSuc = new Configuraci_nes_Sucursal__c();
        confSuc.Canal__c = 'Página Web';
        confSuc.Marca__c = lstLead[0].Marca__c;
        confSuc.Sucursal__c  = lstLead[0].Sucursal__c;
        confSuc.Estado_asignaci_n__c  = 'Activo';
        insert confSuc;

        List<User> lstUser = [Select Id,ProfileId From User Where Profile.Name Like '%Asesor%' and IsActive = true Limit 2];

        Configuraci_nes_Asesor_x_Sucursal__c confAsSuc = new Configuraci_nes_Asesor_x_Sucursal__c();
        confAsSuc.NumeroControl__c  = 1;
        confAsSuc.Estado__c = 'Activo';
        confAsSuc.buscar_asesor__c = lstUser[0].id;
		confAsSuc.Buscar_Sucursal__c = confSuc.Id;
        insert confAsSuc;
        
        Configuraci_nes_Asesor_x_Sucursal__c confAsSuc2 = new Configuraci_nes_Asesor_x_Sucursal__c();
        confAsSuc2.NumeroControl__c  = 1;
        confAsSuc2.Estado__c = 'Activo';
        confAsSuc2.buscar_asesor__c = lstUser[1].id;
		confAsSuc2.Buscar_Sucursal__c = confSuc.Id;
        insert confAsSuc2;
        
        leadOwnerAssignacion.setOwner(lstLead);
    }
}