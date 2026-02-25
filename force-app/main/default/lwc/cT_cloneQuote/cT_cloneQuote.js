import { api, LightningElement, track,wire } from 'lwc';
import duplicarQuoteExacta from '@salesforce/apex/cT_duplicarQuote.duplicarQuoteExacta'; 
import { NavigationMixin } from "lightning/navigation";

  export default class cT_cloneQuote extends NavigationMixin (LightningElement) {
    // you can also do wire or recordId here as standard LWC
    @api recordId;
    isCloned = '';
    disabled = false;
    handleClone(){    
      this.disabled = true;
      duplicarQuoteExacta ( { PresupuestoId: this.recordId })
      .then((result) => {
        console.log('lista ' + result);
        console.log(result);
        this.isCloned = result;
      })
      .catch((error) => {
          this.isCloned = error.body.message;
          console.log('lista ' + error);
          console.log(error);
      });
    }

    viewRecord(event) {
      // Navigate to Account record page
      console.log('event.target.value',event.target.value);
      console.log('event.target',event.target);
      this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              "recordId": event.target.value,
              "objectApiName": "Quote",
              "actionName": "view"
          },
      });
    }
  }