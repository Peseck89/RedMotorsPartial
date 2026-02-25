import LightningModal from 'lightning/modal';
import { wire, api } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchMechanics from '@salesforce/apex/SampleLookupController.searchMechanics';
import getTerritoriesByContactId from '@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.getTerritoriesByContactId';
import crearActividad from '@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.crearActividad';
import getTipoValues from '@salesforce/apex/RM_CT_GestionMecanicos_Ctrl.getTipoValues';

export default class Rm_ct_registrar_actividad_mecanico extends LightningModal {
    mechanicInitialSelection = [];
    mechanicId = undefined;

    isLoading = false;

    territoryOptions = [];
    territoryId;

    tipoSeleccionado;
    tipoOptions = [];
    errorTipo;
    @wire(getTipoValues)
    tipoValues({ error, data }) {
        if (data) {
            this.tipoOptions = data
            .map(type => {
                return {
                    label: type.label,
                    value: type.label
                };
            }
            );

            this.tipoOptions = this.tipoOptions.filter(type => (!type.value.toLowerCase().includes('tarea') ));
            this.errorTipo = undefined;
        } else if (error) {
            this.errorTipo = error;
            this.tipoOptions = [];
        }
    }

    handleTipoChange(event) {
        this.tipoSeleccionado = event.detail.value;
    }

    handleMechanicLookUpSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
        params["firedElement"] = 'Mecánico';
        params["icon"] = 'standard:user';

        searchMechanics(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Consultar información de mecánico',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });
    }
    
    handleMechanicLookupChange(event){
        this.mechanicId = undefined;
        this.mechanicInitialSelection = [];

        if (event.detail.length > 0) {
            const selectedContact = event.target.getSelection();
            this.mechanicId = selectedContact[0].id;
            this.mechanicInitialSelection = selectedContact;
        }

    }

    handleTerritoryChange(event){
        this.territoryId = event.target.value;
    }

    //retrieve territories calling getTerritoriesByContactId using wired function
    wiredTerritoriesResult;
    @wire(getTerritoriesByContactId,{contactId: '$mechanicId'})
    wiredTerritories(result){
        this.wiredTerritoriesResult = result;
        if(result.data){
            //this is the query SELECT Id,Name FROM ServiceTerritory
            //adjust the structure data for a lightning-combobox
            this.territoryOptions = result.data.territories.map(territory => {
                return {
                    label: territory.Name,
                    value: territory.Id
                };
            });

        }else if(result.error){
            console.log('error');
            console.log(result.error);
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Consultar territorios',
            //         message: reduceErrors(result.error).join(', '),
            //         variant: 'error'
            //     })
            // );
        }
    }

    get isSaveDisabled(){
        return !this.mechanicId || !this.territoryId;
    }

    handleSave(){
        this.isLoading = true;
        crearActividad({mechanicId: this.mechanicId, tallerId: this.territoryId, tipo: this.tipoSeleccionado})
            .then(() => {

            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Consultar territorios',
                        message: reduceErrors(result.error).join(', '),
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
                this.close();
            });
      
    }
}