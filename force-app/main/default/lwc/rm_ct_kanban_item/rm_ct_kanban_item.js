import { LightningElement, wire, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecords from '@salesforce/apex/CT_VistaKanban_Ctrl.getRecords';

export default class Rm_ct_kanban_item extends LightningElement {

    @api tallerId = null;
    @api workServiceType = null;
    @api stageName = null;
    @api workOrderNumber = null;
    @api caseNumber = null;    
    @api vin = null;    
    @api startCreationDate = null;    
    @api endCreationDate = null;
    @api nested = false;

    startTime = null;    
    endTime = null;  
    @track workSteps = [];    
    wiredStepWorksResult;

    @wire(getRecords,{ tallerId: "$tallerId", serviceTypeId: "$workServiceType", status: "$stageName", caseNumber: "$caseNumber", workOrderNumber: "$workOrderNumber",vin: "$vin", startDate: "$startCreationDate", endDate: "$endCreationDate", nested:"$nested" })
    wiredStepWorks(result) {
        this.wiredStepWorksResult = result;        
        if (result.data && result.data.workStepWrapperList) {         
            this.workSteps = JSON.parse(JSON.stringify(result.data.workStepWrapperList));
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.workSteps = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atención!',
                    message: result.error.body.message,
                    variant: 'error'
                })
            );
        }
        this._isLoading = false;
    }

    connectedCallback() {
        this.timer = setInterval(() => {         
            this.calcularTiempos();
        }, 1000);
    }    
    
    calcularTiempos(){
        let currentTime = new Date();
        if(this.workSteps)
        Object.values(this.workSteps).forEach((item, index) => {
            let hoursWorked = 0;
            let minutesWorked = 0;
            let secondsWorked = 0;

            let hoursPaused = 0;
            let minutesPaused = 0;
            let secondsPaused = 0;

            let totalMinutesWorked = 0
            let totalMinutesPaused = 0

            if(item.startTime){             
                let startTime = new Date(item.startTime);
                let milliseconds = Math.floor(currentTime - startTime);

                hoursWorked = Math.floor(milliseconds  / 3600000); // hours      
                minutesWorked = Math.floor(((milliseconds % 86400000) % 3600000) / 60000);///minutes la diferencia es en minutos del 0 - 59
                secondsWorked = Math.floor((((milliseconds % 86400000)% 3600000) % 60000) /1000);//La diferencia en segundos es del 0 al 60
                                
                totalMinutesWorked += (hoursWorked * 60) + minutesWorked;
                totalMinutesWorked -= item.minutesPausedAcum ? item.minutesPausedAcum : 0;
            }

            if(item.startDateTimePause){
                let startPauseTime = new Date(item.startDateTimePause);
                let milliseconds = Math.floor(currentTime - startPauseTime);

                hoursPaused = Math.floor(milliseconds  / 3600000); // hours      
                minutesPaused = Math.floor(((milliseconds % 86400000) % 3600000) / 60000);//minutes la diferencia es en minutos del 0 - 59
                secondsPaused = Math.floor((((milliseconds % 86400000)% 3600000) % 60000) /1000);//La diferencia en segundos es del 0 al 60              
                
                totalMinutesPaused += (hoursPaused * 60) + minutesPaused;
            }

            this.workSteps[index].hoursWorked = hoursWorked.toFixed(0);
            this.workSteps[index].minutesWorked = minutesWorked.toFixed(0);
            this.workSteps[index].secondsWorked = secondsWorked.toFixed(0);
            this.workSteps[index].totalMinutesWorked = totalMinutesWorked.toFixed(0);
            
            this.workSteps[index].hoursPaused = hoursPaused;
            this.workSteps[index].minutesPaused = minutesPaused.toFixed(0);
            this.workSteps[index].secondsPaused = secondsPaused.toFixed(0);
            this.workSteps[index].totalMinutesPaused = totalMinutesPaused.toFixed(0);  
        });
    }

    get workStepsUpdated(){      
        return this.workSteps;
    }

    get isLoading(){
        return !this.wiredStepWorksResult.data && !this.wiredStepWorksResult.error;
    }

    get recordsFound(){
        return this.workSteps.height > 0;
    }
}