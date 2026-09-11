/* myDatatable.js */
import { LightningElement, wire, track } from "lwc";
import getAccountList from "@salesforce/apex/AddProductController.getAccountList";

// const COLS = [
//   {
//     label: "Account Name",
//     type: "customName",
//     typeAttributes: {
//       accountName: { fieldName: "Name" },
//     },
//   },
//   {
//     label: "Industry",
//     fieldName: "Industry",
//     cellAttributes: {
//       class: { fieldName: "industryColor" },
//     },
//   },
//   {
//     label: "Employees",
//     type: "customNumber",
//     fieldName: "NumberOfEmployees",
//     typeAttributes: {
//       status: { fieldName: "status" },
//     },
//     cellAttributes: {
//       class: "slds-theme_alert-texture",
//     },
//   },
// ];

const COLS = [
  {
    label: "Account Name",
    type: "customName",
    typeAttributes: {
      accountName: { fieldName: "Name" },
    },
  },
  {
    label: "Industry",
    fieldName: "Industry",
  },

  // ✅ Discount Type Picklist
  {
    label: "Discount Type",
    fieldName: "DiscountType",
    type: "picklistColumn",
    editable: true,
    typeAttributes: {
      placeholder: "Select",
      options: { fieldName: "discountTypeOptions" },
      value: { fieldName: "DiscountType" },
      context: { fieldName: "Id" }
    }
  },

  // ✅ Discount Number
  {
    label: "Discount",
    fieldName: "Discount",
    type: "number",
    editable: true,
    typeAttributes: {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    },
    cellAttributes: { alignment: "left" }
  }
];
export default class MyDatatable extends LightningElement {
  columns = COLS;
  @track accounts = [];

  @wire(getAccountList)
  wiredAccounts({ error, data }) {
    if (error) {
      // Handle error
    } else if (data) {
      // Process record data
      this.accounts = data.map((record) => {
        return {
          ...record,
          discountTypeOptions: [
            { label: "Percentage", value: "Percentage" },
            { label: "Amount", value: "Amount" }
          ],
          DiscountType: record.DiscountType || "",
          Discount: record.Discount || 0
        };
      });
    }
  }
}