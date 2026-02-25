/********************************************************************
Apex Class Name	:	PN_TrabajosController
Version			:	1.0
Created Date	:	 24/10/2025
Function 		:    Clase controlador del cmp cT_CaseChangeData_lwc
Test Class		:	

Modification Log
*--------------------------------------------------------------------
* Developer		     		Date			   	Description
* -------------------------------------------------------------------
* Kevin Garcia  		 	24/10/2025			Original Version-
*********************************************************************/
public with sharing class PN_TrabajosController {
   

     // Trae el listado de trabajos postegardos 
    @AuraEnabled(cacheable = true)
    public static List<Archivo_lineas_rechazadas__c> getTrabajosApex(String caseId) {
        try {
                return [SELECT Id, Name, Alias__c
                    FROM Archivo_lineas_rechazadas__c
                    WHERE Quote__r.Opportunity.WorkOrder__r.CaseId =: caseId AND PN_RechazadoCaso__c = FALSE
                    ];
        } catch (Exception e) {
            throw new AuraHandledException('Error obteniendo trabajos: ' + e.getMessage());
        }
    }

    //Aceptar el trabajo rechazado
    @AuraEnabled(cacheable = false)
    public static Respuesta aceptarTrabajoApex(String trabajoId){

        Respuesta res = new Respuesta();
        res.exito = true;

        try {
            
             Archivo_lineas_rechazadas__c trabajo = [SELECT Id, Alias__c, Quote__r.Opportunity.WorkOrder__c, Product__c,
                                                Cantidad__c, Descuento__c, PN_TipoTrabajo__c, Precio__c, PN_IdPricebookEntry__c,
                                                Quote__r.Opportunity.WorkOrder__r.Pricebook2Id, PN_RechazadoCaso__c,
                                                Quote__r.Opportunity.WorkOrder__r.CaseId, PN_Aprobador__c, 
                                                PN_CategoriaPresupuesto__c, PN_Hora__c, PN_TipoCargo__c, PN_SubtrabajoRealizar__c,
                                                PN_SubtrabajoAlias__c, PN_HorasSubtrabajo__c, PN_UTS__c,
                                                PN_SubtrabajoRealizar__r.ManoDeObra__c
                                                FROM Archivo_lineas_rechazadas__c WHERE Id =: trabajoId];

            Id tax = [SELECT Id FROM Impuesto__c WHERE codigoImpuesto__c = '0108' LIMIT 1 ].Id;

            PricebookEntry PBE = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id =: trabajo.Quote__r.Opportunity.WorkOrder__r.Pricebook2Id AND Product2Id =: trabajo.Product__c LIMIT 1];

            WorkOrderLineItem wl = new WorkOrderLineItem(); 
            wl.WorkOrderId = trabajo.Quote__r.Opportunity.WorkOrder__c;
            wl.Product__c = trabajo.Product__c;
            wl.PricebookEntryId = PBE.Id;
            wl.Alias_Articulo__c = trabajo.Alias__c;
            //wl.aprobado__c = wr.aprobado;
            wl.Quantity = trabajo.Cantidad__c;
            wl.porcentajeDescuento__c = trabajo.Descuento__c;
            wl.tiposDeTrabajo__c = trabajo.PN_TipoTrabajo__c;
            //wl.Trabajo__c = wr.productType; //PROBAR
            wl.Impuesto__c = tax;
            //System.debug('PRECIO VENTA--------------- ' + wr.precioVenta);
            wl.PrecioVenta__c = trabajo.Precio__c;
            wl.UnitPrice = trabajo.Precio__c;

            //wl.TareaQuote__c = wr.tareaQuote; // si tu modelo guarda el nombre
            // Si tienes un lookup real a Tarea en WOLI, podrías usar:
            // wl.Tarea__c = wr.tareaId;

            //wl.Prioridad_de_tarea__c = wr.prioridadTarea;

            /*
            if(wr.bodegaId != null) {
                wl.Bodega__c = wr.bodegaId;
            }
            */
            //wl.especificacionesTaller__c = sugerido;

            insert wl;


            ///////////////////////////////////////////////////

            tiposDeTrabajoCaso__c trabajoARealizarNuevo = new tiposDeTrabajoCaso__c();
            trabajoARealizarNuevo.Tipotrabajo__c = trabajo.PN_TipoTrabajo__c;
            trabajoARealizarNuevo.RM_WorkOrder__c = trabajo.Quote__r.Opportunity.WorkOrder__c;
            trabajoARealizarNuevo.Caso__c = trabajo.Quote__r.Opportunity.WorkOrder__r.CaseId;
            trabajoARealizarNuevo.Alias_Articulo__c = trabajo.Alias__c;
            trabajoARealizarNuevo.Aprobador__c  = trabajo.PN_Aprobador__c;
            trabajoARealizarNuevo.UTS__c  = trabajo.Cantidad__c;
            trabajoARealizarNuevo.Categor_a_de_presupuesto__c  = trabajo.PN_CategoriaPresupuesto__c;
            trabajoARealizarNuevo.Horaa__c   = trabajo.PN_Hora__c;
            trabajoARealizarNuevo.Tipo_de_cargo__c  = trabajo.PN_TipoCargo__c;
            trabajoARealizarNuevo.UTS_Real__c = trabajo.PN_UTS__c;

            insert trabajoARealizarNuevo;


            Subtipo_de_trabajo_del_caso__c subtrabajo = new Subtipo_de_trabajo_del_caso__c();
            subtrabajo.Tipo_de_trabajo_del_caso__c = trabajoARealizarNuevo.Id;
            subtrabajo.TipoDeTrabajo__c = trabajo.PN_SubtrabajoRealizar__c;
            subtrabajo.Alias__c = trabajo.PN_SubtrabajoAlias__c;
            subtrabajo.Mano_de_Obra__c  = trabajo.PN_SubtrabajoRealizar__r.ManoDeObra__c;
            subtrabajo.Name = trabajo.PN_SubtrabajoAlias__c != NULL ? trabajo.PN_SubtrabajoAlias__c : trabajo.PN_SubtrabajoRealizar__r.ManoDeObra__r.Name;
            subtrabajo.Articulo_Mano_de_Obra__c = wl.Id;
            subtrabajo.UTS__c = trabajo.Cantidad__c;
            subtrabajo.Cantidad_de_horas__c = trabajo.PN_HorasSubtrabajo__c;
            subtrabajo.Caso__c = trabajo.Quote__r.Opportunity.WorkOrder__r.CaseId;
            subtrabajo.Orden_de_trabajo__c = trabajo.Quote__r.Opportunity.WorkOrder__c;


            insert subtrabajo;

            ///////////////////////////////////////////////////////////////////

            trabajo.PN_RechazadoCaso__c = true;
            
            update trabajo;

            return res;

        } catch (Exception e) {
            
            System.debug('--aceptarTrabajoApex--  exception' + e.getMessage());
            System.debug('--aceptarTrabajoApex--  exception lines' + e.getLineNumber());

            res.exito = false;
            res.msg = e.getMessage();

            return res;
        }

       
        

    }

    public class Respuesta{
        @AuraEnabled public Boolean exito;
        @AuraEnabled public String msg;
    }
}