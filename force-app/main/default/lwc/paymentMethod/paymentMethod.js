import { LightningElement, api, wire } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';

// Import Apex Methods
import getAccountAddresses from '@salesforce/apex/BillingAddressController.getAccountAddresses';
import getPaymentInfo from '@salesforce/apex/PaymentController.getPaymentInfo';
import setPayment from '@salesforce/apex/PaymentController.setPayment';

const PO_NUMBER = 'PurchaseOrderNumber';
const CARD_PAYMENT = 'CardPayment';

// TODO: Replace with label imports
const labels  = {
    paymentMethod: 'Payment Method',
    billingSameAddress: 'My billing address is the same as my shipping address',
    paymentMethodHeader: 'Payment Method',
    purchaseOrderOptionLabel: 'Purchase Order',
    purchaseOrderEntryHeader: 'Enter PO Number',
    cardPaymentOptionLabel: 'Credit Card',
};

/**
 * Allows users to choose the type of payment (eg. Purchase Order, Credit Card)
 * and to fill out the required information for the chosen type.
 *
 * @fires FlowNavigationNextEvent
 * @fires FlowNavigationBackEvent
 * @fires PaymentMethod#submitpayment
 */
export default class PaymentMethod extends LightningElement {
    /**
     * Comes from the flow itself and only available in flow. Given this component is only designed
     * for use in flows, this is probably fine. The actions will tell us if "Previous" is available
     * so we can display the "Previous" button only when it's available.
     */
    @api availableActions;

    @api recordId;
    @api storeOrNetworkId;
    @api selectedAddressId
    @api poRequired = false;
    @api cardHolderNameRequired = false;
    @api cardTypeRequired = false;
    @api expiryMonthRequired = false;
    @api expiryYearRequired = false;
    @api cvvRequired = false;

    @api hideTitle = false;
    @api hideCardHolderName = false;
    @api hideCardType = false;
    @api hideCvv = false;
    @api hideExpiryMonth = false;
    @api hideExpiryYear = false;
    @api hidePurchaseOrder = false;
    @api hideCreditCard = false;

    @api previousButtonLabel = 'Previous';
    @api nextButtonLabel = 'Next';

    /**
     * ! Not using validate() because it rerenders the component and input data is lost. Stick with custom button and handler until fixed.
     * Handles the validation when the Flow attempts to proceed to the next screen.
     * If PO Number is selected, make an apex call to set the new values.
     * If Credit Card is selected, check to see that all required fields are filled in first,
     * then makes an apex call which in turns makes a call to Payment.tokenize endpoint
     */
    /* @api
    validate() {
        let isValid = true;
        let errorMessage;

        const selectedAddressResult = this.getBillingAddress();

        if (this.selectedPaymentType !== CARD_PAYMENT) {
            if (selectedAddressResult.error) {
                this.purchaseOrderErrorMessage = selectedAddressResult.error;
                errorMessage = selectedAddressResult.error;
                isValid = false;
            }

            const poInput = this.getComponent('[data-po-number]');            
            // Make sure that PO input is valid first
            if (poInput != null && !poInput.reportValidity()) {
                isValid = false;
            }

            const paymentInfo = {
                poNumber: this.purchaseOrderNumber
            };

            setPayment({
                paymentType: this.selectedPaymentType,
                cartId: this.cartId,
                billingAddress: selectedAddressResult.address,
                paymentInfo: paymentInfo
            }).then(() => {
                // After making the server calls, navigate NEXT in the flow
                // const navigateNextEvent = new FlowNavigationNextEvent();
                // this.dispatchEvent(navigateNextEvent);
            }).catch((error) => {
                this.purchaseOrderErrorMessage = error.body.message;
                errorMessage = error.body.message;
                isValid = false;
            });
        } else {
            if (selectedAddressResult.error) {
                this.creditCardErrorMessage = selectedAddressResult.error;
                errorMessage = selectedAddressResult.error;
                isValid = false;
            }

            // First let's get the cc data
            const creditPaymentComponent = this.getComponent('[data-credit-payment-method]');

            // Second let's make sure the required fields are valid
            if (creditPaymentComponent != null && !creditPaymentComponent.reportValidity()) {
                isValid = false;
                errorMessage = "Credit Card details are invald";
            }

            const creditCardData = this.getCreditCardFromComponent(creditPaymentComponent);
            
            setPayment({
                paymentType: this.selectedPaymentType,
                cartId: this.cartId,
                billingAddress: selectedAddressResult.address,
                paymentInfo: creditCardData
            }).then(() => {
                // After making the server calls, navigate NEXT in the flow
                // const navigateNextEvent = new FlowNavigationNextEvent();
                // this.dispatchEvent(navigateNextEvent);
            }).catch((error) => {
                this.creditCardErrorMessage = error.body.message;
                errorMessage = error.body.message;
                isValid = false;
            });
        }

        if(isValid === true) { 
            return { isValid: true }; 
        }
        else {
            return { 
                isValid: false, 
                errorMessage: errorMessage || ""
            }; 
        }
    } */

