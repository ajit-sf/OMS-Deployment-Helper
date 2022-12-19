import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
   FlowNavigationNextEvent,
} from 'lightning/flowSupport';

import { reduceErrors } from 'c/utility';

import createCardAndAddItems from '@salesforce/apex/ProductSearchDataService.createCardAndAddItems';
import getCurrentCartItems from '@salesforce/apex/ProductSearchDataService.getCurrentCartItems';
import getProducts from '@salesforce/apex/ProductSearchDataService.getProducts';
import deleteCartItemHelper from '@salesforce/apex/ProductSearchDataService.deleteCartItemHelper';

export default class LineItemContainer extends LightningElement {
    @api recordId;
    @api webstoreId;
    @api searchResultFields;
    @api searchResultMetaFieldAPI;
    @api searchResultSuggestionMax;
    @api searchResultFieldsLabel;
    
    @api generatedCartId;

    @track lineItems = [];
    tempDraftValues;

    isProductSearch = false;

    columns = [];

    isLoading = false;

    get isItemExist(){
        return this.lineItems.length > 0;
    }

    connectedCallback(){
        try{
            let fieldLabels = this.searchResultFieldsLabel.split(',');
            for(let i = 0; i < this.searchResultFields.split(',').length; i++){
                if(this.searchResultFields.split(',')[i] === 'id' || this.searchResultFields.split(',')[i] === 'Id')
                    continue;
                
                this.columns.push({label : fieldLabels[i], fieldName : this.searchResultFields.split(',')[i]});

                if(this.columns.length > 2){
                    break;
                }
            }
            this.columns.push({label : 'Unit Price', fieldName : `unitPrice`, type: 'currency', cellAttributes: { alignment: 'left' }});
            this.columns.push({label : 'Quantity', fieldName : `quantity`, editable: true});
            this.columns.push({label : 'Total ', fieldName : `total`, type: 'currency', cellAttributes: { alignment: 'left' }});
            this.columns.push({type : 'action', typeAttributes : {rowActions : [ { label: 'Delete', name: 'delete' }]}});

            this.handleGetCartItems();
            
        }
        catch(e){
            console.error(e);
        }

    }

    handleSave = (event) => {
        const draftArr = event.detail.draftValues;
        for(let i of draftArr){
            const index = this.lineItems.findIndex(ele => ele.id === i.id);
            this.lineItems[index].quantity = i.quantity;
        }
        this.tempDraftValues = null;
        console.log('Handle Save');
    }

    handleGetCartItems = async () => {

        this.isLoading = true;
        
        if(this.generatedCartId){
            let cartItems = await getCurrentCartItems({
                webstoreId : this.webstoreId,
                cartId : this.generatedCartId,
                effectiveAccountId : this.recordId
            });
            
            let cartItemData = [];
            let productIds = [];

            for(let i of cartItems.cartItems){
                cartItemData.push({
                    productId : i.cartItem.productId,
                    quantity : i.cartItem.quantity,
                    cartItemId : i.cartItem.cartItemId,
                });
                productIds.push(i.cartItem.productId);
            }
            if(productIds.length>0){
                let products = await getProducts({
                    webstoreId : this.webstoreId,
                    effectiveAccountId : this.recordId,
                    ids : productIds,
                    fields : this.searchResultFields.split(',')
                });
                
                this.lineItems = products.products;
    
                for(let i of cartItemData){
                    const index = this.lineItems.findIndex(ele => ele.id === i.productId);
                    this.lineItems[index].quantity = i.quantity;
                    this.lineItems[index].cartItemId = i.cartItemId;
                }
            }
        }

        this.isLoading = false;
    }

    get lineItemsArr(){
        return this.lineItems.map(ele => {
            for(let i of this.searchResultFields.split(',')){
                ele[i] = ele['fields'][i];
            }
            ele['unitPrice'] = ele.prices.unitPrice;
            ele['total'] = ele.prices.unitPrice * ele.quantity;
            return ele;
        });
    }

    handleProductSearch = () => {
        this.isProductSearch = true;
    }

    handleCloseSearch = () => {
        this.isProductSearch = false;
    }

    handleProductAddition = (evt) => {

        let newAddedProd = JSON.parse(evt.detail.data);

        for(let i of newAddedProd){
            const index = this.lineItems.findIndex(ele => ele.id === i.id);
            if(index > -1){
                this.lineItems[index].quantity = parseInt(this.lineItems[index].quantity) + i.quantity;
            }
            else{
                this.lineItems.push(i);
            }
        }

        if(evt.detail.closeSearch === 'Add')
            this.isProductSearch = false;
    }

    async handleRowAction(event) {
        const row = event.detail.row;
        const { id } = row;
        const index = this.lineItems.findIndex(ele => ele.id === id);
        if(this.lineItems[index].cartItemId){
            this.isLoading = true;
            await deleteCartItemHelper({
                webstoreId : this.webstoreId, 
                effectiveAccountId : this.recordId,
                activeCartOrId : this.generatedCartId,
                cartItemId : this.lineItems[index].cartItemId
            });
            this.isLoading = false;
        }
        this.lineItems.splice(index,1);
    }

    handleNextFlowChange = async () => {
        
        try{
            this.isLoading = true;

            let selectedProd = [];
            for(let i of this.lineItemsArr){
                selectedProd.push({
                    productId : i.id,
                    quantity : i.quantity,
                    cartItemId : i.cartItemId,
                });
            }

            this.generatedCartId = await createCardAndAddItems({webstoreId : this.webstoreId, effectiveAccountId : this.recordId, productDataStr : JSON.stringify(selectedProd), cartId : this.generatedCartId});
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        catch(e){
            let error = reduceErrors(e);
            console.error('error' + error);
            const event = new ShowToastEvent({
                title: 'Something went wrong!',
                message:
                    error,
            });
            this.dispatchEvent(event);
        }
        this.isLoading = false;
    }

}