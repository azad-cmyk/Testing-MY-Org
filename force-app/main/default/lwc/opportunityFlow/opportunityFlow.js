// import { LightningElement,api } from 'lwc';

// // export default class OpportunityFlow extends LightningElement {}

// export default class OpportunityFlow extends LightningElement {
//     @api recordId; // Account Id from quick action

//     get inputVariables() {
//         return [
//             {
//                 name: 'accountId',
//                 type: 'String',
//                 value: this.recordId
//             }
//         ];
//     }
//     connectedCallback(){
//         console.log('recordId'+this.recordId);
//     }
// }



import { LightningElement, track, api} from 'lwc';

export default class OpportunityFlow extends LightningElement {

    actionName;
    recordId;
    @track flowInputVariables = [];

    connectedCallback() {
        console.log('actionName  ',this.actionName);
        const url = window.location.href;

        /* 1️⃣ Extract Quick Action Name */
        const actionMatch = url.match(/quick\/([^?]+)/);
        if (actionMatch && actionMatch[1]) {
            this.actionName = actionMatch[1];
            console.log('Quick Action Name:', this.actionName);
        }

        /* 2️⃣ Extract recordId from query params */
        const urlParams = new URLSearchParams(window.location.search);
        this.recordId = urlParams.get('recordId');

        console.log('Record Id:', this.recordId);

        /* 3️⃣ Pass values to Screen Flow */
        this.flowInputVariables = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

}