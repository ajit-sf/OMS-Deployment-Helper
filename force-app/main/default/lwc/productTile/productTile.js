import { api, LightningElement } from 'lwc';

export default class ProductTile extends LightningElement {

    @api searchResultFields;
    @api searchResultMetaFieldAPI;
    @api searchResultFieldsLabel;

    productDetailVal = {};
    productDetailTransform = {};
    quantity = 0;

    connectedCallback(){
        this.productDetailTransform.headerName = this.productDetailVal['fields'][this.searchResultMetaFieldAPI.split(',')[0]];
        this.productDetailTransform.body = [];

        let fieldLabels = this.searchResultFieldsLabel.split(',');
        for(let i = 0; i < this.searchResultFields.split(',').length; i++){
            if(this.productDetailVal['fields'][this.searchResultFields.split(',')[i]])
                this.productDetailTransform.body.push({label : fieldLabels[i], value : this.productDetailVal['fields'][this.searchResultFields.split(',')[i]]});
        }
    }
    get productDetail(){
        return this.productDetailVal;
    }
    @api 
    set productDetail(val){
        this.productDetailVal = JSON.parse(JSON.stringify(val));
    }

    handleAddNewQuantity = () => {
        this.quantity++;
        this.handleAddproductTotal();
    }

    handleSubtractQuantity = () => {
        this.quantity--;
        this.handleAddproductTotal();
    }

    handleAddproductTotal = () => {
        this.dispatchEvent(new CustomEvent('addproduct', {detail : {id : this.productDetail.id, quantity : this.quantity}}));
    }

    get backGroundUrl(){
        return `background: url('${this.productDetail.defaultImage.url}');`;
    }

}