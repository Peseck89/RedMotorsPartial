import { LightningElement, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation'

export default class CT_vistaKanbanCard extends NavigationMixin(LightningElement) {
    @api stage
    @api record
    @api strstatus 
    @api status

    isStatusPause = false;

    isStatusRunning = false;
    
    get isPauseStatus(){
        return this.record.stageName == 'En pausa';
    }

    get isRunningStatus(){
        return this.record.stageName == 'En curso';
    }

    connectedCallback() {
        console.log('paso por aqui card');
    }

    get isSameStage(){
        return true; // this.stage === this.strstatus;
    }

    get percentage(){
        return `width:${this.record.percentageWorkCompleted}px;`;
    }

    navigateToRecord(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: event.target.dataset.object,
                actionName: 'view',
            },
        });
    }


    handleDragStart(event){
        event.dataTransfer.setData("workstepid", this.record.id);
    }

    get color(){
        let color = '';        
        if(this.record.stageName == 'Nueva' && (this.record.mechanicName == null || this.record.mechanicName == '')){  
            // this.nuevaSinMecanico = true;                                      
            color = '#ffffff';
        }else if(this.record.stageName == 'Nueva' && (this.record.mechanicName != null && this.record.mechanicName != '')){
            // this.nuevaConMecanico = true;
            color = '#eafbfe';
            // rowList[i].style.color = '#4892b8';
        }else if(this.record.stageName == 'En curso' && this.record.totalMinutesWorked > this.record.scheduledMinutes){
            // this.enCursoDestiempo = true;
            color = '#fb617b';
            // rowList[i].style.color = '#fff6f7';
        }else if(this.record.stageName == 'En curso' && this.record.totalMinutesWorked < this.record.scheduledMinutes){
            // this.enCursoEnTiempo = true;
            color = '#f2f8e7';
            // rowList[i].style.color = '#5daa40';
        }else if(this.record.stageName == 'En pausa'){
            // this.enPausa = true;            
            color = '#f8efe1';
            // rowList[i].style.color = '#f09f3f';
        }else if(this.record.stageName == 'Completada'){
            // this.completada = true;
            color = '#23282c';
            // rowList[i].style.color = '#c3c9ce';                            
        }else{
            // this.blanco = true;
            color = '#f6f6f6';
        }
        return 'height: 25px;width: 25px;background-color: '+color+';border-radius: 50%;display: inline-block;';
    }
}