/**
    Author:         Derrick Vuong
    Company:        Salesforce
    Description:    shippingAddress.js
    Date:           29-Sep-2022

    TODO:
    - 
**/

import { LightningElement, wire, api } from 'lwc';

// Import Apex Methods
import getAccountAddresses from '@salesforce/apex/ShippingAddressController.getAccountAddresses';
import createAccountAddress from '@salesforce/apex/ShippingAddressController.createAccountAddress';

// Import Custom Labels
import selectShippingAddress from '@salesforce/label/c.Select_Shipping_Address';
import specialInstructions from '@salesforce/label/c.Shipping_Instructions';
import specialInstructionsPlaceholder from '@salesforce/label/c.Shipping_Instructions_Placeholder';

const NEW_ADDRESS_VIEW = "New";
const SELECT_ADDRESS_VIEW = "Select";

export default class ShippingAddress extends LightningElement {
    @api hideTitle;
    @api recordId;
    @api storeOrNetworkId;
    @api selectedAddressId;
    @api specialInstructions;
    @api hideSpecialInstructions;

    @api
    validate() {
        const selectedAddressResult = this.getShippingAddress();
        if(selectedAddressResult.error) {
            console.error("Selected Address Result", selectedAddressResult.error);
            return {
                isValid : false,
                errorMessage : selectedAddressResult.error
            };
        }
        
        if (selectedAddressResult.address && selectedAddressResult.address?.addressId == null) {
            createAccountAddress({
                accountOrRelatedId : this.recordId,
                storeOrNetworkId : this.storeOrNetworkId,
                addressDetails : selectedAddressResult.address
            }).then((data) => {
                this.selectedAddressId = data;
            }).catch((error) => {
                console.error("createAccountAddress error", error);
                return {
                    isValid : false,
                    errorMessage : "Failed to create new shipping address"
                };
            });
        } else if (this.selectedAddressId) {
            
        } else {
            return {
                isValid : false,
                errorMessage : "Shipping address is required"
            };
        }

        return { isValid: true };
    }

    labels = {
        selectShippingAddress,
        specialInstructions,
        specialInstructionsPlaceholder
    };

    wiredData;
    shippingAddresses;
    hasRendered = false;

    @wire(getAccountAddresses, {
        accountOrRelatedId : "$recordId",
        storeOrNetworkId : "$storeOrNetworkId"
    }) getAccountAddresses(value) {
        this.wiredData = value;
        const {error, data} = value;
        
        if(data) {
            this.shippingAddresses = this.setAddressDefaultPosition(data);
            this.setSelectedAddress();
        } else if(error) {
            console.error("OMS Order Entry Shipping Address Error: ", error);
        } else {
            // console.log("OMS Order Entry Shipping Address: No Data");
        }
    }

    renderedCallback() {
        if(this.hasRendered) {
            return;
        }
    }


    /**
     * addressSelectHandler
     * @desc Handle selection of address choices, updates the selected id which is a ContactPointAddressId to be output
     * 
     * @param {*} event 
     */
    addressSelectHandler(event) {
        this.selectedAddressId = event.target.value;
    }

    handleAddressSelectEvent(event) {
        this.selectedAddressId = event.detail;
    }


    /**
     * addressChangeHandler
     * @desc Handle updates to the input address lines. Check general validity of address then 
     * set a 3.5s delay before attempting to write the address to database. 
     * 
     * @param {*} event 
     */
    addressChangeHandler(event) {
        /* const validAddressFormat = event.detail.validity.valid;

        if(this.addressChangeTimeout) {
            clearTimeout(this.addressChangeTimeout);
        }

        if(validAddressFormat) {
            this.addressChangeTimeout = setTimeout(() => {
                console.log(JSON.parse(JSON.stringify(event.detail)));
                // TODO: Handle address save and update here. Need to check against name and make default checkbox too
                // this.startProductSearch(searchText);
              }, 3500);
        } */
    }


    specialInstructionsChangeHandler(event) {
        const specialInstructions = event.detail.value;
        this.specialInstructions = specialInstructions;
    }

    makeDefaultSelectHandler(event) {
        console.log(event);
        // TODO: Handle address save and update here. Need to check against name and make default checkbox too
    }

    setAddressDefaultPosition(addresses) {
        if(addresses.length) {
            addresses = JSON.parse(JSON.stringify(addresses));
            const index = addresses.findIndex(address => address.isDefault == true);
            if(index > 0) {
                addresses.unshift(addresses.splice(index, 1)[0]);
            }
        }
        return addresses;
    }

    setSelectedAddress() {
        const index = this.selectedAddressId == null ? 0 : this.shippingAddresses.findIndex(address => address.addressId == this.selectedAddressId);
        this.shippingAddresses[index].checked = true;
        this.selectedAddressId = this.shippingAddresses[index].addressId;
    }

    /**
     * @returns The selected shipping address in an object { address: <the selected shipping address> } or
     *          { error: <the error message> } if the field is required but missing. It can return an empty
     *          object if there is no shipping address and it's not a required field.
     */
    getShippingAddress() {
        const addressCmp = this.template.querySelector("c-address-selector");
        const isNewAddress = addressCmp.getNewAddress();
        if(isNewAddress) {
            const addressDetails = addressCmp.getAddressDetails();
            if(addressDetails.validity && addressDetails.validity.valid) {
                return { address : addressDetails };
            } else {
                return { error: 'Shipping Address is invalid' };
            }
        } else if(this.selectedAddressId) {
            return { address : this.shippingAddresses.find(address => address.addressId == this.selectedAddressId) };
        } else {
            return { error: 'Shipping Address is required' };
        }
    }
}