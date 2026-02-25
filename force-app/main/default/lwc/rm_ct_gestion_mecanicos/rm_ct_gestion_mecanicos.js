import { LightningElement,wire,track } from 'lwc';
import COLUMNS from './columns';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getData from '@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.getData';
import rm_ct_registrar_actividad_mecanico from 'c/rm_ct_registrar_actividad_mecanico';
import getTerritoriesByUserId from '@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.getTerritoriesByUserId';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';
import { subscribe } from 'lightning/empApi';

export default class Rm_ct_gestion_mecanicos extends LightningElement {
    columns = COLUMNS; 
    
    userId = USER_ID;

    selectedIds = [];

    data;
    error;
    isLoading;

    salesforceURL;
    connectedCallback() {
        this.salesforceURL = window.location.origin;
        this.handleSubscribe();
    }

    territoryId = '';
    pageSize = 100;
    pageNumber = 1;
    contacts = [];

    isLoading = false;

    wiredTerritoriesResult;
    territoryOptions = [];

    channelName = '/event/RM_WorkStep__e';
    subscription = {};

    @track wiredDataResult;
    @wire(getData, { territoryId: '$territoryId', pageSize: '$pageSize', pageNumber: '$pageNumber'})
    wiredData(result) {
        this.isLoading = true;
        this.wiredDataResult = result;
        this.contacts = [];
        if (result.data) {
            for (let contact of result.data.contacts) {
                let newRow = {};
                newRow.id = contact.Id;
                newRow.mechanicName = contact.Name;
                newRow.mechanicURL = `${this.salesforceURL}/${contact.Id}`;
                let tallerId = contact.Actividades_Mecanicos__r && contact.Actividades_Mecanicos__r.length > 0 && contact.Actividades_Mecanicos__r[0].RM_Taller__c ? contact.Actividades_Mecanicos__r[0].RM_Taller__c : '';
                newRow.tallerURL = `${this.salesforceURL}/${tallerId}`;
                newRow.tallerName = contact.Actividades_Mecanicos__r && contact.Actividades_Mecanicos__r.length > 0 && contact.Actividades_Mecanicos__r[0].RM_Taller__r  ? contact.Actividades_Mecanicos__r[0].RM_Taller__r.Name : '';
                newRow.fechaHoraInicio = contact.Actividades_Mecanicos__r && contact.Actividades_Mecanicos__r.length > 0 ? contact.Actividades_Mecanicos__r[0].RM_FechaHoraInicio__c : '';
                newRow.tipo = contact.Actividades_Mecanicos__r && contact.Actividades_Mecanicos__r.length > 0 ? contact.Actividades_Mecanicos__r[0].RM_Tipo__c : 'Sin Actividad';
                newRow.acId = contact.Actividades_Mecanicos__r && contact.Actividades_Mecanicos__r.length > 0 ? contact.Actividades_Mecanicos__r[0].Id : '';
                newRow.name = newRow.tipo;
                newRow.nameURL = `${this.salesforceURL}/${newRow.acId}`;
                if(contact.Actividades_Mecanicos__r && contact.Actividades_Mecanicos__r.length > 0 && contact.Actividades_Mecanicos__r[0].RM_Paso__r){
                    newRow.name = contact.Actividades_Mecanicos__r[0].RM_Caso__r ? contact.Actividades_Mecanicos__r[0].RM_Caso__r.CaseNumber : newRow.name;
                }

                if(contact.Actividades_Mecanicos__r && contact.Actividades_Mecanicos__r.length > 0 && contact.Actividades_Mecanicos__r[0].RM_Paso__r){
                    let paso = contact.Actividades_Mecanicos__r[0].RM_Paso__r;
                    let caso = contact.Actividades_Mecanicos__r[0].RM_Caso__r;
                    newRow.nameURL = caso && caso.Id ? `${this.salesforceURL}/${caso.Id}` : '';

                    let totalHorasFX = paso.RM_TotalHorasFX__c ? paso.RM_TotalHorasFX__c : 0;
                    let totalTiempoTrabajado = paso.Total_de_tiempo_trabajado_en_minutos__c ? paso.Total_de_tiempo_trabajado_en_minutos__c : 0;
                    newRow.avance = totalTiempoTrabajado > 0 ? (totalTiempoTrabajado * 100) / totalHorasFX : 0;
                    newRow.avance = newRow.avance.toFixed(2);

                    // si el % de avance es el 90% ponerlo en orange, se se paso de tiempo ponerlo en rojo, si no ponerlo en verde
                    newRow.status = paso.Status;
                    newRow.statusColor = newRow.avance >= 90 ? 'background-color: orange;color:white;' : newRow.avance > 100 ? 'background-color: red;color:white;' : 'background-color: green;color:white;';
                }
                
                this.contacts.push(newRow);
            }
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
        
        if (result.data || result.error) {
            this.isLoading = false;
        }
    }

    handleExportSelect(event){
        const selectedItemValue = event.detail.value;
        if(selectedItemValue === 'entrada'){
            this.handleEntrada();
        }else if(selectedItemValue === 'salida'){
            this.handleSalida();
        }else if(selectedItemValue === 'crearTiempoImproductivo'){
            this.handleCrearHoraTiempoImproductivo();
        }
    }

    handleCrearHoraTiempoImproductivo(){
        rm_ct_registrar_actividad_mecanico.open({
            size: 'small',
            title: 'Registrar Actividad'
        })
        .then(result => {
            console.log('result despues cerrar');
            return refreshApex(this.wiredDataResult);
        });
    }

    getHora(time){
        //if time is empty return empty string
        if (!time) {
            return '';
        }

        let seconds = time;

        let hours = Math.floor(seconds / 3600);
        let minutes = Math.floor((seconds % 3600) / 60);
        let remainingSeconds = seconds % 60;

        let timeString = `${hours}:${minutes}:${remainingSeconds}`;

        return timeString;
    }

    @wire(getTerritoriesByUserId,{userId: '$userId'})
    wiredTerritories(result){
        this.wiredTerritoriesResult = result;
        if(result.data){
            this.territoryOptions = [{ label: 'Todos', value: 'all' }].concat(result.data.territories.map(territory => {
                return {
                    label: territory.Name,
                    value: territory.Id
                };
            }));

        }else if(result.error){
        }
    }

    handleTerritoryChange(event){
        this.territoryId = event.target.value;
        this.contacts = [];
    }

    handleSubscribe() {
        const messageCallback = (response) => {
            this.refreshComponent();
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscribed to channel gestion mecanicos');
            this.subscription = response;
        });
    }

    refreshComponent() {
        return refreshApex(this.wiredDataResult);   
    }
}