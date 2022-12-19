import { api, LightningElement } from 'lwc';

import getProductSuggestion from '@salesforce/apex/ProductSearchDataService.getProductSuggestion';

export default class ProductSearchLookup extends LightningElement {

    @api webstoreId;
    @api recordId;
    @api searchResultFields;
    @api searchResultMetaFieldAPI;
    @api searchResultSuggestionMax;

    isLoading = false;

    suggestedItems = [];
    backendSuggestedItems = [];

    doneTypingInterval = 300;
    typingTimer;

    isEnterPressed = false;

    get isSuggestedItems(){
        return this.suggestedItems.length > 0;
    }

    handleProductSuggest = (event) => {
        if(event.keyCode === 13)
            return;

        this.isEnterPressed = false;
        clearTimeout(this.typingTimer);

        let searchTerm = event.target.value;

        this.typingTimer = setTimeout(() => {
            if(searchTerm && searchTerm.length > 2){
                this.handleProductSuggestHelper(searchTerm);
            }
            else{
                this.suggestedItems = [];
            }
        }, this.doneTypingInterval);
    }

    handleProductSuggestHelper = async (searchTerm) => {
        
        this.isLoading = true;
        let res = await getProductSuggestion({
            webstoreId : this.webstoreId,
            effectiveAccountId : this.recordId,
            searchTerm : searchTerm,
            searchResultFields : this.searchResultFields,
        });

        console.log(JSON.stringify(res));
        
        if(res.productsPage.products.length > 0){
            let mainField = this.searchResultMetaFieldAPI.split(',')[0];
            let metaField = this.searchResultMetaFieldAPI.split(',')[1];

            this.backendSuggestedItems = res;

            if(!this.isEnterPressed)
                {
                    this.suggestedItems = res.productsPage.products.slice(0,this.searchResultSuggestionMax).map(ele => {
                        ele.mainField = ele['fields'][mainField]['value'];
                        ele.metaField = ele['fields'][metaField]['value'];
                        return ele;
                    });  
                }
        }
        else{
            this.suggestedItems = [];
            this.backendSuggestedItems = [];
        }
        this.isLoading = false;
    }

    handleItemSelected = (evt) => {
        const productId = evt.target.dataset.item;
        this.dispatchEvent(new CustomEvent('itemselected', {detail : [productId]}));
        this.suggestedItems = [];
    }

    handleProductMoreDetails = async (evt) => {
        let searchTerm = evt.target.value;
        if(evt.keyCode === 13 && searchTerm.length > 2){
            this.isEnterPressed = true;
            await this.handleProductSuggestHelper(searchTerm);
            let productIds = [];
            if(this.backendSuggestedItems.productsPage)
            {
                for(let i of this.backendSuggestedItems.productsPage.products){
                    productIds.push(i.id);
                }
            }
            this.dispatchEvent(new CustomEvent('itemselected', {detail : productIds}));
            this.suggestedItems = [];
            clearTimeout(this.typingTimer);
        }
    }


}