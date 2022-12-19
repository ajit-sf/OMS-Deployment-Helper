import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import getCheckoutSession from '@salesforce/apex/checkoutSessionWaitController.getCheckoutSession';


export default class CheckoutSessionWait extends LightningElement {
    @api checkoutSessionId;
    @api availableActions = [];

    wiredData;
    checkoutSession;
    displayedMessage = "";
    isLoading = true;

    @wire(getCheckoutSession, {
        checkoutSessionId : "$checkoutSessionId"
    }) handleWireData(value) {
        this.wiredData = value;
        const {error, data} = value;

        if(data) {
            this.checkoutSession = data;
            if(data.IsProcessing === false) {
                this.goNextAction();
            } else {
                let count = 0;
                let refresh = setTimeout(() => {
                    refreshApex(this.wiredData);
                    count++;
                    if(count == 5) {
                        this.displayedMessage = "This is taking a little longer than expected. Please bear with us.";
                    }
                    else if(count == 20) {
                        clearTimeout(refresh);
                        this.goNextAction();
                    }
                }, 2000);
            }
        } else if(error) {
            console.error(error);
        }
    }

    goNextAction() {
        this.isLoading = false;
        if(this.availableActions.find((action) => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}