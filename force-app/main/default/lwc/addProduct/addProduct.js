import { LightningElement } from 'lwc';


import {api, track, wire } from 'lwc';
import QUOTE_OBJECT from '@salesforce/schema/Quote';
import { updateRecord } from 'lightning/uiRecordApi';
//import INVOICE_OBJECT from '@salesforce/schema/Invoice__c';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import QUOTE_PRICE_BOOK_FIELD from '@salesforce/schema/Quote.Pricebook2Id';
//import getPricebook from '@salesforce/apex/AddLineItemController.getPricebook';
//import INVOICE_PRICE_BOOK_FIELD from '@salesforce/schema/Invoice__c.Price_Book__c';
//import createLineItems from '@salesforce/apex/AddLineItemController.createLineItems';
//import getAllPriceBook from '@salesforce/apex/AddLineItemController.getAllPriceBook';
import OPPORTUNITY_PRICE_BOOK_FIELD from '@salesforce/schema/Opportunity.Pricebook2Id';
//import showProductDetails from '@salesforce/apex/AddLineItemController.showProductDetails';
//import QLI_DISCOUNT_TYPE from '@salesforce/schema/QuoteLineItem.Discount_Type__c';
//import OLI_DISCOUNT_TYPE from '@salesforce/schema/OpportunityLineItem.Discount_Type__c';
//import ILI_DISCOUNT_TYPE from '@salesforce/schema/QuoteLineItem.Discount_Type__c';
import OPPORTUNITY_LINE_ITEM_OBJECT  from '@salesforce/schema/OpportunityLineItem';
import QUOTE_LINE_ITEM_OBJECT from '@salesforce/schema/QuoteLineItem';
//import INVOICE_LINE_ITEM_OBJECT from '@salesforce/schema/Invoice_Line_Item__c';
import { NavigationMixin } from 'lightning/navigation';
//import hasLineItems from '@salesforce/apex/AddLineItemController.hasLineItems';
//import getDiscountTypePicklistValues from '@salesforce/apex/AddLineItemController.getDiscountTypePicklistValues';

// export default class AddProduct extends LightningElement {

export default class AddProduct extends NavigationMixin(LightningElement) {
    // --------- Public Property ----------
    @api recordId;
    @api objectApiName;

    // --------- Component State ----------
    pricebookId;
    objectSchema;
    lineItemObjectSchema;
    pricebookField;
    searchValue = '';
    pricebookName = '';
    discountTypeField = '';
    discountTypeOptions = [];
 
    // --------- Data ----------
    allProducts = []; 
    draftValues = [];
    filteredProducts = []; 
    pricebookListOptions = []; 
    selectedProductsOnAddProductModel = []; 
    selectedProductsOnEditProductModel = [];
    selectedProductIdsOfAddProductModel = []; 
   
    // --------- UI Flags ----------
    isLoading = false;
    isPricebookModelOpen = false;
    isAddProductModalOpen = false;
    isEditProductsModalOpen = false;

