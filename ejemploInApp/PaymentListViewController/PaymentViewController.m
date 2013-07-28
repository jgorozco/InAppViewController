//
//  ViewController.m
//  ejemploInApp
//
//  Created by me on 15/07/13.
//  Copyright (c) 2013 ejemplo. All rights reserved.
//

#import "PaymentViewController.h"
#import <QuartzCore/QuartzCore.h>
#define IN_APP_DICT @"_DICT_INAPP"
#import "AppDelegate.h"
@interface PaymentViewController ()

@end

@implementation PaymentViewController

-(void)setProducts:(NSArray *)arrProducts{
    listId=arrProducts;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *nib=@"productCell";
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        nib=@"productCell_ipad";
    }
    
    [self.productCollection    registerNib:[UINib nibWithNibName:nib bundle:nil] forCellWithReuseIdentifier:@"productCellId"];
    NSSet *productos=[NSSet setWithArray:listId];
    
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productos];
    productsRequest.delegate = self;
    NSLog(@"INICIADA REQUEST");
    [productsRequest start];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self hideDetails];
    [self showLoading];
    [self configureViews];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)configureViews{
    [self.detailContent.layer setCornerRadius:20.0f];
    
    [self.detailContent.layer setBorderColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6].CGColor];
    [self.detailContent.layer setBorderWidth:0.5f];
    // drop shadow
    [self.detailContent.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.detailContent.layer setShadowOpacity:0.6];
    [self.detailContent.layer setShadowRadius:3.0];
    [self.detailContent.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)showLoading{
    [self.loadingView setHidden:NO];
}
-(void)hideLoading{
    [self.loadingView setHidden:YES];
    
}



-(void)hideDetails{
    [self.detailView setHidden:YES];
    selectedProduct=nil;
}

-(void)showDetailsWithProduct:(SKProduct *)p{
    [self.detailView setHidden:NO];
    selectedProduct=p;
    [self.detailsTitle setText:p.localizedTitle];
    [self.detailDescription setText:p.localizedDescription];
    NSString *image=[[p.productIdentifier componentsSeparatedByString:@"."] lastObject];
    NSLog(@"--->%@",image);
    image=[NSString stringWithFormat:@"_%@.png",image];
    [self.detailPhoto setImage:[UIImage imageNamed:image]];
    if ([self isPurchased:p.productIdentifier]){
        [self.detailBtnPurchase setHidden:YES];
        [self.detailBtnPurchase setEnabled:NO];
    }else{
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:p.priceLocale];
        NSString *currencyString = [formatter stringFromNumber:p.price];
        currencyString=[NSString stringWithFormat:@"     %@",currencyString];
        [self.detailBtnPurchase setTitle:currencyString forState:UIControlStateNormal];
        [self.detailBtnPurchase setEnabled:YES];
        [self.detailBtnPurchase setHidden:NO];
        
        
    }
    
}


- (IBAction)clickPurchase:(id)sender {
    if (selectedProduct){
        [self purchaseProduct:selectedProduct];
    }
}

- (IBAction)clickClose:(id)sender {
    [self.detailView setHidden:YES];
}



#pragma mark INAPP STAFF
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"response:%@",response);
    listSKProducts=response.products;
    NSLog(@"-->%@",listSKProducts);
    NSLog(@"INVALID:%@",response.invalidProductIdentifiers);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.productCollection reloadData];
        [self hideLoading];
    }];
}
-(void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"requestDidFinish__RECIBIDO::::%@",request);
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to connect with error: %@", [error localizedDescription]);
}
-(void)purchaseProduct:(SKProduct *)product{
    @try {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [self showLoading];
    }
    @catch (NSException *exception) {
        NSLog(@"ERR:%@",exception);
    }
    
}

