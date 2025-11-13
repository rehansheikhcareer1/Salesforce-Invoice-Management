import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getClientInvoices from '@salesforce/apex/InvoiceController.getClientInvoices';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Invoice Number', fieldName: 'Name', type: 'text' },
    { label: 'Invoice Date', fieldName: 'Invoice_Date__c', type: 'date' },
    { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    { label: 'Total Amount', fieldName: 'Total_Amount__c', type: 'currency' },
    { label: 'Amount Paid', fieldName: 'Amount_Paid__c', type: 'currency' },
    { label: 'Balance Due', fieldName: 'Balance_Due__c', type: 'currency' }
];

export default class InvoiceList extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    invoices;
    error;
    wiredInvoicesResult;

    @wire(getClientInvoices, { clientId: '$recordId' })
    wiredInvoices(result) {
        this.wiredInvoicesResult = result;
        if (result.data) {
            this.invoices = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.invoices = undefined;
            this.showToast('Error', 'Error loading invoices', 'error');
        }
    }

    handleRefresh() {
        return refreshApex(this.wiredInvoicesResult);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get hasInvoices() {
        return this.invoices && this.invoices.length > 0;
    }
}
