import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NavigateToRecord extends NavigationMixin(LightningElement) {
    @api recordId;
    @api object;
    @api toastMessage;
    connectedCallback() {
        if(this.recordId && this.object){
            console.log(this.recordId + ' - ' + this.object);
            const finishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(finishEvent);
            window.location.href = `/lightning/r/${this.object}/${this.recordId}/view`;
            this.showToast('Success', this.toastMessage, 'Success');
        }
        else if (this.object) {
            // Redirect to All List View if recordId is null
            const finishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(finishEvent);
            window.location.href = `/lightning/o/${this.object}/list?filterName=Recent`; // or use filterName=All if available
            this.showToast('Info', this.toastMessage, 'info');
        }
    }

    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}