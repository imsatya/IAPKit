IAPKit
======

How to add it to your project:

* Get a copy of IAPKit.h and IAPKit.m and include it with your project
* Make sure you add StoreKit.framework to your project in Xcode

How to get started with In-App Purchases:

* Read Ray Wenderlich's article to get started with the product setup:
  http://www.raywenderlich.com/2797/introduction-to-in-app-purchases

### Example
  
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
   
If you want to initiate a purchase (after an IBAction, for instance), just call this:   

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