    @api
    get selectedPaymentType() {
        return this._selectedPaymentType;
    }

    set selectedPaymentType(newPaymentType) {
        this._selectedPaymentType = newPaymentType;
    }

    @api purchaseOrderNumber;

    /**
     * The address data. Used to pass the user's addresses to the child billing address components.
     * @type {Address[]}
     */
    @api addresses;

    @api selectedBillingAddress;

    @api hideBillingAddress = false;
    @api billingAddressRequired = false;

    /**
     * The error message string if there is an error with displaying billing addresses.
     * Errors that are possible are no access to web cart/ no access to CPA/ or no billing addresses in the list.
     *
     * @type {String}
     */
    @api billingAddressErrorMessage;

    @api
    get cartId() {
        return this._cartId;
    }

    set cartId(cartId) {
        this._cartId = cartId;
        if (cartId) {
            this.initializePaymentData(cartId);
        }
    }

    get labels() {
        return labels;
    }

    get canGoPrevious() {
        return (this.availableActions && this.availableActions.some(element => element == 'BACK'));
    }

    get paymentTypes() {
        return {
            poNumber: PO_NUMBER,
            cardPayment: CARD_PAYMENT
        };
    }

    get isCardPaymentSelected() {
        return (
            this.actualSelectedPaymentType ===
            CARD_PAYMENT && !this.hideCreditCard
        );
    }

    /**
     * Get state of selected payment type
     * @return {boolean} true if selected payment type is PO number
     */
    get isPoNumberSelected() {
        return (
            this.actualSelectedPaymentType ===
            PO_NUMBER && !this.hidePurchaseOrder
        );
    }

    /**
     * Get the selected payment type.
     * If hidePurchaseOrder is true, default to cardPayment.
     * if hideCreditCard is true, default to PurchaseOrderNumber.
     * @private
     */
    get actualSelectedPaymentType() {
        return this.hidePurchaseOrder
        ? CARD_PAYMENT
        : (this.hideCreditCard ? PO_NUMBER : this.selectedPaymentType);
    }

    get hidePaymentTypes() {
        return this.hidePurchaseOrder || this.hideCreditCard ? true : false;
    }

    get paymentMethodOptions() {
        return [
            { label: this.labels.purchaseOrderOptionLabel, value: PO_NUMBER },
            { label: this.labels.cardPaymentOptionLabel, value: CARD_PAYMENT },
        ];
    }

    _cartId;
    _selectedPaymentType = PO_NUMBER;

    creditCardErrorMessage;
    sameAsShippingAddress = true;
    purchaseOrderErrorMessage = '';
    wiredData;
    billingAddresses;

    cardTypes = [
        { label : 'Visa', value : 'Visa' },
        { label : 'Master Card', value : 'MasterCard' },
        { label : 'American Express', value : 'AmericanExpress' },
        { label : 'Diners Club', value : 'DinersClub' },
        { label : 'JCB', value : 'JCB' },
    ];

    @wire(getAccountAddresses, {
        accountOrRelatedId : "$recordId",
        storeOrNetworkId : "$storeOrNetworkId"
    }) getAccountAddresses(value) {
        this.wiredData = value;
        const {error, data} = value;
        
        if(data) {
            this.billingAddresses = this.setAddressDefaultPosition(data);
            if(this.billingAddresses.length > 0) {
                this.setSelectedAddress(this.billingAddresses);
            }
        } else if(error) {
            console.error("Payment Method Error: ", error);
        } else {
            // console.log("Payment Method No Data");
        }
    }

    /**
     * Handler to initialize the payment component
     * @param {String} cartId - the current webCart ID
     */
    initializePaymentData(cartId) {
        // If we don't have those values yet
        /* getPaymentInfo({ cartId: cartId, accountOrRelatedId : this.recordId })
            .then((data) => {
                this.purchaseOrderNumber = data.purchaseOrderNumber;
                this.addresses = data.addresses;
            })
            .catch((error) => {
                //do nothing, continue as normal
                console.log(error.body.message);
            }); */
    }

    /**
     * Handler for the 'blur' event fired from the purchase order input.
     */
    handleUpdate() {
        const poComponent = this.getComponent('[data-po-number]');
        const poData = (poComponent.value || '').trim();
        this.purchaseOrderNumber = poData;
    }

    /**
     * Handler for the 'click' event fired from the payment type radio buttons.
     * @param {event} event - The selected payment type
     */
    handlePaymentTypeSelected(event) {
        this.selectedPaymentType = event.detail.value;
    }

