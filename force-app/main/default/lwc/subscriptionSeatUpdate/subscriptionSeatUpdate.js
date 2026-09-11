import { LightningElement,track,wire,api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import ITEMS_JSON_FIELD from '@salesforce/schema/Stripe_Subscription__c.Stripe_Subscription_Item__c';

const COLUMNS = [
    { label: 'Product', fieldName: 'productLabel', type: 'text' },
    { label: 'Price ID', fieldName: 'priceId', type: 'text' },
    {
        label: 'Amount', fieldName: 'amount', type: 'currency',
        typeAttributes: { currencyCode: { fieldName: 'currency' } }
    },
    { label: 'Interval', fieldName: 'intervalLabel', type: 'text' },
    { label: 'Quantity', fieldName: 'quantity', type: 'number', editable: true },
    { label: 'Current Period End', fieldName: 'currentPeriodEnd', type: 'date' }
];
const FIELDS=[ITEMS_JSON_FIELD];
export default class SubscriptionSeatUpdate extends LightningElement {

    @api recordId;
    @track isShowModal = false;

    columns = COLUMNS;
    draftValues = [];
    productNameMap = {};
    @track itemRows = [];


    showModalBox() {
        console.log('showModalBox call');
        this.isShowModal = true;
    }

    handleCancel() {
        console.log('handleCancel call');
        this.isShowModal = false;
    }
     @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredSubscription({ data, error }) {
        if (data) {
            console.log('data-->' + JSON.stringify(data));
            this.itemsJson = getFieldValue(data, ITEMS_JSON_FIELD);
           
        
            this.mapItemRows();  // load the product name
        } else if (error) {
            console.error('Error fetching subscription', error);
        }
    }

     mapItemRows() {
        if (!this.itemsJson) return [];
        const items = JSON.parse(this.itemsJson);
        console.log('item--' + items);

        this.itemRows = items.map((item) => {
            const stripeProductId = item.price?.product;
            console.log('stripeProductId-->' + stripeProductId);
            return {
                id: item.id,                          // si_xxx -> subscription item id
                productLabel: this.id || item.price?.product || item.price?.id, // fallback if no product name
                priceId: item.price?.id,
                amount: (item.price?.unit_amount || 0) / 100,
                currency: (item.price?.currency || 'usd').toUpperCase(),
                intervalLabel: `${item.price?.recurring?.interval_count} ${item.price?.recurring?.interval}`,
                quantity: item.quantity,
                currentPeriodEnd: new Date(item.current_period_end * 1000).toISOString()
            }
        });
    }
}