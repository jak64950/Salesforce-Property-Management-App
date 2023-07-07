import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getProperties from '@salesforce/apex/RentalAgreementController.getProperties';
import saveRentalAgreement from '@salesforce/apex/RentalAgreementController.saveRentalAgreement';
import createRentalAgreement from '@salesforce/apex/RentalAgreementController.createRentalAgreement';
import rentTerms from '@salesforce/resourceUrl/Sample_Rental_Terms';
import getContactId from '@salesforce/apex/RentalAgreementController.getContactId';



export default class RentalApplication extends NavigationMixin(LightningElement) {
    @track searchResults = [];
    @track selectedProperty = null;
    @track propertyStreet = '';
    @track propertyCity = '';
    @track propertyState = '';
    @track propertyZip = '';
    @track bedrooms;
    @track bathrooms;
    @track squareFootage;
    @track rent;
    @track tenantId;
    @track isMapsLoaded = false;
    @track mapMarkers = [];
    @track recordId;
    @track deposit = 0;
    @track search = false;
    @track application = false;
    @track terms = rentTerms;
    @track acceptTerms = true;
    @track tenantDetails = false;

    connectedCallback() {
        this.loadTenantId();
    }

    loadTenantId() {
        getContactId()
            .then((result) => {
                if (result) {
                    this.tenantId = result;
                }
            })
            .catch((error) => {                
                console.log(error);
            });
    }

    handleSearch() {
        getProperties({
            street: this.propertyStreet,
            city: this.propertyCity,
            state: this.propertyState,
            zip: this.propertyZip,
            bedrooms: this.bedrooms,
            bathrooms: this.bathrooms,
            squareFootage: this.squareFootage,
            rent: this.rent
        })
        .then(result => {
            if (result) {
                this.search = true;
                this.searchResults = result;
                this.isMapsLoaded = true;
                // Create map markers using property data
                this.mapMarkers = result.map(unit => {
            return {
                location: {
                    City: unit.Property__r.Property_City__c,
                    Country: unit.Property__r.Property_Country__c,
                    PostalCode: unit.Property__r.Property_Zip__c,
                    State: unit.Property__r.Property_State__c,
                    Street: unit.Property__r.Property_Street__c
                },
                value: unit.Property__c,
                icon: 'standard:account',
                title: unit.Property__r.Name
            };
                });
            } else if (error) {
                this.isMapsLoaded = false;
                this.searchResults = [];
            }
        })
    }

    handlePropertySelection(event) {
        const recordId = event.currentTarget.getAttribute('data-record-id');
        if (recordId) {
            // Navigate to the record detail page using NavigationMixin
            this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Rental_Unit__c',
                actionName: 'view'
            }
            });
        }
    }

    handleTenantInputChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;

        this[fieldName] = fieldValue;
    }

    handlePropertyInputChange(event) {
        this.search = false;
        this.application = false;
        this.isMapsLoaded = false;
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        if (fieldValue === '') {
            if (fieldName === 'bedrooms' || fieldName === 'bathrooms' || fieldName === 'squareFootage') {
                this[fieldName] = 0;
            } else if (fieldName === 'rent') {
                this[fieldName] = 999999;
            } else {
                this[fieldName] = fieldValue;
            }
        } else {
            this[fieldName] = fieldValue;
        }
    }

    applyRentalAgreement(event) {
        const recordId = event.currentTarget.getAttribute('data-record-id');
        this.recordId = recordId;
        if (recordId) {
            saveRentalAgreement({ recordId: recordId })
                .then(result => {
                    this.isMapsLoaded = false;
                    this.application = true;
                    this.selectedProperty = result;
                    this.rent = this.selectedProperty.Rent__c;
                    this.deposit = this.selectedProperty.Rent__c * 2;
                });
        }
    }

    updateContact() {
        this.tenantDetails = true;
    }

    handleAcceptTerms() {
        this.acceptTerms = false;
    }

    createRentalAgreement() {    
        createRentalAgreement({ recordId: this.recordId })
            .then(result => {                
                if (result) {
                    // Navigate to the record detail page using NavigationMixin
                    this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Rental_Agreement__c',
                        actionName: 'view'
                    }
                    });
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
}