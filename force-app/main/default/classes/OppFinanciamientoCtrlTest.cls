@isTest()
public class OppFinanciamientoCtrlTest {
    private static testmethod void validated(){  
        
        Maestro_Plantillas__c mp = new Maestro_Plantillas__c();
        mp.Categoria__c='Automóvil';
        mp.Producto__c ='Leasing operativo en función financiera';
        mp.Sub_Categoria__c = 'Nuevo';
        insert mp;
        
        Plantilla_Formalizacion__c pf = new Plantilla_Formalizacion__c();
        pf.Plantilla__c = 'test body';
        pf.Maestro_Plantillas__c = mp.Id;
        pf.Nombre_de_Plantilla__c = 'test{{comisionInfo}}';
        
        insert pf;
        
        Oportunidad_de_Financiamiento__c opf = new Oportunidad_de_Financiamiento__c();
        opf.Categoria__c = 'Automóvil';
        opf.Subcategoria__c = 'Nuevo'; 
        opf.TipoProducto__c = 'Leasing operativo en función financiera';
        insert opf;	
        
      //  Opp_Finacial__mdt ofmdt = new Opp_Finacial__mdt();
      //  ofmdt.DeveloperName = 'Cuenta Cliente';
      //  ofmdt.label = 'Cuenta Cliente';
       // ofmdt.Field__c = 'Cuenta_cliente__c';
      //  insert ofmdt;
        
        Cotizacion__c ct = new Cotizacion__c();
        ct.Oportunidad_de_Financiamiento__c = opf.id;
        ct.Estado__c = 'Aceptada';
        ct.Monto_Seguro__c = 11;
        insert ct;
        
        Tabla_Pagos__c tp = new Tabla_Pagos__c();
        tp.Cotizacion__c = ct.id;
        tp.Administrativo__c =100;
        tp.Impuestos__c=10;
        tp.Monto__c=121;
        tp.Comision__c=11;
        tp.GPS__c=1;
        insert tp;
        
        Distribucion__c dis = new Distribucion__c();
        dis.Mes_Final__c = 25;
        dis.Mes_Inicial__c = 1;
        dis.Porcentaje_Tasa_Base__c = 12;
        dis.spread__c =1;
        dis.Cotizacion__c = ct.Id;
        insert dis;
        
        
        OppFinanciamientoCtrl pfCtrl = new OppFinanciamientoCtrl();
        pfCtrl.doMergeFields(opf.id, 'test');
        
        //opf.Tipo_Cargo__c='Financiado Independientemente';
        //update opf;
        
       // pfCtrl.doMergeFields(opf.id, 'test');
    }
}