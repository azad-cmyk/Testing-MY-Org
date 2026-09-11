import { api, LightningElement } from 'lwc';


import getAccounts from '@salesforce/apex/DemoClass.getAccounts';
import getFields from '@salesforce/apex/DemoClass.getFields';


const columns = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'Name', fieldName: 'Name' },
    { label: 'Rating', fieldName: 'Rating' },
    { label: 'Industry', fieldName: 'Industry' }
];

export default class LazyLoadingSingle extends LightningElement {

    isModalOpen = false;

    accounts = [];
    columns = columns;

    rowLimit = 20;
    rowOffset = 0;
    isLoading = false;
    hasMoreData = true;

    // ===
    @api recordId;
    isFieldModalOpen = false;
    fields = [];
    fieldOffset = 0;
    fieldLimit = 20;
    isFieldLoading = false;
    hasMoreFields = true;

    // OPEN MODAL
    openModal() {
        this.isModalOpen = true;

        // reset data every time modal opens
        this.accounts = [];
        this.rowOffset = 0;
        this.hasMoreData = true;

        this.loadData();
    }

    // CLOSE MODAL
    closeModal() {
        this.isModalOpen = false;
    }

    // LOAD DATA
    loadData() {
        if (!this.hasMoreData) return;

        this.isLoading = true;

        return getAccounts({
            limitSize: this.rowLimit,
            offset: this.rowOffset
        })
            .then(result => {
                console.log('result', result);
                if (result.length < this.rowLimit) {
                    this.hasMoreData = false; // no more records
                    console.log('No more records to load' + this.hasMoreData);
                }

                this.accounts = [...this.accounts, ...result];
                this.isLoading = false;
            })
            .catch(error => {
                console.error(error);
                this.isLoading = false;
            });
    }

    // INFINITE SCROLL
    loadMoreData(event) {
        if (!this.hasMoreData) return;
        const target = event.target;
        console.log('loadMoreData')
        target.isLoading = true;

        this.rowOffset += this.rowLimit;

        this.loadData().then(() => {
            target.isLoading = false;
        });
    }
    // // FIELD MODAL LOGIC
    openModalDynamic() {
        this.isFieldModalOpen = true;

        this.fields = [];
        this.fieldOffset = 0;
        this.hasMoreFields = true;

        this.loadFields();
    }

    closeFieldModal() {
        this.isFieldModalOpen = false;
    }

    loadFields() {

        if (!this.hasMoreFields) return;

        this.isFieldLoading = true;

        return getFields({
            recordId: this.recordId,
            limitSize: this.fieldLimit,
            offset: this.fieldOffset
        })
            .then(result => {

                this.fields = [...this.fields, ...result.fields];
                this.hasMoreFields = result.hasMore;

                this.isFieldLoading = false;
            })
            .catch(error => {
                console.error(error);
                this.isFieldLoading = false;
            });
    }

    handleScroll(event) {

        const el = event.target;

        if (el.scrollTop + el.clientHeight >= el.scrollHeight - 5) {

            if (this.isFieldLoading || !this.hasMoreFields) {
                return;
            }

            this.fieldOffset += this.fieldLimit;

            this.loadFields();
        }
    }
}