import { LightningElement, api } from 'lwc';

// Import Custom Labels
import newAddress from '@salesforce/label/c.New_Address';
import backToList from '@salesforce/label/c.Back_to_list';
import firstName from '@salesforce/label/c.First_Name';
import lastName from '@salesforce/label/c.Last_Name';
import street from '@salesforce/label/c.Street';
import city from '@salesforce/label/c.City';
import state from '@salesforce/label/c.State';
import postalCode from '@salesforce/label/c.Postal_Code';
import country from '@salesforce/label/c.Country';
import defaultText from '@salesforce/label/c.Default';
import makeDefaultAddress from '@salesforce/label/c.Make_Default_Address';

const NEW_ADDRESS = "New";
const SELECT_ADDRESS = "Select";

export default class AddressSelector extends LightningElement {
    _addresses;
    _hideTitle = false;
    _hideName = false;
    _hideNameInput = false;
    _hideMakeDefaultAddress = false;

    @api addressType = "Shipping";
    @api selectedAddressId;

    @api 
    set addresses(value) {
        this._addresses = JSON.parse(JSON.stringify(value));
    }

    get addresses() {
        return this._addresses;
    }

    @api 
    set hideTitle(value) {
        this._hideTitle = value === "false" || !value ? false : true;
    }

    get hideTitle() {
        return this._hideTitle;
    }

    @api 
    set hideName(value) {
        this._hideName = value === "false" || !value ? false : true;
    }

    get hideName() {
        return this._hideName;
    }

    @api 
    set hideNameInput(value) {
        this._hideNameInput = value === "false" || !value ? false : true;
    }

    get hideNameInput() {
        return this._hideNameInput;
    }

    @api 
    set hideMakeDefaultAddress(value) {
        this._hideMakeDefaultAddress = value === "false" || !value ? false : true;
    }

    get hideMakeDefaultAddress() {
        return this._hideMakeDefaultAddress;
    }

    @api
    getAddressDetails() {
        return this.newAddressDetails;
    }

    @api
    getNewAddress() {
        return this.newAddress;
    }

    get hasExistingAddresses() {
        return this.addresses != null && this.addresses.length > 0 ? true : false;
    }

    labels = {
        newAddress,
        backToList,
        firstName,
        lastName,
        street,
        city,
        state,
        postalCode,
        country,
        defaultText,
        makeDefaultAddress
    };

    name = {};
    newAddressDetails = {};
    addressChangeTimeout;
    hasRendered = false;
    showAddresses = false;
    newAddress = false;

    connectedCallback() {
        this.newAddressDetails = {
            "addressType" : this.addressType,
            "isDefault" : false
        };
        if(this.addressType === "Shipping" && this.addresses.length && this.selectedAddressId != null) {
            this.setSelectedAddress();
        }
    }

    renderedCallback() {
        if(this.hasRendered) {
            return;
        }

        if(this.addresses != null && this.addresses.length > 0) {
            this.toggleView(SELECT_ADDRESS);
            this.hasRendered = true;
        } else if(this.addresses != null) {
            this.toggleView(NEW_ADDRESS);
            this.hasRendered = true;
        }
    }

    handleFirstNameChange(event) {
        this.name["FirstName"] = event.detail.value;
        this.setAddressName();
    }

    handleLastNameChange(event) {
        this.name["LastName"] = event.detail.value;
        this.setAddressName();
    }

    setAddressName() {
        let name = "";
        if(this.name.FirstName && this.name.FirstName != "") {
            name = this.name.FirstName;
        }

        if(this.name.LastName && this.name.LastName != "") {
            name += ' ' + this.name.LastName;
        }

        this.newAddressDetails["name"] = name;
    }

    /**
     * handleAddressChange
     * @desc Handle updates to the input address lines. Stores details and also fires a custom change event
     * 
     * @param {*} event 
     */
    handleAddressChange(event) {
        this.newAddressDetails = {...this.newAddressDetails, ...event.detail};
        // console.log(this.newAddressDetails, this.newAddressDetails.validity.valid);
        this.dispatchCustomEvent("addresschangeevent", this.newAddressDetails);
    }


    /**
     * handleAddressSelect
     * @desc Handle selection of address choices, updates the selected id which is a ContactPointAddressId to be output
     * 
     * @param {*} event 
     */
     handleAddressSelect(event) {
        this.selectedAddressId = event.target.value;
        this.dispatchCustomEvent("addressselectevent", this.selectedAddressId);
    }

    handleMakeDefaultAddress(event) {
        console.log("Is Default", event.detail.checked);
        this.newAddressDetails["isDefault"] = event.detail.checked;
    }

    handleNewAddressClick() {
        this.toggleView(NEW_ADDRESS);
    }

    handleBackToListClick() {
        this.toggleView(SELECT_ADDRESS);
    }

    toggleView(state) {
        if(state === SELECT_ADDRESS) {
            this.newAddress = false;
            this.showAddresses = true;
        } else {
            this.newAddress = true;
            this.showAddresses = false;
        }
    }

    setAddressDefaultPosition(addresses) {
        if(addresses.length > 0) {
            addresses = JSON.parse(JSON.stringify(addresses));
            const index = addresses.findIndex(address => address.isDefault == true);
            if(index > 0) {
                addresses.unshift(addresses.splice(index, 1)[0]);
            }
        }
        return addresses;
    }

    setSelectedAddress() {
        const index = this.addresses.findIndex(address => address.addressId == this.selectedAddressId);
        this.addresses[index].checked = true;
        this.selectedAddressId = this.selectedAddressId || this.addresses[index].addressId;
    }

    dispatchCustomEvent(eventName, detail) {
        this.dispatchEvent(
            new CustomEvent(eventName, {
                bubbles: false,
                composed: false,
                cancelable: false,
                detail
            })
        );
    }
}