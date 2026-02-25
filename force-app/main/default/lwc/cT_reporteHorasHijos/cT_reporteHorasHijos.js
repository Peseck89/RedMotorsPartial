import { LightningElement, api, track } from 'lwc';

export default class CT_reporteHorasHijos extends LightningElement {

    @api
    config;
    @track territoryId

    @api
    _workSteps = [];

    @api
    caseId = null;

    @api
    mechanicId = null;

    @api
    territoryId;

    @api
    fieldName = null;

    @api
    showResume;

    @track territory = null;
    @track caseNumber = null;
    @track hoursAssigned = 0.0;
    @track hoursWorked = 0.0;
    @track hoursBilled = 0.0;

    totalHoursAssigned = 0.0;
    totalHoursWorked = 0.0;
    totalHoursBilled = 0.0;
    totalHorasImproductivas = 0.0;

    @track productividad = 0;
    @track eficiencia = 0;

    horas_x_dia = 0;
    dias_x_mes = 0;

    @api cases;

    connectedCallback() {
        this.config = this.config.data ? JSON.parse(JSON.stringify(this.config.data)) : [];
        this.validarDisponibilidad();
        this.caseNumber = null;

        this.hoursAssigned = 0;
        this.hoursWorked = 0.0;
        this.hoursBilled = 0;

        this.totalHoursAssigned = 0;
        this.totalHoursWorked = 0;
        this.totalHoursBilled = 0;
        this.totalHorasImproductivas = 0;
        
        this.workSteps.forEach((workStep, key) => {

            //sumar a nive de mecanico, territorio y caso
            if (workStep.Mec_nico_asignado__c == this.mechanicId && workStep.Caso__r.Service_Territory1__c == this.territoryId && (!this.showResume || (this.showResume && workStep.Caso__c == this.caseId))) {

                if ((workStep.Flag_Is_Task_FX__c === false && workStep.Tipo_de_trabajo_del_caso__c && workStep.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c === 'Tarea padre') ||
                (workStep.Flag_Is_Task_FX__c === true && workStep.Tipo_de_trabajo_del_caso__c && workStep.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c !== 'Tarea padre')) 
                {

                    let _hoursAssigned = workStep.RM_TotalHorasFX__c ? parseFloat(workStep.RM_TotalHorasFX__c) : 0;
                    let _hoursWorked = workStep.Total_de_tiempo_trabajado_en_minutos__c && parseFloat(workStep.Total_de_tiempo_trabajado_en_minutos__c) > 0 ? parseFloat(workStep.Total_de_tiempo_trabajado_en_minutos__c) : 0;

                    _hoursWorked = _hoursWorked > 0 ? (_hoursWorked / 60) : 0;

                    _hoursWorked = _hoursWorked.toFixed(2);

                    this.territory = workStep.WorkOrder && workStep.WorkOrder.ServiceTerritory && workStep.WorkOrder.ServiceTerritory.Name ? workStep.WorkOrder.ServiceTerritory.Name : '';
                    this.caseNumber = workStep.Caso__r.CaseNumber;
                    this.hoursAssigned += parseFloat(_hoursAssigned);
                    this.hoursWorked += parseFloat(_hoursWorked);
                    this.hoursBilled += parseFloat(_hoursAssigned);
                }
            }

            // sumar a nivel de mecanico y territorio
            if (workStep.Mec_nico_asignado__c == this.mechanicId && workStep.Caso__r.Service_Territory1__c == this.territoryId) {
                let _hoursAssigned =  0;
                let _hoursWorked =  0;
                if (workStep.Flag_Is_Task_FX__c === false && workStep.Tipo_de_trabajo_del_caso__c && workStep.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c === 'Tarea padre') {
                    _hoursAssigned = workStep.RM_TotalHorasFX__c ? parseFloat(workStep.RM_TotalHorasFX__c) : 0;
                    _hoursWorked = workStep.Total_de_tiempo_trabajado_en_minutos__c && parseFloat(workStep.Total_de_tiempo_trabajado_en_minutos__c) > 0 ? parseFloat(workStep.Total_de_tiempo_trabajado_en_minutos__c) : 0;
                    _hoursWorked = _hoursWorked > 0 ? (_hoursWorked / 60) : 0;   
                }else if (workStep.Flag_Is_Task_FX__c && workStep.Tipo_de_trabajo_del_caso__c && workStep.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c !== 'Tarea padre') {
                    _hoursAssigned = workStep.RM_TotalHorasFX__c ? parseFloat(workStep.RM_TotalHorasFX__c) : 0;
                    _hoursWorked = workStep.Total_de_tiempo_trabajado_en_minutos__c && parseFloat(workStep.Total_de_tiempo_trabajado_en_minutos__c) > 0 ? parseFloat(workStep.Total_de_tiempo_trabajado_en_minutos__c) : 0;
                    _hoursWorked = _hoursWorked > 0 ? (_hoursWorked / 60) : 0;
                }

                this.totalHoursAssigned = parseFloat(this.totalHoursAssigned) + parseFloat(_hoursAssigned);
                this.totalHoursWorked = parseFloat(this.totalHoursWorked) + parseFloat(_hoursWorked);
                this.totalHoursBilled = parseFloat(this.totalHoursBilled) + parseFloat(_hoursAssigned);

                this.territory = workStep.WorkOrder && workStep.WorkOrder.ServiceTerritory && workStep.WorkOrder.ServiceTerritory.Name ? workStep.WorkOrder.ServiceTerritory.Name : '';
            }

        });

        this.productividad = this.totalHoursAssigned ? (this.totalHoursAssigned / this.horas_x_dia) * this.dias_x_mes : 0;
        this.eficiencia = this.totalHoursWorked > 0 ? (this.totalHoursWorked / this.totalHoursBilled) : 0;

        if (this.cases && this.cases.length > 0) {
            for (let i = 0; i < this.cases.length; i++) {
                this.totalHorasImproductivas += parseFloat(this.cases[i].minutosPausa);
            }
        }
    }

