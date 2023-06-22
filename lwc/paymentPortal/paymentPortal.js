import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPaymentRecordTypes from '@salesforce/apex/PaymentsController.getPaymentRecordTypes';
import savePayment from '@salesforce/apex/PaymentsController.savePayment';
import getContactFields from '@salesforce/apex/PaymentsController.getContactFields';
import getStatementFields from '@salesforce/apex/PaymentsController.getStatementFields';

export default class PaymentsComponent extends LightningElement {
    @track paymentRecordTypes = [];
    @track expirationYears = [];
    @track expirationMonths = [];
    @track isSubmitting = false;
    @track payment = {
        Payment_Amount__c: 0
    };
    @track contact = {};
    
    // Get Payment Record Types for Payment Method Options
    @wire(getPaymentRecordTypes)
    wiredPaymentRecordTypes({ error, data }) {
        if (data) {
            this.paymentRecordTypes = data.map(item => ({ value: item.value, label: item.label }));
        } else if (error) {
            this.showToast('Error', 'Error retrieving payment record types.', 'error');
        }
    }

    // Populate Expiration Months and Years
    connectedCallback() {
        this.getExpirationYears();
        this.getExpirationMonths();
    }

    // Generate Credit Card Expiration Years
    getExpirationYears() {
        const currentYear = new Date().getFullYear();
        // Next 5 years
        for (let i = 0; i < 5; i++) {
            this.expirationYears.push({ label: String(currentYear + i), value: String(currentYear + i) });
        }
    }

    // Generate Credit Card Expiration Months
    getExpirationMonths() {
        const allMonths = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];
        for (let i = 0; i < allMonths.length; i++) {
            this.expirationMonths.push({ label: allMonths[i], value: allMonths[i] });
        }
    }

    // Determine if credit card record type selected
    get isCreditCardSelected() {
        const selectedRecordType = this.paymentRecordTypes.find(
            item => item.value === this.payment.RecordTypeId
        );
        return selectedRecordType && selectedRecordType.label === 'Credit Card';
    }

    // Determine if check record type selected
    get isCheckSelected() {
        const selectedRecordType = this.paymentRecordTypes.find(
            item => item.value === this.payment.RecordTypeId
        );
        return selectedRecordType && selectedRecordType.label === 'Check';
    }  
    
    // Update payment object as input fields change
    handleInputChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        this.payment[fieldName] = fieldValue;
        // Allow submission due to changing fields
        this.isSubmitting = false;

        if (fieldName === 'Statement__c' && fieldValue) {
            // Clear fields if Statement changed
            this.clearPaymentFields();
            this.payment.Statement__c = fieldValue;
            // Pre-populate fields based on Contact on Statement
            getContactFields({ statementId: fieldValue })
                .then(result => {
                    if (result) {
                        this.contact = result;
                        this.payment.Billing_Name__c = this.contact.FirstName + ' ' + this.contact.LastName;
                        this.payment.Billing_Street__c = this.contact.MailingStreet;
                        this.payment.Billing_City__c = this.contact.MailingCity;
                        this.payment.Billing_State__c = this.contact.MailingState;
                        this.payment.Billing_Zip__c = this.contact.MailingPostalCode;
                        this.payment.Billing_Country__c = this.contact.MailingCountry;
                    }
                });
                // Populate Payment amount to Statement Amount
                getStatementFields({ statementId: fieldValue })
                    .then(result => {
                        if (result) {
                            this.payment.Payment_Amount__c = result;
                        }
                    });
        }
    }

    handleSavePayment(event) {
        // Override lighting-record-edit-form standard function
        event.preventDefault();        
        
        // Ensure all fields populated before submission
        if (!this.isFormComplete()) {
            this.showToast('Error', 'Please fill out all fields.', 'error');
            return;
        }

        // Show message after running save payment apex method whether successful or not
        savePayment({ payment: this.payment })
            .then(result => {
                if (result) {
                    this.showToast('Success', 'Payment successful.', 'success');
                    // Prevent accidental multiple submissions
                    this.isSubmitting = true;
                } else {
                    this.showToast('Error', 'Payment failed.', 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred while processing the payment.', 'error');
            });    
        }

    // Fields needed to be completed
    isFormComplete() {
        const requiredFields = [
            'Billing_Name__c',
            'Billing_Street__c',
            'Billing_City__c',
            'Billing_State__c',
            'Billing_Zip__c',
            'Billing_Country__c',
            'RecordTypeId'
        ];

        if (this.isCreditCardSelected) {
            requiredFields.push(
                'Credit_Card_Number__c',
                'Credit_Card_Expiration_Month__c',
                'Credit_Card_Expiration_Year__c',
                'Credit_Card_Security_Code__c'
            );
        } else if (this.isCheckSelected) {
            requiredFields.push(
                'Check_Account_Number__c',
                'Check_Routing_Number__c'
            );
        }
        
        // Return false if all fields not completed
        for (const field of requiredFields) {
            if (!this.payment[field]) {
                return false;
            }
        }
        
        // else return true
        return true;
    }

    // Reset Form
    clearPaymentFields() {
        this.payment = {
            Payment_Amount__c: 0,
            Billing_Name__c: '',
            Billing_Street__c: '',
            Billing_City__c: '',
            Billing_State__c: '',
            Billing_Zip__c: '',
            Billing_Country__c: ''
        };
    }

    // Show messages for events
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}

