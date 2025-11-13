import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createInvoiceWithLineItems from '@salesforce/apex/InvoiceController.createInvoiceWithLineItems';

export default class InvoiceCreator extends NavigationMixin(LightningElement) {
    @api recordId;
    lineItems = [this.createEmptyLineItem()];
    dueDate;
    taxRate = 10;

    createEmptyLineItem() {
        return {
            id: Date.now() + Math.random(),
            productName: '',
            description: '',
            quantity: 1,
            unitPrice: 0
        };
    }

    handleAddItem() {
        this.lineItems = [...this.lineItems, this.createEmptyLineItem()];
    }

    handleRemoveItem(event) {
        const index = parseInt(event.target.dataset.index, 10);
        if (this.lineItems.length > 1) {
            this.lineItems = this.lineItems.filter((item, i) => i !== index);
        } else {
            this.showToast('Warning', 'At least one line item is required', 'warning');
        }
    }

    handleLineItemChange(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.lineItems = this.lineItems.map((item, i) => {
            if (i === index) {
                return { ...item, [field]: value };
            }
            return item;
        });
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        
        this.dueDate = fields.Due_Date__c;
        this.taxRate = fields.Tax_Rate__c || 10;

        if (!this.validateLineItems()) {
            return;
        }

        createInvoiceWithLineItems({
            clientId: this.recordId,
            dueDate: this.dueDate,
            taxRate: this.taxRate,
            lineItems: this.lineItems
        })
        .then(invoiceId => {
            this.showToast('Success', 'Invoice created successfully', 'success');
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: invoiceId,
                    objectApiName: 'Invoice__c',
                    actionName: 'view'
                }
            });
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        });
    }

    handleSuccess() {
        // Handled in handleSubmit
    }

    validateLineItems() {
        for (let item of this.lineItems) {
            if (!item.productName || item.quantity <= 0 || item.unitPrice <= 0) {
                this.showToast('Error', 'Please fill all line item fields correctly', 'error');
                return false;
            }
        }
        return true;
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
