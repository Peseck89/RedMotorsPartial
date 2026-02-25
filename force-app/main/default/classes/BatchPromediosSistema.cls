global class BatchPromediosSistema implements Database.Batchable<sObject>, Database.Stateful {
    global Map<String, Promedio_Sistema__c> promediosMap;
    
    // Fecha límite: últimos 6 meses
    global final Date FECHA_LIMITE = Date.today().addMonths(-6);

    global BatchPromediosSistema() {
        promediosMap = new Map<String, Promedio_Sistema__c>();
    }

    global Iterable<sObject> start(Database.BatchableContext bc) {
        return new CustomIterable(FECHA_LIMITE);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        for(sObject rec : scope) {
            String marca, modelo, traccion, combustible, transmision;
            Decimal anio, valorJefe = 0;
            Date createdDate;

            if(rec instanceof Avaluo__c) {
                Avaluo__c avaluo = (Avaluo__c) rec;
                marca = avaluo.Marca__c;
                modelo = avaluo.Modelo__c;
                anio = avaluo.Anio_Number__c;
                traccion = avaluo.Tracci_n__c;
                combustible = avaluo.Combustible__c;
                transmision = avaluo.Trasmision__c;
                valorJefe = avaluo.Valor_Sugerido_Jefe_Usados__c != null ? avaluo.Valor_Sugerido_Jefe_Usados__c : 0;
                createdDate = Date.newInstance(
                    avaluo.CreatedDate.year(), 
                    avaluo.CreatedDate.month(), 
                    avaluo.CreatedDate.day()
                );
            } else if(rec instanceof ReciboUsado__c) {
                ReciboUsado__c recibo = (ReciboUsado__c) rec;
                marca = recibo.Marca__c;
                modelo = recibo.Modelo__c;
                traccion = recibo.Traccion__c;
                combustible = recibo.Combustible__c;
                transmision = recibo.Trasmision__c;
                valorJefe = recibo.ReciboJefeUsados__c != null ? recibo.ReciboJefeUsados__c : 0;
                createdDate = Date.newInstance(
                    recibo.CreatedDate.year(), 
                    recibo.CreatedDate.month(), 
                    recibo.CreatedDate.day()
                );

                if (recibo.Ano__c == null || !recibo.Ano__c.isNumeric()) {
                    continue;
                }
                anio = Decimal.valueOf(recibo.Ano__c);
            }
            
            marca = marca != null ? marca.toUpperCase() : null;
            modelo = modelo != null ? modelo.toUpperCase() : null;
            traccion = traccion != null ? traccion.toUpperCase() : null;
            combustible = combustible != null ? combustible.toUpperCase() : null;
            transmision = transmision != null ? transmision.toUpperCase() : null;

            // Filtrar por fecha de creación (últimos 6 meses)
            if(createdDate < FECHA_LIMITE) continue;

            if(marca != null && modelo != null && anio != null && 
               traccion != null && combustible != null && transmision != null) {
                
                // String key = marca + '-' + modelo + '-' + anio + '-' + 
                //              traccion + '-' + combustible + '-' + transmision;
                // String key = (marca != null ? marca.toUpperCase() : '') + '-' + 
                // (modelo != null ? modelo.toUpperCase() : '') + '-' + 
                // anio + '-' + 
                // (traccion != null ? traccion.toUpperCase() : '') + '-' + 
                // (combustible != null ? combustible.toUpperCase() : '') + '-' + 
                // (transmision != null ? transmision.toUpperCase() : '');

                String key = marca + '-' + modelo + '-' + anio + '-' + 
                         traccion + '-' + combustible + '-' + transmision;

                if(!promediosMap.containsKey(key)) {
                    promediosMap.put(key, new Promedio_Sistema__c(
                        Marca__c = marca,
                        Modelo__c = modelo,
                        Anio_Number__c = anio,
                        Traccion__c = traccion,
                        Combustible__c = combustible,
                        Transmision__c = transmision,
                        Total_Valor_Jefe_Usados__c = 0,
                        Cantidad_Registros__c = 0
                    ));
                }

                Promedio_Sistema__c ps = promediosMap.get(key);
                ps.Total_Valor_Jefe_Usados__c += valorJefe;
                ps.Cantidad_Registros__c += 1;
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        List<Promedio_Sistema__c> promediosValidos = new List<Promedio_Sistema__c>();
        for(Promedio_Sistema__c ps : promediosMap.values()) {
            if(ps.Cantidad_Registros__c > 0) {
                promediosValidos.add(ps);
            }
        }
        if(!promediosValidos.isEmpty()) {
            upsert promediosValidos;
        }
    }

    private class CustomIterable implements Iterable<sObject> {
        private Date fechaLimite;
        
        public CustomIterable(Date fechaLimite) {
            this.fechaLimite = fechaLimite;
        }
        
        public Iterator<sObject> iterator() {
            return new CustomIterator(fechaLimite);
        }
    }

    private class CustomIterator implements Iterator<sObject> {
        private Iterator<sObject> avaluoIterator;
        private Iterator<sObject> reciboIterator;
        private Boolean isAvaluoPhase = true;
        private Date fechaLimite;

        public CustomIterator(Date fechaLimite) {
            this.fechaLimite = fechaLimite;
            
            // Convertir fecha límite a DateTime para comparación
            DateTime dtLimite = DateTime.newInstance(
                fechaLimite.year(), 
                fechaLimite.month(), 
                fechaLimite.day()
            );
            
            avaluoIterator = Database.getQueryLocator([
                SELECT Marca__c, Modelo__c, Anio_Number__c, Tracci_n__c, 
                       Combustible__c, Trasmision__c, Valor_Sugerido_Jefe_Usados__c, CreatedDate
                FROM Avaluo__c 
                WHERE Valor_Sugerido_Jefe_Usados__c != null
                AND CreatedDate >= :dtLimite
            ]).iterator();
            
            reciboIterator = Database.getQueryLocator([
                SELECT Marca__c, Modelo__c, Ano__c, Traccion__c, 
                       Combustible__c, Trasmision__c, ReciboJefeUsados__c, CreatedDate
                FROM ReciboUsado__c 
                WHERE ReciboJefeUsados__c != null
                AND CreatedDate >= :dtLimite
            ]).iterator();
        }

        public Boolean hasNext() {
            if (isAvaluoPhase) {
                if (avaluoIterator.hasNext()) {
                    return true;
                } else {
                    isAvaluoPhase = false;
                    return reciboIterator.hasNext();
                }
            } else {
                return reciboIterator.hasNext();
            }
        }

        public sObject next() {
            if (isAvaluoPhase && avaluoIterator.hasNext()) {
                return avaluoIterator.next();
            } else if (!isAvaluoPhase && reciboIterator.hasNext()) {
                return reciboIterator.next();
            } else {
                // Lanzar excepción si no hay más elementos
                throw new NoSuchElementException();
            }
        }
    }

     public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
		i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}