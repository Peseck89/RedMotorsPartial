public without sharing class BMWVinScanTrabajoGenerator {

    private static String resolveTipoVehiculoCatalogo(String tipoVehiculo) {
        if (String.isBlank(tipoVehiculo)) return 'Automóvil';

        String normalized = tipoVehiculo.trim().toUpperCase();
        if (normalized == 'AUTO' || normalized == 'AUTOS' || normalized == 'AUTOMOVIL' || normalized == 'AUTOMÓVIL') {
            return 'Automóvil';
        }

        return 'Motocicleta';
    }

    @AuraEnabled
    public static Map<String, Object> createTrabajosFromVinScan(Id caseId, Id workOrderId, String vinScanJson, String tipoCargo) {
        if (caseId == null) throw new AuraHandledException('caseId es requerido');
        if (workOrderId == null) throw new AuraHandledException('workOrderId es requerido');
        if (String.isBlank(vinScanJson)) throw new AuraHandledException('vinScanJson viene vacío');

        if (!hasField(Schema.SObjectType.tiposDeTrabajo__c, 'Identificador__c')) {
            throw new AuraHandledException('El objeto tiposDeTrabajo__c no tiene el campo Identificador__c.');
        }

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(vinScanJson);

        Map<String, Object> op = (root.containsKey('operationResult') && root.get('operationResult') != null)
            ? (Map<String, Object>) root.get('operationResult')
            : root;

        List<Object> servicesRaw = (op != null && op.containsKey('services')) ? (List<Object>) op.get('services') : null;
        if (servicesRaw == null || servicesRaw.isEmpty()) {
            throw new AuraHandledException('La respuesta no trae services[] para generar trabajos.');
        }

        List<ServiceDTO> services = new List<ServiceDTO>();
        Set<String> identifiers = new Set<String>();
        Map<String, String> nameByIdentifier = new Map<String, String>();
        Integer skippedNoIdent = 0;

        for (Object o : servicesRaw) {
            Map<String, Object> s = (Map<String, Object>) o;

            ServiceDTO dto = new ServiceDTO();
            dto.name = safeStr(s.get('name'));
            dto.advisoryText = safeStr(s.get('advisoryText'));
            dto.state = safeStr(s.get('state'));

            dto.numero = safeStr(s.get('serviceNumber'));
            if (String.isBlank(dto.numero)) dto.numero = safeStr(s.get('number'));
            if (String.isBlank(dto.numero)) dto.numero = safeStr(s.get('numero'));

            dto.identificador = normalizeIdentifier(dto.numero);

            Integer utInt = 0;
            if (s.containsKey('quantity') && s.get('quantity') != null) {
                Map<String, Object> q = (Map<String, Object>) s.get('quantity');
                Integer v = safeInt(q.get('value'));
                utInt = (v == null ? 0 : v);
            }
            dto.utInt = utInt;

            if (String.isNotBlank(dto.name)) {
                dto.name = (dto.name.length() > 80) ? dto.name.substring(0, 80) : dto.name;
            }

            if (String.isBlank(dto.identificador)) {
                skippedNoIdent++;
                services.add(dto);
                continue;
            }

            identifiers.add(dto.identificador);

            if (!nameByIdentifier.containsKey(dto.identificador) && String.isNotBlank(dto.name)) {
                nameByIdentifier.put(dto.identificador, dto.name);
            }

            services.add(dto);
        }

        if (identifiers.isEmpty()) {
            throw new AuraHandledException('No se encontró ningún Identificador (número de servicio) válido para crear tiposDeTrabajo__c.');
        }

        WorkOrder wo = [
            SELECT Id,
                   Case.Asset.Tipo_de_veh_culo__c,
                   Pricebook2Id,
                   Pricebook2.Name,
                   empresaFactura__c,
                   empresaFacturaCP__c
            FROM WorkOrder
            WHERE Id = :workOrderId
            LIMIT 1
        ];

        String empresa;
        if (wo.empresaFacturaCP__c != null) {
            EmpresaContext empresaContext = EmpresaResolver.resolve(wo.empresaFacturaCP__c);
            empresa = empresaContext.codigo;
        } else {
            empresa = wo.empresaFactura__c;
        }
        if (
            empresa != 'RMBAVARIAN' &&
            empresa != 'RMOTOBAI' &&
            empresa != 'RMPEKING'
        ) {
            throw new EmpresaConfigurationException(
                String.isBlank(empresa)
                    ? 'La empresa del WorkOrder es requerida.'
                    : 'La empresa del WorkOrder no está soportada: ' + empresa + '.'
            );
        }

        Impuesto__c impuesto0108 = [
            SELECT Id
            FROM Impuesto__c
            WHERE codigoImpuesto__c = '0108'
            LIMIT 1
        ];

        Boolean tipoTieneWorkType = hasField(Schema.SObjectType.tiposDeTrabajo__c, 'Work_Type__c');

        String camposTipo =
            'Id, Name, Identificador__c, ManoDeObra__c, ManoDeObra__r.Name, Cantidad__c' +
            (tipoTieneWorkType ? ', Work_Type__c' : '');

        List<tiposDeTrabajo__c> tiposFound = Database.query(
            'SELECT ' + camposTipo +
            ' FROM tiposDeTrabajo__c' +
            ' WHERE Identificador__c IN :identifiers'
        );

        Map<String, tiposDeTrabajo__c> tipoPorIdent = new Map<String, tiposDeTrabajo__c>();
        for (tiposDeTrabajo__c tt : tiposFound) {
            if (String.isNotBlank(tt.Identificador__c)) {
                tipoPorIdent.put(tt.Identificador__c, tt);
            }
        }

        List<tiposDeTrabajo__c> nuevosTipos = new List<tiposDeTrabajo__c>();
        for (String ident : identifiers) {
            if (!tipoPorIdent.containsKey(ident)) {
                String nombre = nameByIdentifier.get(ident);
                if (String.isBlank(nombre)) nombre = 'Servicio ' + ident;

                tiposDeTrabajo__c nuevo = new tiposDeTrabajo__c();
                nuevo.Name = (nombre.length() > 80 ? nombre.substring(0, 80) : nombre);
                nuevo.Identificador__c = ident;

                nuevosTipos.add(nuevo);
            }
        }

        if (!nuevosTipos.isEmpty()) {
            insert nuevosTipos;

            tiposFound = Database.query(
                'SELECT ' + camposTipo +
                ' FROM tiposDeTrabajo__c' +
                ' WHERE Identificador__c IN :identifiers'
            );
            tipoPorIdent.clear();
            for (tiposDeTrabajo__c tt : tiposFound) {
                if (String.isNotBlank(tt.Identificador__c)) {
                    tipoPorIdent.put(tt.Identificador__c, tt);
                }
            }
        }

        Set<Id> tipoIds = new Set<Id>();
        for (tiposDeTrabajo__c tt : tipoPorIdent.values()) tipoIds.add(tt.Id);

        Set<Id> yaEnCaso = new Set<Id>();
        for (tiposDeTrabajoCaso__c ttc : [
            SELECT Id, Tipotrabajo__c
            FROM tiposDeTrabajoCaso__c
            WHERE Caso__c = :caseId
            AND Tipotrabajo__c IN :tipoIds
        ]) {
            yaEnCaso.add(ttc.Tipotrabajo__c);
        }

        Map<String, Schema.SObjectField> ttcFields  = tiposDeTrabajoCaso__c.SObjectType.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> woliFields = WorkOrderLineItem.SObjectType.getDescribe().fields.getMap();

        Id defaultWorkTypeId = null;
        try {
            defaultWorkTypeId = [SELECT Id FROM WorkType ORDER BY Name LIMIT 1].Id;
        } catch (Exception ignore) {}

        List<tiposDeTrabajoCaso__c> nuevosTTC = new List<tiposDeTrabajoCaso__c>();
        List<TTCContext> contexts = new List<TTCContext>();
        Set<String> createdIdentifiers = new Set<String>();

        for (ServiceDTO s : services) {
            if (String.isBlank(s.identificador)) continue;

            tiposDeTrabajo__c tipo = tipoPorIdent.get(s.identificador);
            if (tipo == null) continue;
            if (yaEnCaso.contains(tipo.Id)) continue;

            Integer utsReal = (s.utInt == null ? 0 : s.utInt);
            Decimal horas = (utsReal == 0) ? 0 : (Decimal.valueOf(utsReal) / 12).setScale(3);

            Id workTypeId = defaultWorkTypeId;
            if (tipoTieneWorkType) {
                try { workTypeId = (Id) tipo.get('Work_Type__c'); } catch (Exception ignore) {}
                if (workTypeId == null) workTypeId = defaultWorkTypeId;
            }

            tiposDeTrabajoCaso__c ttcNew = new tiposDeTrabajoCaso__c();
            ttcNew.Caso__c = caseId;
            ttcNew.RM_WorkOrder__c = workOrderId;
            ttcNew.Tipotrabajo__c = tipo.Id;

            ttcNew.UTS__c = horas;
            ttcNew.UTS_Real__c = utsReal;

            ttcNew.Tipo_de_cargo__c = tipoCargo;
            ttcNew.Aprobador__c = 'Asesor';
            ttcNew.RM_EsTrabajoAdicional__c = true;
            ttcNew.Categor_a_de_presupuesto__c = mapPrioridad(s.state);

            safePut(ttcNew, ttcFields, 'Work_Type__c', workTypeId);
            safePut(ttcNew, ttcFields, 'Alias_Articulo__c', tipo.Name);

            String comentario = '';
            if (String.isNotBlank(s.numero)) comentario += 'Softland#: ' + s.numero + ' ';
            if (String.isNotBlank(s.state)) comentario += 'State: ' + s.state + ' ';
            if (String.isNotBlank(s.advisoryText)) comentario += '| ' + s.advisoryText;
            if (String.isNotBlank(comentario)) safePut(ttcNew, ttcFields, 'ComentarioTTC__c', comentario.left(255));

            nuevosTTC.add(ttcNew);
            createdIdentifiers.add(s.identificador);

            TTCContext ctx = new TTCContext();
            ctx.tipo = tipo;
            ctx.horas = horas;
            ctx.utsReal = utsReal;
            ctx.prioridad = ttcNew.Categor_a_de_presupuesto__c;
            ctx.alias = tipo.Name;
            ctx.workTypeId = workTypeId;
            contexts.add(ctx);
        }

        if (nuevosTTC.isEmpty()) {
            Map<String, Object> out0 = new Map<String, Object>();
            out0.put('createdTiposDeTrabajo', nuevosTipos.size());
            out0.put('createdTrabajosCaso', 0);
            out0.put('servicesReceived', services.size());
            out0.put('servicesSkippedNoIdent', skippedNoIdent);

            List<RM_TraerTrabajosEmailService.ServiceRow> rows0 = new List<RM_TraerTrabajosEmailService.ServiceRow>();
            for (ServiceDTO s0 : services) {
                RM_TraerTrabajosEmailService.ServiceRow r0 = new RM_TraerTrabajosEmailService.ServiceRow();
                r0.serviceNumber = s0.numero;
                r0.identificador = s0.identificador;
                r0.name = s0.name;
                r0.state = s0.state;
                r0.uts = s0.utInt;
                r0.prioridad = mapPrioridad(s0.state);
                r0.creado = (s0.identificador != null && createdIdentifiers.contains(s0.identificador));
                rows0.add(r0);
            }

            Boolean emailSent0 = RM_TraerTrabajosEmailService.sendUsageEmail(
                caseId,
                workOrderId,
                tipoCargo,
                services.size(),
                0,
                nuevosTipos.size(),
                skippedNoIdent,
                rows0
            );
            out0.put('emailSent', emailSent0);

            return out0;
        }

        insert nuevosTTC;

        String tipoVehiculoAsset = (wo.Case != null && wo.Case.Asset != null)
            ? wo.Case.Asset.Tipo_de_veh_culo__c
            : null;
        String tipoDeVehiculo = resolveTipoVehiculoCatalogo(tipoVehiculoAsset);

        String tipodecargo = tipoCargo;

        Set<Id> idsSinMano = new Set<Id>();
        Set<Id> idsManoDeObra = new Set<Id>();

        for (TTCContext ctx : contexts) {
            if (ctx.tipo.ManoDeObra__c != null) idsManoDeObra.add(ctx.tipo.ManoDeObra__c);
            else idsSinMano.add(ctx.tipo.Id);
        }

        Id manoFallback = null;
        if (!idsSinMano.isEmpty()) {
            List<TipoDeCargoConManoDeObra__c> listTC = [
                SELECT ManoDeObra__c
                FROM TipoDeCargoConManoDeObra__c
                WHERE Empresa__c = :empresa
                AND TipoDeCargo__c = :tipodecargo
                AND TipoDeVehiculo__c = :tipoDeVehiculo
                LIMIT 1
            ];
            if (listTC.isEmpty() || listTC[0].ManoDeObra__c == null) {
                throw new AuraHandledException('Tipo de cargo sin mano de obra definida.');
            }
            manoFallback = listTC[0].ManoDeObra__c;
            idsManoDeObra.add(manoFallback);
        }

        Map<String, WorkOrderLineItem> existingWolis = new Map<String, WorkOrderLineItem>();
        if (!idsManoDeObra.isEmpty()) {
            for (WorkOrderLineItem w : [
                SELECT Id, Product__c, Alias_Articulo__c
                FROM WorkOrderLineItem
                WHERE WorkOrderId = :workOrderId
                AND Product__c IN :idsManoDeObra
            ]) {
                existingWolis.put(w.Product__c + '-' + w.Alias_Articulo__c, w);
            }
        }

        Map<Id, Id> pbeByProduct = new Map<Id, Id>();
        if (!idsManoDeObra.isEmpty()) {
            for (PricebookEntry pbe : [
                SELECT Id, Product2Id
                FROM PricebookEntry
                WHERE Pricebook2Id = :wo.Pricebook2Id
                AND Product2Id IN :idsManoDeObra
                LIMIT 50000
            ]) {
                if (!pbeByProduct.containsKey(pbe.Product2Id)) {
                    pbeByProduct.put(pbe.Product2Id, pbe.Id);
                }
            }
        }

        Map<String, WorkOrderLineItem> woliByKey = new Map<String, WorkOrderLineItem>();
        List<Subtipo_de_trabajo_del_caso__c> subtToUpsert = new List<Subtipo_de_trabajo_del_caso__c>();

        for (Integer i = 0; i < nuevosTTC.size(); i++) {
            tiposDeTrabajoCaso__c padre = nuevosTTC[i];
            TTCContext ctx = contexts[i];

            Id mano = (ctx.tipo.ManoDeObra__c != null) ? ctx.tipo.ManoDeObra__c : manoFallback;
            if (mano == null) throw new AuraHandledException('No se pudo determinar Mano de Obra para: ' + ctx.tipo.Name);

            String alias = ctx.alias;
            String key = mano + '-' + alias;

            WorkOrderLineItem woli = existingWolis.containsKey(key) ? existingWolis.get(key) : new WorkOrderLineItem();
            if (woli.Id == null) {
                woli.WorkOrderId = workOrderId;
                woli.Product__c = mano;
            }

            woli.Quantity = ctx.horas;
            woli.Alias_Articulo__c = alias;

            Id pbeId = pbeByProduct.get(mano);
            if (pbeId == null) {
                throw new AuraHandledException(
                    'No hay PricebookEntry para Mano de Obra ' + String.valueOf(mano) +
                    ' en Pricebook ' + String.valueOf(wo.Pricebook2Id)
                );
            }
            woli.PricebookEntryId = pbeId;

            safePut(woli, woliFields, 'Impuesto__c', impuesto0108.Id);
            safePut(woli, woliFields, 'aprobado__c', true);
            safePut(woli, woliFields, 'especificacionesTaller__c', ctx.prioridad);
            safePut(woli, woliFields, 'tiposDeTrabajo__c', padre.Tipotrabajo__c);
            safePut(woli, woliFields, 'Trabajo__c', 'Mano de Obra');
            safePut(woli, woliFields, 'created_From__c', 'caseWorkTypes');
            safePut(woli, woliFields, 'WorkTypeId', ctx.workTypeId);

            woliByKey.put(key, woli);

            Subtipo_de_trabajo_del_caso__c sub = new Subtipo_de_trabajo_del_caso__c(
                Caso__c = caseId,
                Orden_de_trabajo__c = workOrderId,
                Name = ctx.tipo.Name,
                UTS__c = ctx.horas,
                Cantidad_de_horas__c = ctx.horas,
                TipoDeTrabajo__c = ctx.tipo.Id,
                Mano_de_Obra__c = mano,
                Alias__c = alias,
                created_From__c = 'caseWorkTypes',
                Tipo_de_trabajo_del_caso__c = padre.Id
            );
            subtToUpsert.add(sub);
        }

        List<WorkOrderLineItem> finalWolis = new List<WorkOrderLineItem>(woliByKey.values());
        upsert finalWolis;

        Map<String, Id> woliIdByKey = new Map<String, Id>();
        for (WorkOrderLineItem w : finalWolis) {
            woliIdByKey.put(w.Product__c + '-' + w.Alias_Articulo__c, w.Id);
        }

        for (Subtipo_de_trabajo_del_caso__c sub : subtToUpsert) {
            String k = sub.Mano_de_Obra__c + '-' + sub.Alias__c;
            Id wId = woliIdByKey.get(k);
            if (wId != null) sub.Articulo_Mano_de_Obra__c = wId;
        }

        upsert subtToUpsert;

        try {
            TipoTrabajoCasoController.createTipoCargo(finalWolis, tipodecargo, null, null);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'createTipoCargo warning: ' + e.getMessage());
        }

        Map<String, Object> out = new Map<String, Object>();
        out.put('createdTiposDeTrabajo', nuevosTipos.size());
        out.put('createdTrabajosCaso', nuevosTTC.size());
        out.put('servicesReceived', services.size());
        out.put('servicesSkippedNoIdent', skippedNoIdent);

        List<RM_TraerTrabajosEmailService.ServiceRow> rows = new List<RM_TraerTrabajosEmailService.ServiceRow>();
        for (ServiceDTO s1 : services) {
            RM_TraerTrabajosEmailService.ServiceRow r1 = new RM_TraerTrabajosEmailService.ServiceRow();
            r1.serviceNumber = s1.numero;
            r1.identificador = s1.identificador;
            r1.name = s1.name;
            r1.state = s1.state;
            r1.uts = s1.utInt;
            r1.prioridad = mapPrioridad(s1.state);
            r1.creado = (s1.identificador != null && createdIdentifiers.contains(s1.identificador));
            rows.add(r1);
        }

        Boolean emailSent = RM_TraerTrabajosEmailService.sendUsageEmail(
            caseId,
            workOrderId,
            tipoCargo,
            services.size(),
            nuevosTTC.size(),
            nuevosTipos.size(),
            skippedNoIdent,
            rows
        );
        out.put('emailSent', emailSent);

        return out;
    }

    @AuraEnabled
    public static Map<String, Object> createSubtrabajosFromVinScan(Id caseId, Id workOrderId, Id trabajoCasoId, String vinScanJson, String tipoCargo) {
        if (caseId == null) throw new AuraHandledException('caseId es requerido');
        if (trabajoCasoId == null) throw new AuraHandledException('trabajoCasoId es requerido');
        if (String.isBlank(vinScanJson)) throw new AuraHandledException('vinScanJson viene vacío');

        if (!hasField(Schema.SObjectType.tiposDeTrabajo__c, 'Identificador__c')) {
            throw new AuraHandledException('El objeto tiposDeTrabajo__c no tiene el campo Identificador__c.');
        }

        List<tiposDeTrabajoCaso__c> padres = [
            SELECT Id, Caso__c, RM_WorkOrder__c, Tipo_de_cargo__c
            FROM tiposDeTrabajoCaso__c
            WHERE Id = :trabajoCasoId
            AND Caso__c = :caseId
            LIMIT 1
        ];
        if (padres.isEmpty()) {
            throw new AuraHandledException('No se encontró el punto de trabajo seleccionado para este Caso.');
        }

        tiposDeTrabajoCaso__c padreSeleccionado = padres[0];
        Id targetWorkOrderId = padreSeleccionado.RM_WorkOrder__c != null ? padreSeleccionado.RM_WorkOrder__c : workOrderId;
        if (targetWorkOrderId == null) throw new AuraHandledException('workOrderId es requerido');

        String tipodecargo = String.isNotBlank(tipoCargo) ? tipoCargo : padreSeleccionado.Tipo_de_cargo__c;
        if (String.isBlank(tipodecargo)) tipodecargo = 'Cliente';

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(vinScanJson);

        Map<String, Object> op = (root.containsKey('operationResult') && root.get('operationResult') != null)
            ? (Map<String, Object>) root.get('operationResult')
            : root;

        List<Object> servicesRaw = (op != null && op.containsKey('services')) ? (List<Object>) op.get('services') : null;
        if (servicesRaw == null || servicesRaw.isEmpty()) {
            throw new AuraHandledException('La respuesta no trae services[] para generar subtrabajos.');
        }

        List<ServiceDTO> services = new List<ServiceDTO>();
        Set<String> identifiers = new Set<String>();
        Map<String, String> nameByIdentifier = new Map<String, String>();
        Integer skippedNoIdent = 0;

        for (Object o : servicesRaw) {
            Map<String, Object> s = (Map<String, Object>) o;

            ServiceDTO dto = new ServiceDTO();
            dto.name = safeStr(s.get('name'));
            dto.advisoryText = safeStr(s.get('advisoryText'));
            dto.state = safeStr(s.get('state'));

            dto.numero = safeStr(s.get('serviceNumber'));
            if (String.isBlank(dto.numero)) dto.numero = safeStr(s.get('number'));
            if (String.isBlank(dto.numero)) dto.numero = safeStr(s.get('numero'));

            dto.identificador = normalizeIdentifier(dto.numero);

            Integer utInt = 0;
            if (s.containsKey('quantity') && s.get('quantity') != null) {
                Map<String, Object> q = (Map<String, Object>) s.get('quantity');
                Integer v = safeInt(q.get('value'));
                utInt = (v == null ? 0 : v);
            }
            dto.utInt = utInt;

            if (String.isNotBlank(dto.name)) {
                dto.name = (dto.name.length() > 80) ? dto.name.substring(0, 80) : dto.name;
            }

            if (String.isBlank(dto.identificador)) {
                skippedNoIdent++;
                services.add(dto);
                continue;
            }

            identifiers.add(dto.identificador);

            if (!nameByIdentifier.containsKey(dto.identificador) && String.isNotBlank(dto.name)) {
                nameByIdentifier.put(dto.identificador, dto.name);
            }

            services.add(dto);
        }

        if (identifiers.isEmpty()) {
            throw new AuraHandledException('No se encontró ningún Identificador (número de servicio) válido para crear subtrabajos.');
        }

        WorkOrder wo = [
            SELECT Id,
                   Case.Asset.Tipo_de_veh_culo__c,
                   Pricebook2Id,
                   Pricebook2.Name,
                   empresaFactura__c,
                   empresaFacturaCP__c
            FROM WorkOrder
            WHERE Id = :targetWorkOrderId
            LIMIT 1
        ];

        String empresa;
        if (wo.empresaFacturaCP__c != null) {
            EmpresaContext empresaContext = EmpresaResolver.resolve(wo.empresaFacturaCP__c);
            empresa = empresaContext.codigo;
        } else {
            empresa = wo.empresaFactura__c;
        }
        if (
            empresa != 'RMBAVARIAN' &&
            empresa != 'RMOTOBAI' &&
            empresa != 'RMPEKING'
        ) {
            throw new EmpresaConfigurationException(
                String.isBlank(empresa)
                    ? 'La empresa del WorkOrder es requerida.'
                    : 'La empresa del WorkOrder no está soportada: ' + empresa + '.'
            );
        }

        Impuesto__c impuesto0108 = [
            SELECT Id
            FROM Impuesto__c
            WHERE codigoImpuesto__c = '0108'
            LIMIT 1
        ];

        Boolean tipoTieneWorkType = hasField(Schema.SObjectType.tiposDeTrabajo__c, 'Work_Type__c');

        String camposTipo =
            'Id, Name, Identificador__c, ManoDeObra__c, ManoDeObra__r.Name, Cantidad__c' +
            (tipoTieneWorkType ? ', Work_Type__c' : '');

        List<tiposDeTrabajo__c> tiposFound = Database.query(
            'SELECT ' + camposTipo +
            ' FROM tiposDeTrabajo__c' +
            ' WHERE Identificador__c IN :identifiers'
        );

        Map<String, tiposDeTrabajo__c> tipoPorIdent = new Map<String, tiposDeTrabajo__c>();
        for (tiposDeTrabajo__c tt : tiposFound) {
            if (String.isNotBlank(tt.Identificador__c)) {
                tipoPorIdent.put(tt.Identificador__c, tt);
            }
        }

        List<tiposDeTrabajo__c> nuevosTipos = new List<tiposDeTrabajo__c>();
        for (String ident : identifiers) {
            if (!tipoPorIdent.containsKey(ident)) {
                String nombre = nameByIdentifier.get(ident);
                if (String.isBlank(nombre)) nombre = 'Servicio ' + ident;

                tiposDeTrabajo__c nuevo = new tiposDeTrabajo__c();
                nuevo.Name = (nombre.length() > 80 ? nombre.substring(0, 80) : nombre);
                nuevo.Identificador__c = ident;

                nuevosTipos.add(nuevo);
            }
        }

        if (!nuevosTipos.isEmpty()) {
            insert nuevosTipos;

            tiposFound = Database.query(
                'SELECT ' + camposTipo +
                ' FROM tiposDeTrabajo__c' +
                ' WHERE Identificador__c IN :identifiers'
            );
            tipoPorIdent.clear();
            for (tiposDeTrabajo__c tt : tiposFound) {
                if (String.isNotBlank(tt.Identificador__c)) {
                    tipoPorIdent.put(tt.Identificador__c, tt);
                }
            }
        }

        Set<Id> tipoIds = new Set<Id>();
        for (tiposDeTrabajo__c tt : tipoPorIdent.values()) tipoIds.add(tt.Id);

        Set<Id> yaEnSubtrabajos = new Set<Id>();
        for (Subtipo_de_trabajo_del_caso__c subExistente : [
            SELECT Id, TipoDeTrabajo__c
            FROM Subtipo_de_trabajo_del_caso__c
            WHERE Tipo_de_trabajo_del_caso__c = :trabajoCasoId
            AND TipoDeTrabajo__c IN :tipoIds
        ]) {
            yaEnSubtrabajos.add(subExistente.TipoDeTrabajo__c);
        }

        Map<String, Schema.SObjectField> woliFields = WorkOrderLineItem.SObjectType.getDescribe().fields.getMap();

        Id defaultWorkTypeId = null;
        try {
            defaultWorkTypeId = [SELECT Id FROM WorkType ORDER BY Name LIMIT 1].Id;
        } catch (Exception ignore) {}

        List<TTCContext> contexts = new List<TTCContext>();
        Set<String> createdIdentifiers = new Set<String>();

        for (ServiceDTO s : services) {
            if (String.isBlank(s.identificador)) continue;

            tiposDeTrabajo__c tipo = tipoPorIdent.get(s.identificador);
            if (tipo == null) continue;
            if (yaEnSubtrabajos.contains(tipo.Id)) continue;

            Integer utsReal = (s.utInt == null ? 0 : s.utInt);
            Decimal horas = (utsReal == 0) ? 0 : (Decimal.valueOf(utsReal) / 12).setScale(3);

            Id workTypeId = defaultWorkTypeId;
            if (tipoTieneWorkType) {
                try { workTypeId = (Id) tipo.get('Work_Type__c'); } catch (Exception ignore) {}
                if (workTypeId == null) workTypeId = defaultWorkTypeId;
            }

            TTCContext ctx = new TTCContext();
            ctx.tipo = tipo;
            ctx.horas = horas;
            ctx.utsReal = utsReal;
            ctx.prioridad = mapPrioridad(s.state);
            ctx.alias = tipo.Name;
            ctx.workTypeId = workTypeId;
            contexts.add(ctx);
            createdIdentifiers.add(s.identificador);
        }

        if (contexts.isEmpty()) {
            Map<String, Object> out0 = new Map<String, Object>();
            out0.put('createdTiposDeTrabajo', nuevosTipos.size());
            out0.put('createdTrabajosCaso', 0);
            out0.put('createdSubtrabajos', 0);
            out0.put('servicesReceived', services.size());
            out0.put('servicesSkippedNoIdent', skippedNoIdent);

            List<RM_TraerTrabajosEmailService.ServiceRow> rows0 = new List<RM_TraerTrabajosEmailService.ServiceRow>();
            for (ServiceDTO s0 : services) {
                RM_TraerTrabajosEmailService.ServiceRow r0 = new RM_TraerTrabajosEmailService.ServiceRow();
                r0.serviceNumber = s0.numero;
                r0.identificador = s0.identificador;
                r0.name = s0.name;
                r0.state = s0.state;
                r0.uts = s0.utInt;
                r0.prioridad = mapPrioridad(s0.state);
                r0.creado = (s0.identificador != null && createdIdentifiers.contains(s0.identificador));
                rows0.add(r0);
            }

            Boolean emailSent0 = RM_TraerTrabajosEmailService.sendUsageEmail(
                caseId,
                targetWorkOrderId,
                tipodecargo,
                services.size(),
                0,
                nuevosTipos.size(),
                skippedNoIdent,
                rows0
            );
            out0.put('emailSent', emailSent0);

            return out0;
        }

        String tipoVehiculoAsset = (wo.Case != null && wo.Case.Asset != null)
            ? wo.Case.Asset.Tipo_de_veh_culo__c
            : null;
        String tipoDeVehiculo = resolveTipoVehiculoCatalogo(tipoVehiculoAsset);

        Set<Id> idsSinMano = new Set<Id>();
        Set<Id> idsManoDeObra = new Set<Id>();

        for (TTCContext ctx : contexts) {
            if (ctx.tipo.ManoDeObra__c != null) idsManoDeObra.add(ctx.tipo.ManoDeObra__c);
            else idsSinMano.add(ctx.tipo.Id);
        }

        Id manoFallback = null;
        if (!idsSinMano.isEmpty()) {
            List<TipoDeCargoConManoDeObra__c> listTC = [
                SELECT ManoDeObra__c
                FROM TipoDeCargoConManoDeObra__c
                WHERE Empresa__c = :empresa
                AND TipoDeCargo__c = :tipodecargo
                AND TipoDeVehiculo__c = :tipoDeVehiculo
                LIMIT 1
            ];
            if (listTC.isEmpty() || listTC[0].ManoDeObra__c == null) {
                throw new AuraHandledException('Tipo de cargo sin mano de obra definida.');
            }
            manoFallback = listTC[0].ManoDeObra__c;
            idsManoDeObra.add(manoFallback);
        }

        Map<String, WorkOrderLineItem> existingWolis = new Map<String, WorkOrderLineItem>();
        if (!idsManoDeObra.isEmpty()) {
            for (WorkOrderLineItem w : [
                SELECT Id, Product__c, Alias_Articulo__c
                FROM WorkOrderLineItem
                WHERE WorkOrderId = :targetWorkOrderId
                AND Product__c IN :idsManoDeObra
            ]) {
                existingWolis.put(w.Product__c + '-' + w.Alias_Articulo__c, w);
            }
        }

        Map<Id, Id> pbeByProduct = new Map<Id, Id>();
        if (!idsManoDeObra.isEmpty()) {
            for (PricebookEntry pbe : [
                SELECT Id, Product2Id
                FROM PricebookEntry
                WHERE Pricebook2Id = :wo.Pricebook2Id
                AND Product2Id IN :idsManoDeObra
                LIMIT 50000
            ]) {
                if (!pbeByProduct.containsKey(pbe.Product2Id)) {
                    pbeByProduct.put(pbe.Product2Id, pbe.Id);
                }
            }
        }

        Map<String, WorkOrderLineItem> woliByKey = new Map<String, WorkOrderLineItem>();
        List<Subtipo_de_trabajo_del_caso__c> subtToUpsert = new List<Subtipo_de_trabajo_del_caso__c>();

        for (TTCContext ctx : contexts) {
            Id mano = (ctx.tipo.ManoDeObra__c != null) ? ctx.tipo.ManoDeObra__c : manoFallback;
            if (mano == null) throw new AuraHandledException('No se pudo determinar Mano de Obra para: ' + ctx.tipo.Name);

            String alias = ctx.alias;
            String key = mano + '-' + alias;

            WorkOrderLineItem woli = existingWolis.containsKey(key) ? existingWolis.get(key) : new WorkOrderLineItem();
            if (woli.Id == null) {
                woli.WorkOrderId = targetWorkOrderId;
                woli.Product__c = mano;
            }

            woli.Quantity = ctx.horas;
            woli.Alias_Articulo__c = alias;

            Id pbeId = pbeByProduct.get(mano);
            if (pbeId == null) {
                throw new AuraHandledException(
                    'No hay PricebookEntry para Mano de Obra ' + String.valueOf(mano) +
                    ' en Pricebook ' + String.valueOf(wo.Pricebook2Id)
                );
            }
            woli.PricebookEntryId = pbeId;

            safePut(woli, woliFields, 'Impuesto__c', impuesto0108.Id);
            safePut(woli, woliFields, 'aprobado__c', true);
            safePut(woli, woliFields, 'especificacionesTaller__c', ctx.prioridad);
            safePut(woli, woliFields, 'tiposDeTrabajo__c', ctx.tipo.Id);
            safePut(woli, woliFields, 'Trabajo__c', 'Mano de Obra');
            safePut(woli, woliFields, 'created_From__c', 'caseWorkTypes');
            safePut(woli, woliFields, 'WorkTypeId', ctx.workTypeId);

            woliByKey.put(key, woli);

            Subtipo_de_trabajo_del_caso__c sub = new Subtipo_de_trabajo_del_caso__c(
                Caso__c = caseId,
                Orden_de_trabajo__c = targetWorkOrderId,
                Name = ctx.tipo.Name,
                UTS__c = ctx.horas,
                Cantidad_de_horas__c = ctx.horas,
                TipoDeTrabajo__c = ctx.tipo.Id,
                Mano_de_Obra__c = mano,
                Alias__c = alias,
                created_From__c = 'caseWorkTypes',
                Tipo_de_trabajo_del_caso__c = trabajoCasoId
            );
            subtToUpsert.add(sub);
        }

        clearInvalidMechanicReferences(caseId, trabajoCasoId);

        List<WorkOrderLineItem> finalWolis = new List<WorkOrderLineItem>(woliByKey.values());
        upsert finalWolis;

        Map<String, Id> woliIdByKey = new Map<String, Id>();
        for (WorkOrderLineItem w : finalWolis) {
            woliIdByKey.put(w.Product__c + '-' + w.Alias_Articulo__c, w.Id);
        }

        for (Subtipo_de_trabajo_del_caso__c sub : subtToUpsert) {
            String k = sub.Mano_de_Obra__c + '-' + sub.Alias__c;
            Id wId = woliIdByKey.get(k);
            if (wId != null) sub.Articulo_Mano_de_Obra__c = wId;
        }

        upsert subtToUpsert;

        try {
            TipoTrabajoCasoController.createTipoCargo(finalWolis, tipodecargo, null, null);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'createTipoCargo warning: ' + e.getMessage());
        }

        Map<String, Object> out = new Map<String, Object>();
        out.put('createdTiposDeTrabajo', nuevosTipos.size());
        out.put('createdTrabajosCaso', 0);
        out.put('createdSubtrabajos', subtToUpsert.size());
        out.put('servicesReceived', services.size());
        out.put('servicesSkippedNoIdent', skippedNoIdent);

        List<RM_TraerTrabajosEmailService.ServiceRow> rows = new List<RM_TraerTrabajosEmailService.ServiceRow>();
        for (ServiceDTO s1 : services) {
            RM_TraerTrabajosEmailService.ServiceRow r1 = new RM_TraerTrabajosEmailService.ServiceRow();
            r1.serviceNumber = s1.numero;
            r1.identificador = s1.identificador;
            r1.name = s1.name;
            r1.state = s1.state;
            r1.uts = s1.utInt;
            r1.prioridad = mapPrioridad(s1.state);
            r1.creado = (s1.identificador != null && createdIdentifiers.contains(s1.identificador));
            rows.add(r1);
        }

        Boolean emailSent = RM_TraerTrabajosEmailService.sendUsageEmail(
            caseId,
            targetWorkOrderId,
            tipodecargo,
            services.size(),
            subtToUpsert.size(),
            nuevosTipos.size(),
            skippedNoIdent,
            rows
        );
        out.put('emailSent', emailSent);

        return out;
    }

    private static String safeStr(Object v) { return v == null ? null : String.valueOf(v); }

    private static Integer safeInt(Object v) {
        if (v == null) return null;
        if (v instanceof Integer) return (Integer) v;
        try { return Integer.valueOf(String.valueOf(v)); } catch (Exception e) { return null; }
    }

    private static String normalizeIdentifier(String raw) {
        if (String.isBlank(raw)) return null;
        return raw.trim();
    }

    private static String mapPrioridad(String state) {
        if (String.isBlank(state)) return 'Sugerido';
        String s = state.toUpperCase();
        if (s == 'RED') return 'Necesario';
        if (s == 'YELLOW') return 'Recomendado';
        if (s == 'GREEN') return 'Sugerido';
        return 'Sugerido';
    }

    private static Boolean hasField(Schema.SObjectType t, String fieldApi) {
        return t.getDescribe().fields.getMap().containsKey(fieldApi);
    }

    private static Boolean hasField(Schema.DescribeSObjectResult d, String fieldApi) {
        return d.fields.getMap().containsKey(fieldApi);
    }

    private static void clearInvalidMechanicReferences(Id caseId, Id trabajoCasoId) {
        if (caseId == null && trabajoCasoId == null) return;

        Case caseRecord = null;
        if (caseId != null && hasField(Schema.SObjectType.Case, 'Mecanico_Asignado__c')) {
            List<Case> cases = [
                SELECT Id, Mecanico_Asignado__c
                FROM Case
                WHERE Id = :caseId
                AND Mecanico_Asignado__c != null
                LIMIT 1
            ];
            if (!cases.isEmpty()) {
                caseRecord = cases[0];
            }
        }

        List<WorkStep> steps = new List<WorkStep>();
        if (trabajoCasoId != null) {
            steps = [
                SELECT Id, RM_Mecanico__c, mecanico__c, Mec_nico_asignado__c
                FROM WorkStep
                WHERE Tipo_de_trabajo_del_caso__c = :trabajoCasoId
                AND (
                    RM_Mecanico__c != null
                    OR mecanico__c != null
                    OR Mec_nico_asignado__c != null
                )
            ];
        }
        if (caseRecord == null && steps.isEmpty()) return;

        Set<Id> mechanicIds = new Set<Id>();
        if (caseRecord != null && caseRecord.Mecanico_Asignado__c != null) {
            mechanicIds.add(caseRecord.Mecanico_Asignado__c);
        }
        for (WorkStep step : steps) {
            if (step.RM_Mecanico__c != null) mechanicIds.add(step.RM_Mecanico__c);
            if (step.mecanico__c != null) mechanicIds.add(step.mecanico__c);
            if (step.Mec_nico_asignado__c != null) mechanicIds.add(step.Mec_nico_asignado__c);
        }
        if (mechanicIds.isEmpty()) return;

        Map<Id, Contact> contactsById = new Map<Id, Contact>([
            SELECT Id, RecordType.Name
            FROM Contact
            WHERE Id IN :mechanicIds
        ]);

        List<WorkStep> stepsToUpdate = new List<WorkStep>();
        for (WorkStep step : steps) {
            WorkStep cleanStep = new WorkStep(Id = step.Id);
            Boolean shouldUpdate = false;

            if (isMissingContact(step.RM_Mecanico__c, contactsById)) {
                cleanStep.RM_Mecanico__c = null;
                shouldUpdate = true;
            }
            if (isMissingContact(step.Mec_nico_asignado__c, contactsById)) {
                cleanStep.Mec_nico_asignado__c = null;
                shouldUpdate = true;
            }
            if (
                isMissingContact(step.mecanico__c, contactsById)
                || isInvalidMecanicoLookup(step.mecanico__c, contactsById)
            ) {
                cleanStep.mecanico__c = null;
                shouldUpdate = true;
            }

            if (shouldUpdate) stepsToUpdate.add(cleanStep);
        }

        if (!stepsToUpdate.isEmpty()) {
            update stepsToUpdate;
        }

        if (
            caseRecord != null
            && (
                isMissingContact(caseRecord.Mecanico_Asignado__c, contactsById)
                || isInvalidMecanicoLookup(caseRecord.Mecanico_Asignado__c, contactsById)
            )
        ) {
            update new Case(
                Id = caseRecord.Id,
                Mecanico_Asignado__c = null
            );
        }
    }

    private static Boolean isMissingContact(Id contactId, Map<Id, Contact> contactsById) {
        return contactId != null && !contactsById.containsKey(contactId);
    }

    private static Boolean isInvalidMecanicoLookup(Id contactId, Map<Id, Contact> contactsById) {
        if (contactId == null || !contactsById.containsKey(contactId)) return false;
        Contact mechanic = contactsById.get(contactId);
        return mechanic.RecordType == null || mechanic.RecordType.Name != 'Contacto de Taller';
    }

    private static void safePut(SObject sobj, Map<String, Schema.SObjectField> fmap, String fieldApi, Object value) {
        if (value == null) return;
        if (fmap == null || !fmap.containsKey(fieldApi)) return;

        Schema.DescribeFieldResult d = fmap.get(fieldApi).getDescribe();
        Boolean isInsert = (sobj.get('Id') == null);
        if (isInsert && !d.isCreateable()) return;
        if (!isInsert && !d.isUpdateable()) return;

        sobj.put(fieldApi, value);
    }

    private class ServiceDTO {
        public String name;
        public String advisoryText;
        public String state;
        public String numero;
        public String identificador;
        public Integer utInt;
    }

    private class TTCContext {
        public tiposDeTrabajo__c tipo;
        public Decimal horas;
        public Integer utsReal;
        public String prioridad;
        public String alias;
        public Id workTypeId;
    }


	
}
