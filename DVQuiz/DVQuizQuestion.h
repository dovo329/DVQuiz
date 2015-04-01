//
//  DVQuizQuestion.h
//  Quiz2
//
//  Created by Douglas Voss on 3/25/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVQuizQuestion : NSObject

@property (nonatomic, readonly) NSMutableString *question;
@property (nonatomic, readonly) NSMutableString *answerA;
@property (nonatomic, readonly) NSMutableString *answerB;
@property (nonatomic, readonly) NSMutableString *answerC;
@property (nonatomic, readonly) NSMutableString *answerD;

/*typedef NS_ENUM(NSInteger, DVQuestionIndex) {
 A,
 B,
 C,
 D
 };
 @property (nonatomic) DVQuestionIndex correctIndex;*/
@property (nonatomic, readonly) NSInteger correctIndex;

- (id)init:(NSString *)question
   answerA:(NSString *)answerA
   answerB:(NSString *)answerB
   answerC:(NSString *)answerC
   answerD:(NSString *)answerD
correctIndex:(NSInteger)correctIndex;

-(NSString *)description;

@end