- (void)provideContent:(NSString *)productIdentifier {
    
    NSLog(@"Toggling flag for: %@", productIdentifier);
    BOOL has=[[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
    if (has)
    {
        NSLog(@"Product already PURCHASED");
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //  [_purchasedProducts addObject:productIdentifier];
    
    //   [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchasedNotification object:productIdentifier];
    
}



- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        [self hideLoading];
        NSLog(@"TRANSACTION:%@",transaction);
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
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"completeTransaction...%@",transaction);
    [self hideDetails];
    //  [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"restoreTransaction...:::%@",transaction.payment.productIdentifier);
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [self hideDetails];
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *error=[[UIAlertView alloc]initWithTitle:@"Error"
                                                     message: transaction.error.localizedDescription
                                                    delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [error show];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"removedTransactions:::%@",transaction.description);
    }
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"restoreCompletedTransactionsFailedWithError:::%@",error.localizedDescription);
}
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@":::paymentQueueRestoreCompletedTransactionsFinished:::%@",queue.transactions);
}

#pragma mark COLLECTION STAFF
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {return [listSKProducts count];}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {return 1;}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        return CGSizeMake(250, 305);
    }else{
        return CGSizeMake(140, 180);
    }
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showDetailsWithProduct:[listSKProducts objectAtIndex:indexPath.row]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"productCellId" forIndexPath:indexPath];
    SKProduct *d=[listSKProducts objectAtIndex:indexPath.row];
    for (UIView *celdaContenido in [cell.contentView subviews]){
        switch (celdaContenido.tag) {
            case 0:
            {
                UILabel *lbl=(UILabel *)celdaContenido;
                [lbl setText:d.localizedTitle];
            }
                break;
            case 1:
            {
                UIImageView *iv=(UIImageView *)celdaContenido;
                NSString *image=[[d.productIdentifier componentsSeparatedByString:@"."] lastObject];
                image=[NSString stringWithFormat:@"_%@.png",image];
                [iv setImage:[UIImage imageNamed:image]];
            }
                break;
            case 3:
            {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [formatter setLocale:d.priceLocale];
                NSString *currencyString = [formatter stringFromNumber:d.price];
                UILabel *lbl=(UILabel *)celdaContenido;
                [lbl setText:currencyString];
                [lbl.layer setCornerRadius:5.0f];
                
                [lbl.layer setBorderColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6].CGColor];
                [lbl.layer setBorderWidth:0.5f];
                // drop shadow
                [lbl.layer setShadowColor:[UIColor blackColor].CGColor];
                [lbl.layer setShadowOpacity:0.6];
                [lbl.layer setShadowRadius:3.0];
                [lbl.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
                
                BOOL comprado=[self isPurchased:d.productIdentifier];//TODO sustituir por comprado o no;
                [lbl setHidden:comprado];
            }
                break;
            case 4:
            {
                UIImageView *iv=(UIImageView *)celdaContenido;
                BOOL comprado=[self isPurchased:d.productIdentifier];//TODO sustituir por comprado o no;
                [iv setHidden:!comprado];
                
            }
                break;
            default:
                break;
        }
    }
    [cell.layer setCornerRadius:10.0f];
    
    [cell.layer setBorderColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6].CGColor];
    [cell.layer setBorderWidth:0.5f];
    // drop shadow
    [cell.layer setShadowColor:[UIColor blackColor].CGColor];
    [cell.layer setShadowOpacity:0.6];
    [cell.layer setShadowRadius:3.0];
    [cell.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    return cell;
}

-(BOOL)isPurchased:(NSString *)identifier{
    
    BOOL is=[[NSUserDefaults standardUserDefaults] boolForKey:identifier];
    //   NSLog(@"Comprado:%@---%d",identifier,is);
    return is;
    
    /*    NSArray *arr=[[NSUserDefaults standardUserDefaults] objectForKey:IN_APP_DICT];
     if (!arr){
     [[NSUserDefaults standardUserDefaults]setObject:[[NSArray alloc]init] forKey:IN_APP_DICT];
     return NO;
     }else{
     for (NSString *ide in arr){
     if ([ide isEqualToString:identifier])return YES;
     }
     return NO;
     }*/
}




#pragma mark EXTRA FUNCTION STAFF

- (IBAction)clickBack:(id)sender {
    if ((self.navigationController)&&(self.navigationController.visibleViewController==self)){
        NSLog(@"Is navigation");
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.presentingViewController != nil) {
        NSLog(@"is presentmodal");
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
    
    
}
- (IBAction)clickReload:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
    [self setDetailContent:nil];
    [self setDetailContent:nil];
    [super viewDidUnload];
}
@end
