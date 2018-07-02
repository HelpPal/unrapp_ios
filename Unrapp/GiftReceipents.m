//
//  GiftReceipents.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 3/8/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "GiftReceipents.h"

@implementation GiftReceipents

static GiftReceipents *singletonInstance;

+ (GiftReceipents*) getInstance
{
    if (singletonInstance == nil)
    {
        singletonInstance = [[super alloc] init];
    }
    return singletonInstance;
}

#pragma mark - Setters

-(void)setSelectedGiftReceipents:(NSMutableArray*)selectedGiftReceipentsIn
{
    selectedGiftReceipents = selectedGiftReceipentsIn;
}

-(void)setSelectedGiftToView:(NSDictionary*)selectedGiftToViewIn
{
    selectedGiftToView = selectedGiftToViewIn;
}

-(void)setSelectedSentToView:(NSDictionary*)selectedSentToViewIn
{
    selectedSentToView = selectedSentToViewIn;
}

-(void)setGiftImage:(UIImage*)giftImageIn
{
    giftImage = giftImageIn;
}

-(void)setIsTakePicture:(BOOL)isTakePictureIn
{
    isTakePicture = isTakePictureIn;
}

-(void)setIsChoosePicture:(BOOL)isChoosePictureIn
{
    isChoosePicture = isChoosePictureIn;
}

-(void)setGiftMessage:(NSString*)giftMessageIn
{
    giftMessage = giftMessageIn;
}
-(void)setWrappingImage:(UIImage*)wrappingImageIn
{
    wrappingPaper = wrappingImageIn;
}
-(void)setSelectedGiftCard:(NSDictionary*)selectedGiftCard
{
    GiftcardToView = selectedGiftCard;
}
-(void)setIsGiftCard:(BOOL)isGiftCardIn
{
    isGiftCard = isGiftCardIn;
}
-(void)setGiftValue:(NSString *)value
{
    giftValue = value;
}
#pragma mark - Getters

-(NSMutableArray*)getSelectedGiftReceipents
{
    return selectedGiftReceipents;
}

-(NSDictionary*)getSelectedGiftToView
{
    return selectedGiftToView;
}

-(NSDictionary*)getSelectedSentToView
{
    return selectedSentToView;
}

-(UIImage*)getGiftImage
{
    return giftImage;
}

-(BOOL)getIsTakePicture
{
    return isTakePicture;
}

-(BOOL)getIsChoosePicture
{
    return isChoosePicture;
}

-(NSString*) getGiftMessage
{
    return giftMessage;
}
-(UIImage*)getWrappingImage
{
    return wrappingPaper;
}
-(NSDictionary*)getGiftCardToView
{
    return GiftcardToView;
}
-(BOOL)getIsGiftCard
{
    return isGiftCard;
}
-(NSString*)getGiftValue
{
    return giftValue;
}
-(NSString*)getGiftCardFee
{
    return @"1.00";
    /*
    int val = [[giftValue substringFromIndex:1] intValue];
    if (val > 260)
        return @"19.99";
    else if (val > 105)
        return @"9.99";
    else if (val > 53)
        return @"4.99";
    else if (val > 32)
        return @"2.99";
    else if (val > 11)
        return @"1.99";
    else
        return @"1.00";
     */
}
@end
