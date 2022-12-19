import { api, LightningElement } from 'lwc';

export default class HeaderContainer extends LightningElement {
    
    @api cardTitle;
    @api iconName;
    @api objectName;
    @api recordName;

    @api stepsName;
    @api currentStep;

    get pathList(){
        let pathListVal = [];
        this.stepsName.split(',').forEach((val, index) => {
            if((index + 1) < this.currentStep){
                pathListVal.push({label : val, index : index + 1, classVal : 'slds-path__item slds-is-complete'});
            }
            else if((index + 1) == this.currentStep){
                pathListVal.push({label : val, index : index + 1, classVal : 'slds-path__item slds-is-active'});
            }
            else if((index + 1) > this.currentStep){
                pathListVal.push({label : val, index : index + 1, classVal : 'slds-path__item slds-is-incomplete'});
            }
        });

        return pathListVal;
    }

    
}