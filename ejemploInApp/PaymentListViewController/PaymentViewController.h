//
//  ViewController.h
//  ejemploInApp
//
//  Created by P2503-IMAC on 15/07/13.
//  Copyright (c) 2013 ejemplo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
@interface PaymentViewController : UIViewController<UICollectionViewDataSource,
                                               UICollectionViewDelegate,
                                               UICollectionViewDelegateFlowLayout,
                                                SKProductsRequestDelegate,
                                                SKPaymentTransactionObserver>
{
    NSArray *listId;
    NSArray *listSKProducts;
    SKProductsRequest *productsRequest;
    SKProduct *selectedProduct;

}

-(void)setProducts:(NSArray *)arrProducts;


@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UICollectionView *productCollection;
@property (weak, nonatomic) IBOutlet UILabel *detailsTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailDescription;
@property (weak, nonatomic) IBOutlet UIImageView *detailPhoto;
@property (weak, nonatomic) IBOutlet UIButton *detailBtnPurchase;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIView *detailContent;


- (IBAction)clickPurchase:(id)sender;
- (IBAction)clickClose:(id)sender;
- (IBAction)clickBack:(id)sender;
- (IBAction)clickReload:(id)sender;

@end
