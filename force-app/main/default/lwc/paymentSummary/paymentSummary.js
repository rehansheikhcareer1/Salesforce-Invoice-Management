import { LightningElement, api, wire } from 'lwc';
import getPaymentSummary from '@salesforce/apex/PaymentController.getPaymentSummary';

export default class PaymentSummary extends LightningElement {
    @api recordId;
    summary;
    error;

    @wire(getPaymentSummary, { clientId: '$recordId' })
    wiredSummary({ error, data }) {
        if (data) {
            this.summary = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.summary = undefined;
        }
    }

    get formattedTotalBilled() {
        return this.formatCurrency(this.summary?.totalBilled);
    }

    get formattedTotalPaid() {
        return this.formatCurrency(this.summary?.totalPaid);
    }

    get formattedTotalOutstanding() {
        return this.formatCurrency(this.summary?.totalOutstanding);
    }

    formatCurrency(value) {
        if (value === null || value === undefined) {
            return '$0.00';
        }
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(value);
    }
}