    // --------- Columns Definition ----------
    productColumns = [
        {
            label: "Product Name",
            fieldName: 'ProductLink',
            type: 'url',
            typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
        },
        { 
            label: 'Product SKU/Code', 
            fieldName: 'ProductCode', 
            type: 'text' 
        },
        {
            label: 'List Price',
            fieldName: 'UnitPrice',
            type: 'currency',
            typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: 'code' },
            cellAttributes: { alignment: 'left' }
        },
        { 
            label: 'Product Description', 
            fieldName: 'ProductDescription', 
            type: 'text' 
        },
        { 
            label: 'Product Family', 
            fieldName: 'ProductFamily', 
            type: 'text' 
        }
    ];

    editableProductColumns = [
        {
            label: "Product",
            fieldName: 'ProductLink',
            type: 'url',
            typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' },
            wrapText: true,
            hideDefaultActions: true,
            displayReadOnlyIcon: true,
            editable: false,
            initialWidth: 200,
            
        },
        {
            label: 'Product SKU/Code',
            fieldName: 'ProductCode',
            type: 'text',
            wrapText: true,
            hideDefaultActions: true,
            displayReadOnlyIcon: true,
            editable: false,
            initialWidth: 200,
        },
        { 
            label: 'Quantity', 
            fieldName: 'Quantity', 
            type: 'number', 
            typeAttributes: { maximumFractionDigits: 2, minimumFractionDigits: 2 },
            cellAttributes: { alignment: 'left' },
            editable: true, 
            wrapText: true, 
            hideDefaultActions: true,
        },
        {
            label: 'List Price',
            fieldName: 'ListPrice',
            type: 'currency',
            typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: 'code' },
            cellAttributes: { alignment: 'left' },
            wrapText: true,
            hideDefaultActions: true,
            displayReadOnlyIcon: true,
        },
        {
            label: 'Unit Price',
            fieldName: 'UnitPrice',
            type: 'currency',
            typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: 'code' },
            editable: true,
            cellAttributes: { alignment: 'left' },
            wrapText: true,
            hideDefaultActions: true,
        },
        {
            label: 'Discount Type',
            fieldName: 'DiscountType',
            type: 'picklistColumn',
            editable: true,
            typeAttributes: {
                placeholder: 'Select',
                options: this.discountTypeOptions,
                value: { fieldName: 'DiscountType' },
                context: { fieldName: 'Id' }
            },
            wrapText: true, 
            hideDefaultActions: true,
        },
        { 
            label: 'Discount', 
            fieldName: 'Discount', 
            type: 'number', 
            typeAttributes: { maximumFractionDigits: 2, minimumFractionDigits: 2 },
            wrapText: true, 
            hideDefaultActions: true, 
            editable: true ,
            cellAttributes: { alignment: 'left' },
        },
        {
            type: 'button-icon',
            typeAttributes: { iconName: 'utility:delete', name: 'delete', size: 'small'},
            cellAttributes: { alignment: 'center' },
            initialWidth: 70,
        }
    ];

    // --------- Lifecycle Hook ----------
    connectedCallback() {
        this.mapObjectToField();
        //this.fetchPricebook();
        console.log('connected CallBack');
    }

    // Map object to its Price Book field and object schema
    mapObjectToField() {
        switch (this.objectApiName) {
            case OPPORTUNITY_OBJECT.objectApiName:
                this.objectSchema = OPPORTUNITY_OBJECT.objectApiName;
               // this.discountTypeField = OLI_DISCOUNT_TYPE.fieldApiName;
                this.pricebookField = OPPORTUNITY_PRICE_BOOK_FIELD.fieldApiName;
                this.lineItemObjectSchema = OPPORTUNITY_LINE_ITEM_OBJECT.objectApiName;
                break;
            case QUOTE_OBJECT.objectApiName:
                this.objectSchema = QUOTE_OBJECT.objectApiName;
               // this.discountTypeField = QLI_DISCOUNT_TYPE.fieldApiName;
                this.pricebookField = QUOTE_PRICE_BOOK_FIELD.fieldApiName;
                this.lineItemObjectSchema = QUOTE_LINE_ITEM_OBJECT.objectApiName;
                break;
            // case INVOICE_OBJECT.objectApiName:
            //     this.objectSchema = INVOICE_OBJECT.objectApiName;
            //     //this.discountTypeField = ILI_DISCOUNT_TYPE.fieldApiName;
            //     this.pricebookField = INVOICE_PRICE_BOOK_FIELD.fieldApiName;
            //     //this.lineItemObjectSchema = INVOICE_LINE_ITEM_OBJECT.objectApiName;
            //     break;
        }
    }

    // Fetch Price Book associated with the record
    // async fetchPricebook() {
    //     try {
    //         const pricebook = await getPricebook({ 
    //             recordId: this.recordId, 
    //             objectSchema: this.objectSchema, 
    //             pricebookField: this.pricebookField
    //         });
    //         this.pricebookId = pricebook.Id;
    //         this.pricebookName = pricebook.Name;
    //     } catch (error) {
    //         console.error('Error fetching Pricebook:', error?.body?.message || error);
    //     }

    // }

    // Open Add Product Modal
    async handleAddProduct() {
        console.log("add product call");
        // if (!this.pricebookId) {
        //     await this.getPricebooks();
        //     return;
        // }
        this.isLoading = true;
        try {
            // const products = await showProductDetails({ pricebookId: this.pricebookId });
            // this.allProducts = this.mapProductDetails(products);
            // this.filteredProducts = this.allProducts;
            this.isAddProductModalOpen = true;
            // this.discountTypeOptions = await getDiscountTypePicklistValues({
            //     objectApiName: this.lineItemObjectSchema,
            //     fieldApiName: this.discountTypeField
            // });
            this.updateDiscountTypeColumn();
        } catch (error) {
            console.error('Error fetching product details:', error?.body?.message || error);
        } finally {
            this.isLoading = false;
        }
    }

    // Helper to update the column options
    updateDiscountTypeColumn() {
        this.editableProductColumns = this.editableProductColumns.map(col => {
            if (col.fieldName === 'DiscountType') {
                return {
                    ...col,
                    typeAttributes: {
                        ...col.typeAttributes,
                        options: this.discountTypeOptions
                    }
                };
            }
            return col;
        });
    }

    // Get all Price Books
    // async getPricebooks() {
    //     this.isLoading = true;
    //     try {
    //         const pricebookResult = await getAllPriceBook();
    //         this.pricebookListOptions = [];
    //         if (pricebookResult && pricebookResult.length > 0) {
    //             pricebookResult.forEach(element => {
    //                 this.pricebookListOptions.push({
    //                     label: element.Name,
    //                     value: element.Id
    //                 });
    //             });
    //             this.isPricebookModelOpen = true;
    //         }
    //     } catch (error) {
    //         console.error('Error fetching price book details:',error?.body?.message || error );
    //     } finally {
    //         this.isLoading = false;
    //     }
    // }

    // Update Price Book Name & Id
    handleChangePricebook( event ) {
        this.pricebookId = event.target.value;
        const selectedPricebook = this.pricebookListOptions.find(
            pb => pb.value === this.pricebookId
        );
        this.pricebookName = selectedPricebook?.label || '';
    }
    
    // Close Price Book Modal
    async handleSavePricebook() {
        this.isLoading = true;
        this.isPricebookModelOpen = false;
        this.selectedProductsOnAddProductModel = [];
        this.selectedProductsOnEditProductModel = [];
        this.selectedProductIdsOfAddProductModel = [];
        const fields = {};
        fields.Id = this.recordId;
        fields[this.pricebookField] = this.pricebookId;

        try {
            await updateRecord({ fields });
            this.showToast('Success', 'Price Book updated successfully!', 'success');
        } catch (error) {
            console.error('Error Price Book not updated:', error?.body?.message || error);
        } finally {
            this.isLoading = false;
            this.handleAddProduct();
        }
    }

    // Close Add Product Modal
    async handlePricebookChange() {
        const hasItems = await hasLineItems({ 
            recordId: this.recordId, 
            objectApiName: this.objectSchema, 
        });
        if (hasItems) {
            this.showToast('Info', 'This record already has line items. The price book cannot be changed.', 'info');
            return; 
        }
        this.isAddProductModalOpen = false;
       // this.getPricebooks();
    }

    // Map Apex Product2 data to datatable fields
    mapProductDetails( records ) {
        records.forEach(res => {
            res.Quantity = 1;
            res.ListPrice = res.UnitPrice;;
            res.ProductLink = '/' + res.Product2Id;
            res.ProductName = res.Product2Id ? res.Product2.Name : '';
            res.ProductFamily = res.Product2Id ? res.Product2.Family : '';
            res.ProductCode = res.Product2Id ? res.Product2.ProductCode : '';
            res.ProductDescription = res.Product2Id ? res.Product2.Description : '';
        });
        return records;
    }

    // Search products by Product Name, Product Code and Product Family
    searchKeyword( event ) {
        this.searchValue = event.target.value.trim(); 
        if (!this.searchValue) {
            this.filteredProducts = this.allProducts;
        } else {
            const searchLower = this.searchValue.toLowerCase();
            this.filteredProducts = this.allProducts.filter(prod =>
                (prod.ProductName && prod.ProductName.toLowerCase().includes(searchLower)) ||
                (prod.ProductCode && prod.ProductCode.toLowerCase().includes(searchLower)) ||
                (prod.ProductFamily && prod.ProductFamily.toLowerCase().includes(searchLower))
            );
        }
    }

    // Add product from add product modal
    handleSelectAction(event) {
        const rows = event.detail.selectedRows || [];
        const seen = new Set();
        const uniqueRows = [];

        for (const item of rows) {
            const key = `${item.ProductCode}__${item.UnitPrice}`;

            if (seen.has(key)) {
                this.showToast(
                    'Error',
                    'Duplicate line selected with same Product Code and Unit Price',
                    'error'
                );
                continue; 
            }

            seen.add(key);
            uniqueRows.push(item);
        }
        this.selectedProductsOnAddProductModel = uniqueRows;
        this.selectedProductIdsOfAddProductModel = uniqueRows.map(row => row.Id);
    }


    // Remove selected product
    handleRowAction( event ) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if ( actionName === 'delete' ) {
            this.selectedProductsOnEditProductModel = this.selectedProductsOnEditProductModel.filter(r => r.Id !== row.Id);
            this.selectedProductsOnAddProductModel =  this.selectedProductsOnAddProductModel.filter(r => r.Id !== row.Id);
            this.selectedProductIdsOfAddProductModel =  this.selectedProductsOnAddProductModel.map(row => row.Id);
            this.showToast('Deleted', `Product "${row.ProductName}" removed.`, 'success');
        }
    }

    // Add selected products to edit products modal
    handleNext() {
        const editMap = new Map(
            this.selectedProductsOnEditProductModel.map(p => [p.Id, p])
        );
        this.selectedProductsOnEditProductModel =
            this.selectedProductsOnAddProductModel.map(
                p => editMap.get(p.Id) || p
            );
        this.isAddProductModalOpen = false;
        this.isEditProductsModalOpen = true;
    }


    // Open add product modal
    handleAddLineItem() {
        this.isEditProductsModalOpen = false;  
        this.isAddProductModalOpen = true;
    }
    
    // Handle cell changes in edit products modal
    handleCellChange( event ) {
        const changedDraftValues = event.detail.draftValues;
        const updatedProduct = this.selectedProductsOnEditProductModel.map(row => {
            const draft = changedDraftValues.find(d => d.Id === row.Id);
            return draft ? { ...row, ...draft } : row;
        });
        this.selectedProductsOnEditProductModel = updatedProduct;
    }

    // Save products to line items
    async saveProduct() {
        if (!this.selectedProductsOnEditProductModel.length) {
            this.showToast('Error', 'No products selected to save!', 'error');
            return;
        } 
        this.isLoading = true;
        try {
            const payload = this.selectedProductsOnEditProductModel.map(sp => ({
                pricebookEntryId: sp.Id,
                productId: sp.Product2Id,
                quantity: sp.Quantity,
                unitPrice: sp.UnitPrice,
                listPrice: sp.ListPrice,
                discount: sp.Discount || 0,
                discountType: sp.DiscountType || ''
            }));

            // await createLineItems({
            //     parentId: this.recordId,
            //     parentObject: this.objectApiName,
            //     items: payload
            // });

            const productCount = this.selectedProductsOnEditProductModel.length;
            this.showToast(
                'Success',
                `${productCount} product${productCount > 1 ? 's' : ''} added successfully!`,
                'success'
            );
            this.closeModal();
            this.isLoading = false;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: this.objectApiName,
                    actionName: 'view'
                }
            });
        } catch ( error ) {
            console.error('Error occurred while saving products:', error?.body?.message || error);
            this.isLoading = false;
        }
    }

    // Disable save button if no products are selected
    get disableSaveButton() {
        return !this.selectedProductsOnEditProductModel.length;
    }

    // Disable next button if no products are selected
    get disableNextButton() {
        return !this.selectedProductsOnAddProductModel.length;
    }    

    get selectedRowCount() {
        return this.selectedProductsOnAddProductModel.length;
    }

    // Show toast message
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode: 'dismissable' }));
    }

    // Reset modal states and selections
    closeModal() { 
        this.isLoading = false;
        this.isPricebookModelOpen = false;
        this.isAddProductModalOpen = false;
        this.isEditProductsModalOpen = false;
        this.selectedProductsOnAddProductModel = [];
        this.selectedProductsOnEditProductModel = [];
        this.selectedProductIdsOfAddProductModel = [];
    }

}