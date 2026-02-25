/**
  @Autor: David Leon Sanchez
  @Fecha creacion: 18/08/2017 
  @Proyecto: Altica
  @Proposito: Controlador para el componente llamado PlantillaSeguimientoOportunidad
 
  **/

public with sharing class ControllerPlantillaOpSeguimiento {

    public ControllerPlantillaOpSeguimiento() {
    }
	public String site{get{return URL.getSalesforceBaseUrl().toExternalForm();}set;}
	
    public Map<String, List<opsSegApro>> MapOpSegu {
        get {
            List<opsSegApro> listOpApro;
            List<Opportunity> listOp = new list<Opportunity>();
            
            Map<String, List<opsSegApro>> MapOpsSeg = new Map<String, List<opsSegApro>> ();
            
            if(Test.isRunningTest()){
                listOp = [SELECT o.EnvioAlertaOF__c, o.Importetotaldelnegocio__c, o.UltimaModificacion__c, o.Sucursal__c, o.OwnerId, o.Owner.Name, o.Name, o.Id,
                (SELECT Id, Name, Producto__c From Oportunidades_de_Financiamiento1__r) FROM Opportunity o WHERE EstadoOF__c = :'Aprobada'];
            }else{
                listOp = [SELECT o.EnvioAlertaOF__c, o.Importetotaldelnegocio__c, o.UltimaModificacion__c, o.Sucursal__c, o.OwnerId, o.Owner.Name, o.Name, o.Id,
                (SELECT Id, Name, Producto__c From Oportunidades_de_Financiamiento1__r) FROM Opportunity o WHERE EstadoOF__c = :'Aprobada' AND DiasSinSeguimiento__c > 0];
            
            }

            System.debug('*********************** LISTA DE OP ************************* ' + listOp);

            for (Opportunity opp : listOp) {
                System.debug('******************* op a actualizar EnvioAlertaOF__c ********** ' + opp);
                opp.EnvioAlertaOF__c = true;
                TriggerHandler.bypass('OpportunityTriggerHandler');
                    update opp;
                TriggerHandler.clearBypass('OpportunityTriggerHandler');
                System.debug('******************* op a actualizar EnvioAlertaOF__c ********** ' + opp);
            }

            for (Opportunity op : listOp) {
                listOpApro = new List<opsSegApro> ();
                opsSegApro opApr = new opsSegApro();
                opApr.idOp = op.Id;
                opApr.nameOp = op.Name;
                opApr.precioFacturacion = op.Importetotaldelnegocio__c;
                opApr.UltimaFechaSeguimiento = op.UltimaModificacion__c;
                opApr.sucursal = op.Sucursal__c;
                for (Oportunidad_de_Financiamiento__c opF : op.Oportunidades_de_Financiamiento1__r) {
                    opApr.idOf = opF.Id;
                    opApr.nameOf = opF.Name;
                    opApr.CodigoVehicular = opF.Producto__c;
                }
                if (MapOpsSeg.containsKey(op.Owner.name)) {
                    listOpApro = MapOpsSeg.get(op.Owner.name);
                    listOpApro.add(opApr);
                    MapOpsSeg.put(op.Owner.name, listOpApro);
                } else {
                    listOpApro.add(opApr);
                    MapOpsSeg.put(op.Owner.name, listOpApro);
                }
            }
            return MapOpsSeg;
        }
        set;
    }

    public class opsSegApro {
        public id idOp { get; set; }
        public id idOf { get; set; }
        public String nameOp { get; set; }
        public String nameOf { get; set; }
        public String CodigoVehicular { get; set; }
        public Decimal precioFacturacion { get; set; }
        public Datetime UltimaFechaSeguimiento { get; set; }
        public String sucursal { get; set; }
    }
}