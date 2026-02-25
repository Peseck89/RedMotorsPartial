// QuoteServiceController.cls
public with sharing class QuoteServiceController {
        public class TareaAgrupada {
        @AuraEnabled public String nombreTarea {get; set;}
        @AuraEnabled public String prioridad {get; set;}
        @AuraEnabled public String tareaName {get; set;}
        @AuraEnabled public Decimal totalTarea {get; set;}
        @AuraEnabled public Integer cantidadItems {get; set;}
        @AuraEnabled public String trabajoARealizarId {get; set;}
        @AuraEnabled public String tareaId {get; set;}
        @AuraEnabled public Boolean yaEnviada {get; set;} // Nuevo campo
        @AuraEnabled public Integer itemsEnviados {get; set;} // Nuevo campo
    }
    
    @AuraEnabled(cacheable=true)
    public static List<TareaAgrupada> getTareasAgrupadas(String quoteId) {
        try {
            System.debug('getTareasAgrupadas called with quoteId: ' + quoteId);
            
            // Obtener todos los QuoteLineItems del quote
            List<QuoteLineItem> productosTarea = [
                SELECT Id, Product2.Name, UnitPrice, TotalPrice, Quantity,
                       BMW_TipoDeArticulo__c, Tarea__c, Categor_a_de_presupuesto__c,
                       Description, TrabajoARealizar__c, TrabajoARealizar__r.Name,
                       BMW_Alias__c, Enviar_presupuesto_a_service__c // Agregar este campo
                FROM QuoteLineItem
                WHERE QuoteId = :quoteId
                ORDER BY CreatedDate ASC
            ];
            
            System.debug('Found ' + productosTarea.size() + ' QuoteLineItems');
            
            // Mapa temporal para agrupar por tarea
            Map<String, TareaAgrupada> mapaTareas = new Map<String, TareaAgrupada>();
            
            for(QuoteLineItem qli : productosTarea) {
                String tareaNombre = qli.Tarea__c != null ? qli.Tarea__c : 'Sin Tarea';
                String prioridad = qli.Categor_a_de_presupuesto__c != null ? qli.Categor_a_de_presupuesto__c : 'Normal';
                String nombreTarea = qli.BMW_Alias__c != null ? qli.BMW_Alias__c :  (qli.TrabajoARealizar__r != null ? qli.TrabajoARealizar__r.Name : 'Sin nombre');
                
                // Crear bloque de tarea si no existe
                if(!mapaTareas.containsKey(tareaNombre)) {
                    TareaAgrupada tarea = new TareaAgrupada();
                    tarea.nombreTarea = tareaNombre;
                    tarea.prioridad = prioridad;
                    tarea.tareaName = nombreTarea;
                    tarea.totalTarea = 0;
                    tarea.cantidadItems = 0;
                    tarea.trabajoARealizarId = qli.TrabajoARealizar__c;
                    tarea.tareaId = qli.Tarea__c;
                    tarea.yaEnviada = false;
                    tarea.itemsEnviados = 0;
                    
                    mapaTareas.put(tareaNombre, tarea);
                }
                
                // Actualizar totales y estado de envío
                TareaAgrupada tarea = mapaTareas.get(tareaNombre);
                tarea.totalTarea += qli.TotalPrice != null ? qli.TotalPrice : 0;
                tarea.cantidadItems += 1;
                
                // Verificar si el item ya fue enviado
                if (qli.Enviar_presupuesto_a_service__c == true) {
                    tarea.itemsEnviados += 1;
                }
            }
            
            // Determinar si la tarea completa ya fue enviada
            List<TareaAgrupada> resultado = new List<TareaAgrupada>();
            for (TareaAgrupada tarea : mapaTareas.values()) {
                // Si todos los items de la tarea fueron enviados, marcar como ya enviada
                tarea.yaEnviada = (tarea.itemsEnviados == tarea.cantidadItems);
                resultado.add(tarea);
            }
            
            // Ordenar por prioridad y nombre
            resultado.sort(new TareaComparator());
            
            System.debug('Returning ' + resultado.size() + ' grouped tasks');
            for (TareaAgrupada tarea : resultado) {
                System.debug('Tarea: ' + tarea.tareaName + ', YaEnviada: ' + tarea.yaEnviada + ', ItemsEnviados: ' + tarea.itemsEnviados + '/' + tarea.cantidadItems);
            }
            
            return resultado;
            
        } catch (Exception e) { System.debug('Error in getTareasAgrupadas: ' + e.getMessage()); throw new AuraHandledException('Error al obtener tareas agrupadas: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<QuoteLineItem> getItemsPorTarea(String quoteId, String trabajoARealizarId, String tareaId) {
        try {
            System.debug('getItemsPorTarea called - quoteId: ' + quoteId + ', trabajoId: ' + trabajoARealizarId + ', tareaId: ' + tareaId);
            
            String query = 'SELECT Id, Product2.Name, Product2Id, Quantity, UnitPrice, TotalPrice, ' +
                          'Discount, BMW_TipoDeArticulo__c, Tarea__c, TrabajoARealizar__c, ' +
                          'TrabajoARealizar__r.Name, Description, BMW_Alias__c, ' +
                          'Categor_a_de_presupuesto__c, Enviar_presupuesto_a_service__c ' + // Agregar este campo
                          'FROM QuoteLineItem ' +
                          'WHERE QuoteId = :quoteId ';
            
            if (tareaId != null && tareaId != 'null' && tareaId != '') {
                query += 'AND Tarea__c = :tareaId ';
            } else {
                query += 'AND (Tarea__c = null OR Tarea__c = \'\') ';
            }
            
            query += 'ORDER BY BMW_TipoDeArticulo__c NULLS LAST, Product2.Name';
            
            List<QuoteLineItem> items = Database.query(query);
            System.debug('Found ' + items.size() + ' items for the task');
            
            return items;
            
        } catch (Exception e) { System.debug('Error in getItemsPorTarea: ' + e.getMessage()); throw new AuraHandledException('Error al obtener items de la tarea: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateItemsPorTarea(String quoteId, List<String> tareaIds, Boolean sendToService) {Savepoint sp = Database.setSavepoint();
        
        try {
            System.debug('updateItemsPorTarea called with ' + tareaIds.size() + ' tasks, sendToService: ' + sendToService);
            
            // 1. Obtener el Quote y verificar si necesita actualización
            Quote quoteActual = [SELECT Id, Enviar_presupuesto_a_service__c FROM Quote WHERE Id = :quoteId LIMIT 1];Boolean actualizarQuote = (sendToService && quoteActual.Enviar_presupuesto_a_service__c != true);
            
            // 2. Extraer todos los valores de Tarea__c de los IDs
            Set<String> tareaValores = new Set<String>();
            for (String tareaCompletaId : tareaIds) { String[] parts = tareaCompletaId.split('_'); if (parts.size() >= 2) {tareaValores.add(parts[1]);
                }
            }
            
            System.debug('Tarea valores a procesar: ' + tareaValores);
            
            // 3. Buscar TODOS los QuoteLineItems de las tareas seleccionadas
            List<QuoteLineItem> itemsToUpdate = [
                SELECT Id, Enviar_presupuesto_a_service__c 
                FROM QuoteLineItem 
                WHERE QuoteId = :quoteId AND Tarea__c IN :tareaValores
            ];
            
            System.debug('Encontrados ' + itemsToUpdate.size() + ' items para actualizar');
            
            // 4. Preparar las actualizaciones
            List<SObject> objetosParaActualizar = new List<SObject>();
            
            // Actualizar QuoteLineItems
            for (QuoteLineItem item : itemsToUpdate) {item.Enviar_presupuesto_a_service__c = true;item.Estado_aprobaci_n_service__c = 'Pendiente';item.Aprobado_service__c = false;objetosParaActualizar.add(item);
                // if (item.Enviar_presupuesto_a_service__c != sendToService) {
                //     item.Enviar_presupuesto_a_service__c = sendToService;
                //     objetosParaActualizar.add(item);
                // }
            }
            
            // Actualizar Quote si es necesario
            if (actualizarQuote) {  quoteActual.Enviar_presupuesto_a_service__c = true; objetosParaActualizar.add(quoteActual);
                System.debug('Quote marcado para actualización');
            }
            
            // 5. Ejecutar las actualizaciones
            if (!objetosParaActualizar.isEmpty()) { update objetosParaActualizar;
                System.debug('Successfully updated ' + objetosParaActualizar.size() + ' objects');
                
                if (actualizarQuote) {
                    System.debug('Quote actualizado con Enviar_presupuesto_a_service__c = true');
                }
            } else {
                System.debug('No hay objetos para actualizar');
            }
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Error in updateItemsPorTarea: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error al actualizar items y quote: ' + e.getMessage());
        }
    }
    
    // Comparator para ordenar tareas por prioridad y nombre
    private class TareaComparator implements Comparator<TareaAgrupada> {
        public Integer compare(TareaAgrupada t1, TareaAgrupada t2) {
            Map<String, Integer> prioridadOrder = new Map<String, Integer>{
                'Necesario' => 1,
                'Recomendado' => 2,
                'Sugerido' => 3,
                'Normal' => 4
            };
            
            Integer order1 = prioridadOrder.get(t1.prioridad) != null ? prioridadOrder.get(t1.prioridad) : 5;
            Integer order2 = prioridadOrder.get(t2.prioridad) != null ? prioridadOrder.get(t2.prioridad) : 5;
            
            if (order1 != order2) {
                return order1 - order2;
            }
            
            return t1.tareaName.compareTo(t2.tareaName);
        }
    }
}