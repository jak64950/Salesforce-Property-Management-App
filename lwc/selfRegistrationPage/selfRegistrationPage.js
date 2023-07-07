import { LightningElement, track } from 'lwc';
import registerUser from '@salesforce/apex/RegistrationController.registerUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SelfRegistrationPage extends LightningElement {
  @track firstName;
  @track lastName;
  @track email;
  @track birthdate;
  @track ssn;
  @track dln;
  @track employment;
  @track income;
  @track phone;
  @track street;
  @track city;
  @track state;
  @track zip;
  @track country;
  @track password;  
  
  employmentOptions = [
    { label: 'Full Time', value: 'Full-Time' },
    { label: 'Part Time', value: 'Part-Time' },
    { label: 'Self Employed', value: 'Self-Employed' },
    { label: 'Disability', value: 'Disability' },
    { label: 'Unemployed', value: 'Unemployed' },
    { label: 'Other', value: 'Other' }
  ];

  handleFieldChange(event) {
    const fieldName = event.target.name;
    this[fieldName] = event.target.value;
  }

  async handleRegister() {
    if (!this.validateFields()) {
      console.log('Please fill out all required fields');
      this.showToast('Error', 'Please fill in all fields', 'error');
      return;
    }

    const registrationData = {
        FirstName: this.firstName,
        LastName: this.lastName,
        Email: this.email,
        Birthdate: this.birthdate,
        Social_Security_Number__c: this.ssn,
        Driver_License_Number__c: this.dln,
        Employment_Status__c: this.employment,
        Income__c: this.income,
        Phone: this.phone,
        MailingStreet: this.street,
        MailingCity: this.city,
        MailingState: this.state,
        MailingPostalCode: this.zip,
        MailingCountry: this.country,
        Password: this.password
    };

    try {
      Object.entries(registrationData).forEach(([key, value]) => {
        console.log(`${key}:`, value);
      });
      await registerUser({ registrationData });
      console.log('Registration successful');
      this.showToast('Success', 'Registration successful. Please login.', 'success');
    } catch (error) {
      console.error('Registration error:', error);
      if (error.body && Array.isArray(error.body)) {
        error.body.forEach(err => {
          console.error('Error message:', err.message);
        });
      } else if (error.body && typeof error.body === 'string') {
        console.error('Error message:', error.body);
      } else {
        console.error('Unknown error occurred during registration');
      }
      this.showToast('Error', 'An error occurred during registration', 'error');
    }
  }

//    try {
//      console.log('Data: ' + registrationData);
//      await registerUser({ registrationData });
//      console.log('Registration Successful');
//      this.showToast('Success', 'Registration successful. Please login.', 'success');
//    } catch (error) {
//        console.log('Error: ' + error);
//        this.showToast('Error', 'An error occurred during registration', 'error');
//    }
//  }

  validateFields() {
    return (
      this.firstName &&
      this.lastName &&
      this.email &&
      this.birthdate &&
      this.ssn &&
      this.dln &&
      this.employment &&
      this.income &&
      this.phone &&
      this.street &&
      this.city &&
      this.state &&
      this.zip &&
      this.country &&
      this.password
    );
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