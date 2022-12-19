import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getCartItems from '@salesforce/apex/ReviewPromotionDataServices.getCartItems';
import getCoupons from '@salesforce/apex/ReviewPromotionDataServices.getCoupons';
import applyCoupons from '@salesforce/apex/ReviewPromotionDataServices.applyCoupons';
import deleteCoupons from '@salesforce/apex/ReviewPromotionDataServices.deleteCoupons';

export default class ReviewPromotion extends LightningElement {
    
    @api recordId;
    @api webstoreId;
    @api searchResultFields;
    @api generatedCartId;
    @api searchResultFieldsLabel;

    cartCouponId;
    cartCouponCode;

    cartItems = null;
    cartSummary = {};
    
    isLoading = false;

    connectedCallback(){
        this.handleGetCartItems();
        this.handleGetCoupons();
    }

    handleCouponChange = (ele) => {
        this.cartCouponCode = ele.target.value;
    }

    get isCartCouponExist(){
        return this.cartCouponId!=null;
    }

    get columns(){
        let columnsArr = [];
        let fieldLabels = this.searchResultFieldsLabel.split(',');
        for(let i = 0; i < this.searchResultFields.split(',').length; i++){
            if(this.searchResultFields.split(',')[i] === 'id' || this.searchResultFields.split(',')[i] === 'Id')
                continue;
            
            columnsArr.push({label : fieldLabels[i], fieldName : this.searchResultFields.split(',')[i]});

            if(columnsArr.length > 2){
                break;
            }
        }
        columnsArr.push({label : 'Unit Price', fieldName : `unitPrice`});
        columnsArr.push({label : 'Quantity', fieldName : `quantity`});
        columnsArr.push({label : 'Tax ', fieldName : `totalTax`});
        columnsArr.push({label : 'Total ', fieldName : `total`});
        return columnsArr;
    }

    get lineItemArr(){
        let productArr = [];
        if(this.cartItems && this.cartItems.cartItems.length > 0){

            for(let i of this.cartItems.cartItems){
                let objData = {};
                objData.arr = [];
                let index = 0;
                for(let j  of this.searchResultFields.split(',')){
                    objData[j] = i.cartItem.productDetails.fields[j];
                    if(j !== 'Id'){
                        if(index === 0){
                            objData.arr.push({val : i.cartItem.productDetails.fields[j], key : j, promotionApplied : i.cartItem.totalAdjustmentAmount < 0 ? true : false });
                        }
                        else{
                            objData.arr.push({val : i.cartItem.productDetails.fields[j], key : j});
                        }
                        index ++;
                    }
                        
                    if(objData.arr.length > 2){
                        break;
                    }
                        
                }
                objData.arr.push({val : i.cartItem.salesPrice, key : 'salesPrice', promotionAppliedVal : i.cartItem.totalAdjustmentAmount < 0 ? true : false, newVal: parseFloat(i.cartItem.salesPrice) + parseFloat(i.cartItem.totalAdjustmentAmount / i.cartItem.quantity), isCurrency : true});
                objData.arr.push({val : i.cartItem.quantity, key : 'quantity',});
                objData.arr.push({val : i.cartItem.totalTax, key : 'totalTax', isCurrency : true});
                objData.arr.push({val : i.cartItem.totalPrice, key : 'total', isCurrency : true});

                objData['quantity'] = i.cartItem.quantity;
                objData['unitPrice'] = i.cartItem.salesPrice;
                objData['total'] = i.cartItem.totalPrice;
                objData['totalTax'] = i.cartItem.totalTax;
                objData['Id'] = i.cartItem.productId;
                productArr.push(objData);
            }
        }
        return productArr;
    }

    get isProductAdded(){
        return this.lineItemArr.length > 0;
    }

    handleGetCartItems =async () => {
        this.isLoading = true;
        this.cartItems = await getCartItems({
            webstoreId : this.webstoreId,
            effectiveAccountId : this.recordId,
            activeCartOrId : this.generatedCartId,
            productFieldsAPI : this.searchResultFields
        });

        this.cartSummary = this.cartItems.cartSummary;

        this.isLoading = false;
    }

    handleGetCoupons = async () => {
        this.isLoading = true;
        let coupons = await getCoupons({
            webstoreId : this.webstoreId,
            effectiveAccountId : this.recordId,
            activeCartOrId : this.generatedCartId,
        });
        this.isLoading = false;
        
        if(coupons.cartCoupons.coupons.length > 0){
            this.cartCouponCode = coupons.cartCoupons.coupons[0].couponCode;
            this.cartCouponId = coupons.cartCoupons.coupons[0].cartCouponId;
        }
        else{
            this.cartCouponCode = null;
            this.cartCouponId = null;
        }
        
    }

    handleApplyCoupon = async () => {
        try{
            this.isLoading = true;
            let res = await applyCoupons({
                webstoreId : this.webstoreId,
                effectiveAccountId : this.recordId,
                activeCartOrId : this.generatedCartId,
                cartCouponCode : this.cartCouponCode,
            });

            const event = new ShowToastEvent({
                title: 'Success!',
                variant : 'success',
                message:
                    'Coupon successfully applied!',
            });
            this.dispatchEvent(event);
            this.handleGetCartItems();
            this.handleGetCoupons();

        }
        catch(e){
            const event = new ShowToastEvent({
                title: 'Invalid Coupon!',
                variant : 'info',
                message:
                    'Coupon not valid for this cart!',
            });
            this.dispatchEvent(event);
        }
        this.isLoading = false;
    }

    handleDeleteCoupon = async() => {
        try{
            this.isLoading = true;
            await deleteCoupons({
                webstoreId : this.webstoreId,
                effectiveAccountId : this.recordId,
                activeCartOrId : this.generatedCartId,
                cartCouponId : this.cartCouponId,
            });

            const event = new ShowToastEvent({
                title: 'Success!',
                variant : 'success',
                message:
                    'Coupon removed!',
            });
            this.dispatchEvent(event);
            this.handleGetCartItems();
            this.handleGetCoupons();

        }
        catch(e){
            const event = new ShowToastEvent({
                title: 'Success!',
                variant : 'error',
                message:
                    'Something went wrong! Please contact system adminstrator.',
            });
            this.dispatchEvent(event);
        }
        this.isLoading = false;
    }
    

}