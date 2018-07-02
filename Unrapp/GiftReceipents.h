//
//  GiftReceipents.h
//  Unrapp
//
//  Created by George R. Cain Jr. on 3/8/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GiftReceipents : NSObject
{
    NSMutableArray *selectedGiftReceipents;
    NSDictionary *selectedGiftToView;
    NSDictionary *selectedSentToView;
    UIImage *giftImage;
    BOOL isTakePicture;
    BOOL isChoosePicture;
    BOOL isGiftCard;
    NSString *giftMessage;
    UIImage *wrappingPaper;
    NSDictionary *GiftcardToView;
    NSString *giftValue;
}

+(GiftReceipents*) getInstance;

-(void)setSelectedGiftReceipents:(NSMutableArray*)selectedGiftReceipentsIn;
-(void)setSelectedGiftToView:(NSDictionary*)selectedGiftToViewIn;
-(void)setSelectedSentToView:(NSDictionary*)selectedSentToViewIn;
-(void)setGiftImage:(UIImage*)giftImageIn;
-(void)setIsTakePicture:(BOOL)isTakePictureIn;
-(void)setIsChoosePicture:(BOOL)isChoosePictureIn;
-(void)setGiftMessage:(NSString*)giftMessageIn;
-(void)setWrappingImage:(UIImage*)wrappingImageIn;
-(void)setSelectedGiftCard:(NSDictionary*)selectedGiftCard;
-(void)setIsGiftCard:(BOOL)isGiftCardIn;
-(void)setGiftValue:(NSString*)value;

-(NSMutableArray*)getSelectedGiftReceipents;
-(NSDictionary*)getSelectedGiftToView;
-(NSDictionary*)getSelectedSentToView;
-(UIImage*)getGiftImage;
-(BOOL)getIsTakePicture;
-(BOOL)getIsChoosePicture;
-(NSString*) getGiftMessage;
-(UIImage*)getWrappingImage;
-(NSDictionary*)getGiftCardToView;
-(BOOL)getIsGiftCard;
-(NSString*)getGiftValue;
-(NSString*)getGiftCardFee;
@end
