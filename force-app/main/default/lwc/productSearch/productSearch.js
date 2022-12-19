import { api, LightningElement } from 'lwc';

import getProducts from '@salesforce/apex/ProductSearchDataService.getProducts';

export default class ProductSearch extends LightningElement {

    @api webstoreId;
    @api recordId;
    @api searchResultFields;
    @api searchResultMetaFieldAPI;
    @api searchResultSuggestionMax;
    @api searchResultFieldsLabel;

    searchResultFieldsSettings = [];

    searchedItems = [];

    addProductItems = [];

    connectedCallback(){
        let settings = this.searchResultFields.split(',').map((ele, index) => {

            return {
                label : this.searchResultFieldsLabel.split(',')[index],
                checked : true,
                apiName : ele
            }
        });
        this.searchResultFieldsSettings = settings.filter((ele) => {
            return ele.label  !== 'Id';
        })
    }

    get doesItemExist(){
        return this.searchedItems.length > 0;
    }

    handleItemSelected = async (evt) => {
        let productIds = JSON.parse(JSON.stringify(evt.detail));
        if(productIds.length>0){
            let res = await getProducts({
                webstoreId : this.webstoreId,
                effectiveAccountId : this.recordId,
                ids : productIds,
                fields : this.searchResultFields.split(',')
            });
            this.searchedItems = res.products;

            console.log(JSON.stringify(res));
        }
        else
            this.searchedItems = [];

        console.log('this.searchedItems' + JSON.stringify(this.searchedItems));
    }

    handleCloseSearch = () => {
        this.dispatchEvent(new CustomEvent('closesearch'));
    }

    handleAddProduct = (evt) => {
        const id = evt.detail.id;
        const quantity = evt.detail.quantity;
        if(this.addProductItems.findIndex(ele => ele.id === id) > -1){
            this.addProductItems.map(ele => {
                if(ele.id === id){
                    ele.quantity = quantity;
                }
                return ele;
            });
        }
        else{
            this.addProductItems.push({id : id, quantity : quantity});
        }
    }

    handleAddAndNewToLineItem = () => {
        let addedProducts = this.handleAddProductProcessing();
        this.searchedItems = [];
        this.addProductItems = [];
        this.dispatchEvent(new CustomEvent('addedproduct', {detail : {data : JSON.stringify(addedProducts), closeSearch : 'AddAndNew'} }));
    }

    handleAddProductToLineItem = () => {
        let addedProducts = this.handleAddProductProcessing();
        this.dispatchEvent(new CustomEvent('addedproduct', {detail : {data : JSON.stringify(addedProducts), closeSearch : 'Add'} }));
    }

    handleAddProductProcessing = () => {
        let addedProducts = [];
        for(let i of this.addProductItems){
            if(i.quantity > 0){
                const foundIndex = this.searchedItems.findIndex(ele => ele.id === i.id);
                addedProducts.push({...this.searchedItems[foundIndex], quantity : i.quantity});
            }
        }
        return addedProducts;
    }

   
}