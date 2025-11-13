import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import recordPayment from '@salesforce/apex/PaymentController.recordPayment';

const FIELDS = ['Invoice__c.Balance_Due__c', 'Invoice__c.Name'];

export default class PaymentRecorder extends LightningElement {
    @api recordId;
    amount;
    paymentDate = new Date().toISOString().split('T')[0];
    paymentMethod = 'Bank Transfer';
    notes = '';
    balanceDue;
    invoiceName;
    isProcessing = false;

    paymentMethodOptions = [
        { label: 'Cash', value: 'Cash' },
        { label: 'Check', value: 'Check' },
        { label: 'Credit Card', value: 'Credit Card' },
        { label: 'Bank Transfer', value: 'Bank Transfer' },
        { label: 'Online Payment', value: 'Online Payment' }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredInvoice({ error, data }) {
        if (data) {
            this.balanceDue = data.fields.Balance_Due__c.value;
            this.invoiceName = data.fields.Name.value;
        } else if (error) {
            this.showToast('Error', 'Error loading invoice details', 'error');
        }
    }

    handleAmountChange(event) {
        this.amount = event.target.value;
    }

    handleDateChange(event) {
        this.paymentDate = event.target.value;
    }

    handleMethodChange(event) {
        this.paymentMethod = event.detail.value;
    }

    handleNotesChange(event) {
        this.notes = event.target.value;
    }

    handleSave() {
        if (!this.validateInputs()) {
            return;
        }

        this.isProcessing = true;

        recordPayment({
            invoiceId: this.recordId,
            amount: parseFloat(this.amount),
            paymentDate: this.paymentDate,
            paymentMethod: this.paymentMethod,
            notes: this.notes
        })
        .then(() => {
            this.showToast('Success', 'Payment recorded successfully', 'success');
            this.dispatchEvent(new CloseActionScreenEvent());
            eval("$A.get('e.force:refreshView').fire();");
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        })
        .finally(() => {
            this.isProcessing = false;
        });
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    validateInputs() {
        if (!this.amount || this.amount <= 0) {
            this.showToast('Error', 'Please enter a valid amount', 'error');
            return false;
        }

        if (this.amount > this.balanceDue) {
            this.showToast('Error', 'Payment amount cannot exceed balance due', 'error');
            return false;
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

    get formattedBalance() {
        return this.balanceDue ? `$${this.balanceDue.toFixed(2)}` : '$0.00';
    }
}
