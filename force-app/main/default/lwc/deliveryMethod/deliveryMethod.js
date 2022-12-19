/**
    Author:         Derrick Vuong
    Company:        Salesforce
    Description:    deliveryMethod.js
    Date:           29-Sep-2022

    TODO:
    - 
**/

import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getDeliveryMethods from '@salesforce/apex/DeliveryMethodController.getDeliveryMethods';
import shippingMethod from '@salesforce/label/c.Shipping_Method';

export default class DeliveryMethod extends LightningElement {
    @api showTitle;
    @api cartId;
    @api recordId;
    @api storeOrNetworkId;
    @api selectedDeliveryMethodId;

    @api
    validate() {
        let isValid = true;
        let errorMessage;

        if(this.selectedDeliveryMethodId == null) {
            isValid = false;
            errorMessage = "Select a Shipping Method";
        }

        if(isValid === true) { 
            return { isValid: true }; 
        }
        else {
            return { 
                isValid: false, 
                errorMessage: errorMessage
            }; 
        }
    }

    labels = {
        shippingMethod,
    };

    wiredData;
    deliveryMethods;
    isLoading = true;
    showDeliveryMethods = false;

    @wire(getDeliveryMethods, {
        cartId : "$cartId"
    }) getDeliveryMethods(value) {
        this.wiredData = value;
        const {error, data} = value;
        
        if(data && data.length > 0) {
            this.deliveryMethods = JSON.parse(JSON.stringify(data));
            this.showDeliveryMethods = true;
            if(this.selectedDeliveryMethodId != null) {
                for(let i=0; i < this.deliveryMethods.length; i++) {
                    if(this.deliveryMethods[i].deliveryMethodId == this.selectedDeliveryMethodId) {
                        this.deliveryMethods[i].checked = true;
                    }
                }
            }
        } else if(error) {
            console.error("OMS Order Entry Delivery Methods Error: ", error);
        } else {
            let count = 0;
            let refresh = setTimeout(() => {
                refreshApex(this.wiredData);
                count++;
                if(count == 20) {
                    clearTimeout(refresh);
                }
            }, 2000);
        }
    }

    renderedCallback() {
        if(this.deliveryMethods != null && this.deliveryMethods.length > 0) {
            this.showDeliveryMethods = true;
        }
    }
    
    deliveryMethodSelectHandler(event) {
        this.selectedDeliveryMethodId = event.target.value;
    }
}