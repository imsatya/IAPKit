IAPKit
======

**How to add it to your project:**

* Get a copy of IAPKit.h and IAPKit.m and include it with your project
* Make sure you add StoreKit.framework to your project in Xcode

**How to get started with In-App Purchases:**

* Always test on your iPhone/iPad, IAPs do not work on the Simulator!
* Read Ray Wenderlich's article to get started with the product setup:
  http://www.raywenderlich.com/2797/introduction-to-in-app-purchases

**How this typically goes down**

* You have added everything to your project
* You have successfully setup your new app ID on iTunes Connect
* You have added the products, with a screenshot and a unique ID (product identifier)
* You typically have a dedicated ViewController responsible for dealing with purchases / products
* This ViewController shows your products, has a price label, buy button and fires actions
* Include "IAPKit.h" in this ViewController
* Make the **IAPKit *store** object a global object, it will fail if you only instantiate/store it within viewDidLoad
* Add the initialization below to your viewWillAppear and/or launch it in a separate thread
* Route an IBAction for your buy button and fire the code further down (purchase example)
* Done

### Setup: Declare the object in your implementation

```ObjC
   IAPKit *store;
```

### Example 1: Initialization
  
```ObjC
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 @"com.twentypeople.randomapp.cymbal",
                                 @"com.twentypeople.randomapp.fanfare",
                                 @"com.twentypeople.randomapp.bell",
                                 nil];

    // Initialize the IAPKit Object
    store = [[IAPKit alloc] initWithProductIds:productIdentifiers];

    // Start off by syncing your products with the iTunes Store 
    [store loadProducts:^{
    
        NSLog(@"Success! We received a product list from Apple.");        
        NSLog(@"Example Product: %@ has price %@", 
          ((SKProduct*)[store.products objectAtIndex:0]).localizedTitle,
          ((SKProduct*)[store.products objectAtIndex:0]).price
        );
        
        // If you want, you can also check if some of these products 
        // were previously purchased by your user
        if ([store productAlreadyPurchased:@"com.twentypeople.randomapp.bell"]) {
            NSLog(@"already purchased!");
        }
        
    } onError:^{
        NSLog(@"There was an error connecting to the iTunes Store");
    }];
```   

### Example 2: Making a purchase

```ObjC
    // Initiate Purchase
    [store purchaseProduct:@"com.twentypeople.randomapp.bell" 
        onSuccess:^{
            NSLog(@"Purchase complete");
        } 
        onCancel:^{
            NSLog(@"Purchase cancelled");
        }
        onError:^{
            NSLog(@"Purchase error");
        }
     ];
```