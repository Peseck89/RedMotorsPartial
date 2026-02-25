// This file is generated as an Apex representation of the
//     corresponding sObject and its fields.
// This read-only file is used by the Apex Language Server to
//     provide code smartness, and is deleted each time you
//     refresh your sObject definitions.
// To edit your sObjects and their fields, edit the corresponding
//     .object-meta.xml and .field-meta.xml files.

global class Oportunidad_de_Financiamiento__c {
    global Id Id;
    global SObject Owner;
    global Id OwnerId;
    global Boolean IsDeleted;
    global String Name;
    global String CurrencyIsoCode;
    global RecordType RecordType;
    global Id RecordTypeId;
    global Datetime CreatedDate;
    global User CreatedBy;
    global Id CreatedById;
    global Datetime LastModifiedDate;
    global User LastModifiedBy;
    global Id LastModifiedById;
    global Datetime SystemModstamp;
    global Date LastActivityDate;
    global Datetime LastViewedDate;
    global Datetime LastReferencedDate;
    global String Ano__c;
    global User Aprobador__r;
    global Id Aprobador__c;
    global String Campana__c;
    global String Categoria__c;
    global String ComentariosAltica__c;
    global Decimal CuotaTotal__c;
    global Double DiasSinSegdespuesCambioEstado__c;
    global Double Valor_OF_Carga__c;
    global Boolean EnvioAlerta__c;
    global String Estado__c;
    global String EtapaOP__c;
    global String Etapa__c;
    global Datetime FechaCambioEstadoOF__c;
    global Datetime FechaInicioOF__c;
    global String IndicadorEstadoOF__c;
    global Decimal Ingreso__c;
    global String Marca__c;
    global String Modelo__c;
    global String ModenaIngreso__c;
    /* Moneda para paybac
    */
    global String Moneda__c;
    global Decimal MontoFinanciar__c;
    global Decimal Monto_Recibo__c;
    global String Nombre_del_Cliente__c;
    global String NumeroIdentificacion__c;
    /* Comentarios de uso exclusivo por Altica.
    */
    global String Observaciones__c;
    global Opportunity Oportunidad__r;
    global Id Oportunidad__c;
    global String Plazo__c;
    global Double PorcentajeGarantia__c;
    global Decimal Prima__c;
    global String Producto__c;
    global Double RCI__c;
    global String Numero_Operacion_Altica__c;
    global Double Score__c;
    global String Subcategoria__c;
    global String Sucursal__c;
    global String Telefono__c;
    global Double Tiempo_de_respuesta_en_Min__c;
    global String TipoProducto__c;
    global Decimal Valor__c;
    global String Vendedor__c;
    /* Comentarios visibles en la oportunidad de RM.
    */
    global String ComentariosFinancieros__c;
    global String EmailVendedorOP__c;
    global String Email__c;
    global String PlazoMeses__c;
    global Decimal PrecioLista__c;
    global Double Time_to_Yes__c;
    global Decimal Monto_a_Financiar_OF_Carga__c;
    global String Ano_2__c;
    global Double Cantidad_2__c;
    global Double Cantidad__c;
    global String Marca_2__c;
    global String Modelo_2__c;
    global Decimal Precio_de_la_Lista_2__c;
    global String Marca_Usado__c;
    global Campaign Campana_Altica__r;
    global Id Campana_Altica__c;
    global String Marca_Altica__c;
    global String Modelo_Altica__c;
    global String Movil_Altica__c;
    global Account Nombre_Cliente_Altica__r;
    global Id Nombre_Cliente_Altica__c;
    global String Numero_de_Identificacion_Altica__c;
    global Double PlazoOF__c;
    global Decimal Prima_Altica__c;
    global String Sucursal_Altica__c;
    global Decimal Valor_Altica__c;
    /* Campo Vendedor para las oportunidad de financiamiento que entra directamente por Altica
    */
    global User Vendedor_Altica__r;
    /* Campo Vendedor para las oportunidad de financiamiento que entra directamente por Altica
    */
    global Id Vendedor_Altica__c;
    global String Vendedor_Externo__c;
    global String cuentaId__c;
    global Boolean ejecutar__c;
    global String Excepcion__c;
    global Decimal Monto_a_Financiar_Altica__c;
    global String Raz_n_de_Perdida__c;
    global String Competencia__c;
    global Double Cantidad_Total__c;
    global Date Fecha_Formalizacion__c;
    global String RazonPerdidaFinanciamiento__c;
    global String Numero_Operacion_SAF__c;
    /* Marcar con check para guardar la oportunidad de financiamiento siempre y cuando el cliente tiene una o mas oportunidades de financiamiento.
    */
    global Boolean Posee_varias_OpFs__c;
    global String Marca_Final__c;
    global String Modelo_Final__c;
    global Double Monto_a_Financiar_Total__c;
    global String Numero_Idenficacion_Final__c;
    global String Plazo_Total__c;
    global Double Precio_Lista_Total__c;
    global Double Prima_Total__c;
    global String Sucursal_Final__c;
    global Double Valor_Total__c;
    global String Vendedor_Final__c;
    global Boolean opNoVigente__c;
    global Double Tasa_Formalizacion__c;
    global String Origen__c;
    global Double Monto_Financiamiento_Neto__c;
    global String Comentarios_de_cancelacion__c;
    global String Motivo_de_cancelacion__c;
    global String Mes_fechaInicioOP__c;
    global String Ao_FechaInicioOP__c;
    global String Mes_FechaCambioEstado__c;
    global String Ao_FechaCambioEstado__c;
    global String Mes_FechaFormalizacion__c;
    global String Ao_FechaFormalizacion__c;
    global Boolean Bienvenida__c;
    global String Vendedor_Externo_Altica__c;
    global Boolean Bienvenida_No_contactado__c;
    global String Tipo_de_Financiamiento__c;
    global String Acreedor_prendario__c;
    global String Activo__c;
    global Boolean Aprobada__c;
    global String Aseguradora__c;
    global Double Asiento__c;
    global String Capacidad__c;
    global Decimal Cargo_administrativo_plazo1__c;
    global Decimal Cargo_administrativo_plazo2__c;
    global String Carroceria__c;
    global Double Cilindrada__c;
    global Double Cilindros__c;
    global String Color__c;
    global Double Score_KyC__c;
    global String ComentariosOrdenCompra__c;
    global Decimal Comision_TP__c;
    global Double Comision__c;
    global Double Compra_Venta_A_o__c;
    global Double Compra_Venta_Dia__c;
    global String Compra_Venta_Mes__c;
    /* Fecha de condicion de venta del contrato
    */
    global Date Compra_Venta__c;
    global String Condicion_Activo__c;
    global String Condicion_representante_legal__c;
    global String Condiciones_adicionales__c;
    /* Agregar al inicio CR y el número
    */
    global String Cuenta_cliente__c;
    global Decimal CuotaTotalPrimerTracto__c;
    global String CuotaTotalPrimerTracto_texto__c;
    global Decimal Cuota_24_meses_Numero__c;
    /* monto en letras
    */
    global String Cuota_24_meses_Texto__c;
    global Decimal Cuota_paybac__c;
    global String Direccion__c;
    global String Direccion_del_RL__c;
    global String Direccion_del_codeudor__c;
    global String Estado_civil__c;
    global String Estado_civil_codeudor__c;
    /* escribir en letras el monto de estimación
    */
    global String Estimacion_Letras__c;
    global Decimal Estimacion_numero__c;
    /* Fecha condicion de venta del contrato
    */
    global Date FechaCompra_Venta__c;
    global Double FechaFirmaDocumentoAno__c;
    global Double FechaFirmaDocumentoDia__c;
    global String FechaFirmaDocumentoMes__c;
    global Date FechaFirmaDocumento__c;
    global Double FechaOrdenCompraAno__c;
    global Double FechaOrdenCompraDia__c;
    global String FechaOrdenCompraMes__c;
    global Date FechaOrdenCompra__c;
    global Double FechaReciboConformeAno__c;
    global Double FechaReciboConformeDia__c;
    global String FechaReciboConformeMes__c;
    global Date FechaReciboConforme__c;
    global Double Fecha_Formalizacion_A_o__c;
    global String Fecha_Formalizacion_Mes__c;
    global Date Fecha_Formalizacion_Plazo__c;
    global Double Fecha_Formalizacion_dia__c;
    global Double Fecha_Ultimo_Pago_A_o__c;
    global String Fecha_Ultimo_Pago_Mes__c;
    global Double Fecha_Ultimo_Pago_dia__c;
    global String Fecha_de_pago__c;
    global Double Fecha_primer_fracci_n_ano__c;
    global Date Fecha_primer_fraccion_de_cuota__c;
    global Double Fecha_primer_fraccion_dia__c;
    global String Fecha_primer_fraccion_mes__c;
    global Date Fecha_primer_pago_cuota_completa__c;
    global Double Folio__c;
    /* mes vencido
    */
    global String Forma_de_pago__c;
    global Decimal GPS_TP__c;
    global Decimal GPS__c;
    global Decimal GPSmasComision__c;
    global String HoraFirmaDocumento__c;
    global Decimal IVA_2__c;
    global Decimal IVA__c;
    global Double Inicio_plazo_variable__c;
    global Double Interes_moratorio_mensual__c;
    global Double Intereses_moratorios__c;
    global String Lista_Proveedor__c;
    global String Marca_del_motor__c;
    /* Monto a financiar dependiendo de tipo de cargo
    */
    global Decimal MontoFinanciarFinal__c;
    global Decimal MontoFinanciarIndependiente__c;
    global String Monto_Cargo_Admin1__c;
    global String Monto_Cargo_Admin2__c;
    global Double Monto_Comision__c;
    /* monto en letras
    */
    global String Monto_a_Financiar_AlticaLetras__c;
    /* detalle en letras monto del seguro
    */
    global String Monto_del_seguro_letras__c;
    global Decimal Monto_del_seguro_numero__c;
    global Decimal Monto_del_seguro_segundo_tracto__c;
    global Decimal Monto_por_pagar_a_la_agencia__c;
    global Decimal Monto_promocion__c;
    global Decimal Monto_recompra__c;
    /* monto en letras
    */
    global String Monto_recompra_letras__c;
    global String Nacionalidad__c;
    global String Nombre_Representante_Legal__c;
    global String Nombre_Vendedor__c;
    global String Nombre_cliente_altica_t__c;
    global String Nombre_codeudor__c;
    global String Numero_Cedula_Representante_Legal__c;
    global String Numero_de_cedula_del_codeudor__c;
    global String Numero_de_cedula_persona_autorizada_reti__c;
    global String Numero_de_chasis__c;
    global String Numero_de_motor__c;
    /* escribir monto en letras
    */
    global String Opcion_de_Compra_Letras_c__c;
    global String Persona_autorizada_retirar_activo__c;
    global String Placa__c;
    global Double PlazoTasaFija__c;
    /* dato en letras
    */
    global String Prima_Altica_Letras__c;
    global String Profesion_Codeudor__c;
    global String Profesion__c;
    global String Razon_Social_de_la_empresa__c;
    global String SeguroDesempleo__c;
    global String SeguroProteccionCrediticia__c;
    global String Serie_Altica__c;
    global Double Spread__c;
    global String Tipo_Cargo__c;
    global Double Tomo__c;
    global String Traccion__c;
    global Decimal ValorFijo__c;
    global Decimal Valor_residual__c;
    /* digitar monto en letras
    */
    global String Valor_residual_letras__c;
    global String VendedorAgencia__c;
    global Decimal X1_5_dias_mora__c;
    global Decimal X30_dias_mora__c;
    global Decimal X31_dias_mora__c;
    global Decimal X60_dias_mora__c;
    global Decimal X6_30_dias_mora__c;
    global Decimal X90_dias_mora__c;
    global Decimal cargo_administrativo_fijo__c;
    global Decimal cargo_administrativo_segundo__c;
    global Double kilometraje_Circulacion__c;
    global Double kilometraje__c;
    global Decimal recibo_de_activo__c;
    global String Estructura_de_la_Propiedad__c;
    global String Origen_de_los_Recursos__c;
    /* Se indica del lago de datos el nivel de riesgo, 1, 2 o 3 según sea el caso.
    */
    global Double comportamiento__c;
    /* Se indica manualmente el nivel de riesgo, 1, 2 o 3 según sea el caso.
    */
    global Double estructuraPropiedad__c;
    /* Formulario conozca su cliente relacionado.
    */
    global formularioConozcaSuCliente__c formConozcaSuCliente__r;
    /* Formulario conozca su cliente relacionado.
    */
    global Id formConozcaSuCliente__c;
    /* Indica que ya se llenó el formulario conozca a su cliente.
    */
    global Boolean formularioConozcaSuCliente__c;
    /* Se indica manualmente el nivel de riesgo, 1, 2 o 3 según sea el caso.
    */
    global Double origenRecursos__c;
    global String tipoCliente__c;
    /* Se indica del lago de datos el nivel de riesgo, 1, 2 o 3 según sea el caso.
    */
    global Double tipoDeProducto__c;
    /* Se indica del lago de datos el nivel de riesgo, 1, 2 o 3 según sea el caso.
    */
    global Double tipoMontoFrecuenciaTransacciones__c;
    global String Tipo__c;
    /* Nivel de riesgo según riesgo actual del cliente.
    */
    global String nivelRiesgoActual__c;
    /* Color según nivel de riesgo.
    */
    global String colorRiesgo__c;
    /* Id de la cuenta relacionada.
    */
    global String idCuenta__c;
    global Double CIC_SUJEF__c;
    global Double Cantidad_OF__c;
    global Decimal Cuenta_monto_a_financiar__c;
    global Boolean CheckProcessbuider__c;
    global String Distribuidor__c;
    global Account DistribuidorLookup__r;
    global Id DistribuidorLookup__c;
    global Tipo_de_cambio__c TipoDeCambio__r;
    global Id TipoDeCambio__c;
    global Double RCI_beta__c;
    global String Oportunidad_Id_Num_rico__c;
    global Boolean VistoBuenoCoordinadorCreditoCobro__c;
    global Decimal Cuota_actual__c;
    global Decimal Saldo_actual__c;
    global Double TIR__c;
    global Double Tasa_interes_efectiva__c;
    global String Estado_operacion__c;
    global String Combustible__c;
    global String Numero_operacion_SIFO__c;
    global Gesti_n_ltica__c Gestion_Altica__r;
    global Id Gestion_Altica__c;
    global Double Ajuste_Score__c;
    global Double Score_Credid_Ajustado__c;
    global Boolean Creado_cotizador__c;
    global Double Age__c;
    global String Estado_lago_datos__c;
    global Double Valor_activo_promedio__c;
    global String Actualizacion__c;
    global Double Desviaci_n_valor_activo__c;
    global String DistribuidorFormula__c;
    global String Vendedor_cotizador__c;
    global List<Account> Cuentas__r;
    global List<ActionPlan> ActionPlans;
    global List<ActivityHistory> ActivityHistories;
    global List<AttachedContentDocument> AttachedContentDocuments;
    global List<AttachedContentNote> AttachedContentNotes;
    global List<Attachment> Attachments;
    global List<CollaborationGroupRecord> RecordAssociatedGroups;
    global List<CombinedAttachment> CombinedAttachments;
    global List<ContactRequest> ContactRequests;
    global List<ContentDocumentLink> ContentDocumentLinks;
    global List<Cotizacion__c> Cotizaciones__r;
    global List<Cuota__c> Cuotas__r;
    global List<DuplicateRecordItem> DuplicateRecordItems;
    global List<EmailMessage> Emails;
    global List<EngagementTopic> EngagementInitiatedTopic;
    global List<EntitySubscription> FeedSubscriptionsForEntity;
    global List<Event> Events;
    global List<EventRelation> EventRelations;
    global List<FlowOrchestrationWorkItem> FlowOrchestrationWorkItems;
    global List<Gesti_n_ltica__c> Gestiones_ltica__r;
    global List<NetworkActivityAudit> ParentEntities;
    global List<NetworkUserHistoryRecent> NetworkUserHistoryRecentToRecord;
    global List<Note> Notes;
    global List<NoteAndAttachment> NotesAndAttachments;
    global List<OpenActivity> OpenActivities;
    global List<Oportunidad_de_Financiamiento__Feed> Feeds;
    global List<Oportunidad_de_Financiamiento__History> Histories;
    global List<Opportunity> Oportunidades__r;
    global List<ProcessException> ProcessExceptions;
    global List<ProcessInstance> ProcessInstances;
    global List<ProcessInstanceHistory> ProcessSteps;
    global List<RecordAction> RecordActions;
    global List<RecordActionHistory> RecordActionHistories;
    global List<RecordAlert> RecordAlertParent;
    global List<RecordAlert> RecordAlertWhat;
    global List<SurveySubject> SurveySubjectEntities;
    global List<Task> Tasks;
    global List<TaskRelation> TaskRelations;
    global List<TopicAssignment> TopicAssignments;
    global List<UserDefinedLabelAssignment> UserDefinedLabelAssignments;
    global List<VideoCall> VideoRelatedRecords;
    global List<VoiceCall> RelatedRecords;
    global List<estudioArticulo15__c> estudioArticulo15__r;
    global List<AIInsightValue> SobjectLookupValue;
    global List<AIRecordInsight> Target;
    global List<AgentWork> WorkItem;
    global List<ContentDistribution> RelatedRecord;
    global List<ContentDocumentLinkChangeEvent> LinkedEntity;
    global List<ContentVersion> FirstPublishLocation;
    global List<EmailMessageChangeEvent> RelatedTo;
    global List<EngagementTopicChangeEvent> Topic;
    global List<EventChangeEvent> What;
    global List<EventRelationChangeEvent> Relation;
    global List<FeedComment> Parent;
    global List<FlowExecutionErrorEvent> ContextRecord;
    global List<FlowRecordRelation> RelatedRecord;
    global List<NetworkFeedResponseMetric> ParentRecord;
    global List<OutgoingEmail> RelatedTo;
    global List<PendingServiceRouting> WorkItem;
    global List<PendingServiceRoutingInteractionInfo> PrimaryRecord;
    global List<PendingServiceRoutingInteractionInfo> TargetObject;
    global List<ProcessExceptionEvent> AttachedTo;
    global List<TaskChangeEvent> What;
    global List<TaskRelationChangeEvent> Relation;
    global List<VideoCallChangeEvent> RelatedRecord;

    global Oportunidad_de_Financiamiento__c () 
    {
    }
}