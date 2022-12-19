@IsTest
public class TestDataUtility {
    public static void setup() {
        Account account = new Account(Name='Test Account');
        insert account;

        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = account.Id
        );
        insert c;

        WebStore webStore = new WebStore(
            Name='Test Store', 
            DefaultLanguage='en_US');
        insert webStore;

        // Begin create Shipping and Billing Addresses
        ContactPointAddress shippingAddr = new ContactPointAddress(
            AddressType='Shipping', 
            IsDefault=true, 
            Name='Test Name', 
            ParentId=account.Id,
            Street='123 Shipping St',
            City='Test City',
            PostalCode='012345',
            Country='USA');
        insert shippingAddr;

        ContactPointAddress billingAddr = new ContactPointAddress(
            AddressType='Billing', 
            IsDefault=true, 
            Name='Test Name', 
            ParentId=account.Id,
            Street='123 Billing St',
            City='Test City',
            State='Test State',
            PostalCode='012345',
            Country='USA');
        insert billingAddr;
        
        // Begin create Cart and related records
        WebCart cart = new WebCart(
            Name='Cart', 
            WebStoreId=webStore.Id, 
            AccountId=account.Id,
            PoNumber = '12345',
            BillingStreet = billingAddr.Street,
            BillingCity = billingAddr.City,
            BillingPostalCode = billingAddr.PostalCode,
            BillingCountry = billingAddr.Country);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId=cart.Id, 
            Name='Default Delivery');
        insert cartDeliveryGroup;

        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = 'C0-D3',
            Description = 'Test Product Description',
            IsActive = true,
            Family = 'Test',
            StockKeepingUnit = 'Test-SKU');
        insert product;
        
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Product2Id = product.Id,
            Sku = product.StockKeepingUnit,
            SalesPrice=10.00, 
            Quantity=3.0, 
            Type='Product', 
            Name = product.Name, 
            CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;

        CartCheckoutSession ccs = new CartCheckoutSession(
            WebCartId = cart.Id,
            Name = cart.Id,
            State = 'Shipping',
            NextState = 'Cart To Order');
        insert ccs;

        Product2 deliveryProduct = new Product2(
            Name = 'Test Shipping',
            ProductCode = 'USPS_Test',
            IsActive = true);
        insert deliveryProduct;

        OrderDeliveryMethod odm = new OrderDeliveryMethod(
            Name = 'Test Shipping',
            Description = 'Test Shipping Description',
            ProductId = deliveryProduct.Id,
            Carrier = 'Test Carrier',
            ClassOfService = 'Test900',
            IsActive = true,
            ReferenceNumber = 'Test');
        insert odm;

        CartDeliveryGroup cdg = new CartDeliveryGroup(
            Name = 'Test Delivery',
            CartId = cart.Id,
            DeliveryMethodId = odm.Id);
        insert cdg;

        CartDeliveryGroupMethod cdgm = new CartDeliveryGroupMethod(
            Name = cdg.Name,
            DeliveryMethodId = odm.Id,
            CartCheckoutSessionId = ccs.Id,
            CartDeliveryGroupId = cdg.Id,
            WebCartId = cart.Id,
            ShippingFee = 11.99,
            ExternalProvider = odm.ClassOfService);
        insert cdgm;
        
/*        PaymentGatewayProvider pgp = [SELECT id from PaymentGatewayProvider LIMIT 1];
        NamedCredential nc = [SELECT id from NamedCredential LIMIT 1];
        PaymentGateway pg = new PaymentGateway(
            PaymentGatewayName  = 'Test Payment Gateway',
            PaymentGatewayProviderId = pgp.Id,
            MerchantCredentialId = nc.Id
        );
        insert pg;
        
        StoreIntegratedService sis =  new StoreIntegratedService(
            ServiceProviderType = 'Payment',
            StoreId = webStore.Id,
            Integration = pg.id
        );
        insert sis; */
        
    }
}