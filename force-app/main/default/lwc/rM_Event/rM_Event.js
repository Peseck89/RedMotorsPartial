import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RM_Event extends LightningElement {
    @track status;
    
    @track message;

    @api recordId;

    @api action = 'alert';
 
    subscription = {};
    @api channelName = '/event/RM_Event__e';

    connectedCallback() {
        this.handleSubscribe();
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {
            var obj = JSON.parse(JSON.stringify(response));
            
            let objData = obj.data.payload;

            self.message = objData.Message__c;

            if(self.recordId == objData.Record_Id__c){
                if(objData.Type__c == 'alert'){
                    self.ShowToast(objData.Title__c,objData.Message__c,objData.Alert_Type__c,'dismissable');
                }else if(objData.Alert_Type__c == 'refresh'){
                    self.dispatchEvent(new CustomEvent('refreshworksteps', {}));
                }
            }
        };
 
        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }
    
    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }    
}