    /**
     * Navigates to the previous page. Doesn't save any information, so that information is lost on clicking
     * Previous.
     */
    handlePreviousButton() {
        const navigatePreviousEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigatePreviousEvent);
    }

    handleSameAsShippingClick(event) {
        const checked = event.detail.checked;
        this.sameAsShippingAddress = checked;
    }

    /**
     * Handler for the 'click' event fired from the payment button.
     * If PO Number is selected, make an apex call to set the new values.
     * If Credit Card is selected, check to see that all required fields are filled in first,
     * then makes an apex call which in turns makes a call to Payment.tokenize endpoint
     */
     handlePaymentButton() {
        const selectedAddressResult = this.getBillingAddress();
        console.log("handlePaymentButton() selectedAddressResult", JSON.parse(JSON.stringify(selectedAddressResult)));

        if (this.selectedPaymentType !== CARD_PAYMENT) {
            if (selectedAddressResult.error) {
                this.purchaseOrderErrorMessage = selectedAddressResult.error;
                return;
            }

            const poInput = this.getComponent('[data-po-number]');

            console.log("Validate PO Number", this.purchaseOrderNumber, poInput.reportValidity(), poInput.checkValidity());
            // Make sure that PO input is valid first
            if(this.purchaseOrderNumber == null) {
                this.purchaseOrderErrorMessage = "PO Number cannot be empty";
                return;
            } else if (poInput != null && !poInput.reportValidity()) {
                this.purchaseOrderErrorMessage = "PO Number is invalid";
                return;
            } else {

            }

            const paymentInfo = {
                poNumber: this.purchaseOrderNumber
            };

            setPayment({
                paymentType: this.selectedPaymentType,
                cartId: this.cartId,
                billingAddress: selectedAddressResult.address,
                paymentInfo: paymentInfo
            }).then(() => {
                // After making the server calls, navigate NEXT in the flow
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }).catch((error) => {
                this.purchaseOrderErrorMessage = error.body.message;
            });
        } else {
            if (selectedAddressResult.error) {
                this.creditCardErrorMessage = selectedAddressResult.error;
                return;
            }

            // First let's get the cc data
            const creditPaymentComponent = this.getComponent('[data-credit-payment-method]');

            // Second let's make sure the required fields are valid
            if (creditPaymentComponent != null && !creditPaymentComponent.reportValidity()) {
                return;
            }

            const creditCardData = this.getCreditCardFromComponent(
                creditPaymentComponent
            );
            
            setPayment({
                paymentType: this.selectedPaymentType,
                cartId: this.cartId,
                billingAddress: selectedAddressResult.address,
                paymentInfo: creditCardData
            }).then(() => {
                // After making the server calls, navigate NEXT in the flow
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }).catch((error) => {
                this.creditCardErrorMessage = error.body.message;
            });
        }
    }

    /**
     * @returns The selected billing address in an object { address: <the selected billing address> } or
     *          { error: <the error message> } if the field is required but missing. It can return an empty
     *          object if there is no billing address and it's not a required field.
     */
    getBillingAddress() {
        if(!this.sameAsShippingAddress && this.billingAddressRequired) {
            const addressCmp = this.getComponent("c-address-selector");
            if(addressCmp.getNewAddress()) {
                const addressDetails = addressCmp.getAddressDetails();
                console.log("getBillingAddress() addresssDetails", addressDetails);
                if(addressDetails.validity && addressDetails.validity.valid) {
                    return { address : addressDetails };
                } else {
                    return { error: 'Billing Address is invalid' };
                }
            } else if(this.selectedAddressId) {
                // console.log("getBillingAddress() selectedAddress", this.selectedAddressId);
                // return { address: this.billingAddresses.filter(add => add.id === this.selectedAddressId)[0] };
                return { address : this.billingAddresses.find(address => address.id == this.selectedAddressId) };
            }
            else {
                return { error: 'Billing Address is required' };
            }
        } else if(this.sameAsShippingAddress) {
            // console.log("getBillingAddress(): same as shipping address");
        }

        return {};
    }

    getCreditCardFromComponent(creditPaymentComponent) {
        const cardPaymentData = {};
        [
            'cardHolderName',
            'cardNumber',
            'cvv',
            'expiryYear',
            'expiryMonth',
            'expiryYear',
            'cardType'
        ].forEach((property) => {
            cardPaymentData[property] = creditPaymentComponent[property];
        });
        return cardPaymentData;
    }

    /**
     * Set the address selected
     */
    handleChangeSelectedAddress(event) {
        const address = event.detail.address;
        if (address.id !== null && (address.id).startsWith('8lW')) {
            this.selectedBillingAddress = address.id;
        } else {
            this.selectedBillingAddress = '';
        }
    }

    handleAddressSelectEvent(event) {
        this.selectedAddressId = event.detail;
    }

    setAddressDefaultPosition(addresses) {
        if(addresses.length && addresses.length > 0) {
            addresses = JSON.parse(JSON.stringify(addresses));
            const index = addresses.findIndex(address => address.isDefault == true);
            if(index > 0) {
                addresses.unshift(addresses.splice(index, 1)[0]);
            }
        }
        return addresses;
    }

    setSelectedAddress(addresses) {
        const index = this.selectedAddressId == null ? 0 : addresses.findIndex(address => address.addressId == this.selectedAddressId);
        addresses[index].checked = true;
        this.selectedAddressId = addresses[index].addressId;
    }

    /**
     * Simple function to query the passed element locator
     * @param {*} locator The HTML element identifier
     * @private
     */
    getComponent(locator) {
        return this.template.querySelector(locator);
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