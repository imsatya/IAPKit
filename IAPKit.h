
//
//  IAPKit.h
//  Roman Mittermayr
//  http://www.twentypeople.com

/*
 
The MIT License (MIT)
Copyright (c) 2012 Roman Mittermayr / TwentyPeople Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void(^successCallback)(void);
typedef void(^errorCallback)(void);
typedef void(^successPurchaseCallback)(void);
typedef void(^errorPurchaseCallback)(void);
typedef void(^cancelledPurchaseCallback)(void);

@interface IAPKit : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
 
    @private
        NSSet  *productIdentifiers;
        successCallback callSuccess;
        errorCallback callError;
        successPurchaseCallback callPurchaseSuccess;
        errorPurchaseCallback callPurchaseError;
        cancelledPurchaseCallback callPurchaseCancelled;
    
    @public
        NSArray *products;
        NSMutableArray *purchasedProducts;
}
@property (nonatomic, strong) NSSet *productIdentifiers;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSMutableArray *purchasedProducts;
@property (nonatomic, copy) successCallback callSuccess;
@property (nonatomic, copy) errorCallback callError;
@property (nonatomic, copy) successPurchaseCallback callPurchaseSuccess;
@property (nonatomic, copy) errorPurchaseCallback callPurchaseError;
@property (nonatomic, copy) cancelledPurchaseCallback callPurchaseCancelled;

- (id)   initWithProductIds: (NSSet*) productIds;
- (void) loadProducts: (void (^)(void))onSuccess  
              onError:(void (^)(void))onError;
- (void) purchaseProduct:(NSString*) productId 
               onSuccess:(void (^)(void))onSuccess  
               onCancel:(void (^)(void))onCancel  
                 onError:(void (^)(void))onError;
- (BOOL) productAlreadyPurchased: (NSString *)productId;

- (void) addTransactionObserver;
- (void) removeTransactionObserver;



@end
