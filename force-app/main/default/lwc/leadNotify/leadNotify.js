import { LightningElement, track } from 'lwc';

import { subscribe, onError } from 'lightning/empApi';

export default class LeadNotify extends LightningElement {

    channelName = '/event/LeadNotification__e';
    @track message = 'Waiting for lead events...';
    isSubscribeDisabled=false;
    subscription={};

    connectedCallback() {
        console.log('connectedCallback call for LeadNotify');
        this.subscribeToEvent();
        this.handleError();
        console.log('this.message1' + this.message);
    }

    subscribeToEvent() {

        const messageCallback = (response) => {

            console.log('New Event Received', response);

            const payload = response.data.payload;

            this.message =
                'New Lead Created: ' +
                payload.Lead_name__c +
                ' Email: ' +
                payload.Email__c;
            console.log('this.message inside messageCallback' + this.message);
            console.log('messageCallback end');
        };

        // subscribe(this.channelName, -1, messageCallback)
        //     .then(response => {
        //         console.log('rsponse', response);
        //         console.log('Subscribed to channel ', response.channel);
        //         console.log('this.message2' + this.message);
        //     });

    }

    handleError() {
        onError(error => {
            console.error('EMP API error: ', JSON.stringify(error));
        });
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = function (response) {
            console.log("New message received: ", JSON.stringify(response));
            // Response contains the payload of the new message received
        };
    
    // Invoke subscribe method of empApi. Pass reference to messageCallback
    subscribe(this.channelName, -1, messageCallback)
    .then((response) => {
      // Response contains the subscription information on subscribe call
      console.log("Subscription request sent to: ", JSON.stringify(response.channel));
      this.subscription = response;
      this.isSubscribeDisabled=true;
      
    });
  }
}