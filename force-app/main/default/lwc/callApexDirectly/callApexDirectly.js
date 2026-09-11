import { LightningElement, api } from 'lwc';
import runApex from '@salesforce/apex/QuickActionController.runApex';

export default class CallApexDirectly extends LightningElement {

    @api recordId;

    handleClick() {
        runApex({ recordId: this.recordId })
        .then(result => {
            console.log('result',result)
            alert(result);
        })
        .catch(error => {
            console.error(error);
        });
    }
}