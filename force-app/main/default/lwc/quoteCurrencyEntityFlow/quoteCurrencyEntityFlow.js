import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import QUOTE_OBJECT from '@salesforce/schema/Quote';
import CURRENCY_FIELD from '@salesforce/schema/Quote.Customer_Chosen_Currency__c';
import ENTITY_FIELD from '@salesforce/schema/Quote.Entity__c';

export default class QuoteCurrencyEntityFlow extends LightningElement {

    // OUTPUT to Flow
    @api currency;
    @api entity;

    currencyOptions = [];
    entityOptions = [];
    isEntityDisabled = true;

    recordTypeId;

    // 1️⃣ Get Quote object info
    @wire(getObjectInfo, { objectApiName: QUOTE_OBJECT })
    objectInfo({ data }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
            console.log('QuoteCurrencyEntityFlow this.recordTypeId-- '+this.recordTypeId);
        }
    }

    // 2️⃣ Get picklist values with dependency metadata
    @wire(getPicklistValuesByRecordType, {
        objectApiName: QUOTE_OBJECT,
        recordTypeId: '$recordTypeId'
    })
    picklistHandler({ data }) {
        if (data) {
             console.log('QuoteCurrencyEntityFlow this.recordTypeId-- getPicklistValuesByRecordType'+JSON.stringify(data));
            this.currencyOptions =
                data.picklistFieldValues[CURRENCY_FIELD.fieldApiName].values;
            this.entityFieldData =
                data.picklistFieldValues[ENTITY_FIELD.fieldApiName];
        }
    }

    handleCurrencyChange(event) {
        this.currency = event.detail.value;
        this.entity = null;
        this.isEntityDisabled = false;

        const controllerIndex =
            this.entityFieldData.controllerValues[this.currency];

        this.entityOptions =
            this.entityFieldData.values.filter(
                option => option.validFor.includes(controllerIndex)
            );
    }

    handleEntityChange(event) {
        this.entity = event.detail.value;
    }
}