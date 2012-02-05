
//
//  IAPKit.m
//  Roman Mittermayr
//  http://www.twentypeople.com

/*
 
 The MIT License (MIT)
 Copyright (c) 2012 Roman Mittermayr / TwentyPeople Ltd.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "IAPKit.h"


@implementation IAPKit

@synthesize productIdentifiers, products, purchasedProducts;
@synthesize callSuccess, callError;
@synthesize callPurchaseError, callPurchaseSuccess, callPurchaseCancelled;

SKProductsRequest *request;
SKMutablePayment *payment;

- (id) init {
    self = [super init];
    if (self != nil) {
        productIdentifiers = [[NSSet alloc] init];
        purchasedProducts = [[NSMutableArray alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (id) initWithProductIds: (NSSet*) productIds {
    
    id instance = [self init];
    productIdentifiers = productIds;
    

    // Check for previously purchased products
    for (NSString * productIdentifier in productIds) {
        BOOL productPurchased = 
            [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
        if (productPurchased) {
            [purchasedProducts addObject:productIdentifier];
        }
    }    
    
    return instance;
}

- (void) loadProducts: (void (^)(void))onSuccess  
              onError:(void (^)(void))onError {
    
    callSuccess = onSuccess;    
    callError = onError;
    
    request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    [request start];
}

- (void) purchaseProduct:(NSString*) productId 
               onSuccess:(void (^)(void))onSuccess  
                onCancel:(void (^)(void))onCancel  
                 onError:(void (^)(void))onError {
    
    callPurchaseSuccess = onSuccess;    
    callPurchaseError = onError;
    callPurchaseCancelled = onCancel;
    
    payment = [[SKMutablePayment alloc] init];
    payment.productIdentifier = productId;
    payment.quantity = 1;

    [[SKPaymentQueue defaultQueue] addPayment:payment];

}


- (BOOL) productAlreadyPurchased: (NSString *)productId {
    return ([purchasedProducts containsObject:productId]);
}




/* DELEGATES */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    if (callSuccess!=nil) callSuccess();
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    //NSLog(@"IAPKit/StoreKit: didFailWithError: %@", error);    
    if (callError!=nil) callError();
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {    
    // TODO: Allow custom function to record the transaction on the server  
}

- (void)provideContent:(NSString *)productIdentifier {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [purchasedProducts addObject:productIdentifier];    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {    
        
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

    if (callPurchaseSuccess!=nil) callPurchaseSuccess();

}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    //if (transaction.error.code != SKErrorPaymentCancelled)
    //{
        //NSLog(@"IAPKit/StoreKit: failedTransaction:%@", transaction.error.localizedDescription);
    //}
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if (transaction.error.code == SKErrorPaymentCancelled) {
        if (callPurchaseCancelled!=nil) callPurchaseCancelled();
    } else {
        if (callPurchaseError!=nil) callPurchaseError();
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue 
{
    NSLog(@"Restored");
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"Restored Error: %@", error);
}



@end