    get isTerritory() {
        return this.fieldName == 'territory';
    }

    get isCaseNumber() {
        return this.fieldName == 'caseNumber';
    }

    get isHoursAssigned() {
        return this.fieldName == 'hoursAssigned';
    }

    get isHoursWorked() {
        return this.fieldName == 'hoursWorked';
    }

    get isHoursBilled() {
        return this.fieldName == 'hoursBilled';
    }

    get isTotalHoursAssigned() {
        return this.fieldName == 'totalHoursAssigned';
    }

    get isTotalHoursWorked() {
        return this.fieldName == 'totalHoursWorked';
    }

    get isTotalHoursBilled() {
        return this.fieldName == 'totalHoursBilled';
    }

    get isProductividad() {
        return this.fieldName == 'productividad';
    }

    get isEficiencia() {
        return this.fieldName == 'eficiencia';
    }

    get isTotalHI() {
        return this.fieldName == 'totalHorasImproductivas';
    }

    @api set workSteps(value) {
        this._workSteps = value;
    }

    get workSteps() {
        return this._workSteps;
    }

    @track existeConfig = false;

    validarDisponibilidad() {
        this.config.forEach((config, index) => {
            if (config.Mecanico__c == this.mechanicId && config.Taller__c == this.territoryId && config.Horas_x_dia__c && parseFloat(config.Horas_x_dia__c) > 0 && config.Dias_x_mes__c && parseFloat(config.Dias_x_mes__c) > 0) {
                this.horas_x_dia = parseFloat(config.Horas_x_dia__c).toFixed(2);
                this.dias_x_mes = parseFloat(config.Dias_x_mes__c).toFixed(2);
                this.existeConfig = true;
            }
        });
    }
}