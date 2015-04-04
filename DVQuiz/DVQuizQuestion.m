//
//  DVQuizQuestion.m
//  Quiz2
//
//  Created by Douglas Voss on 3/25/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "DVQuizQuestion.h"

@interface DVQuizQuestion()

    @property (nonatomic, readwrite) NSMutableString *question;
    @property (nonatomic, readwrite) NSMutableString *answerA;
    @property (nonatomic, readwrite) NSMutableString *answerB;
    @property (nonatomic, readwrite) NSMutableString *answerC;
    @property (nonatomic, readwrite) NSMutableString *answerD;

    /*typedef NS_ENUM(NSInteger, DVQuestionIndex) {
        A,
        B,
        C,
        D
    };
    @property (nonatomic) DVQuestionIndex correctIndex;*/
    @property (nonatomic, readwrite) NSInteger correctIndex;

@end

@implementation DVQuizQuestion

- (id)init:(NSString *)question
   answerA:(NSString *)answerA
   answerB:(NSString *)answerB
   answerC:(NSString *)answerC
   answerD:(NSString *)answerD
correctIndex:(NSInteger)correctIndex
{
    if (self = [super init]) {
        self.question=(NSMutableString *)question;
        self.answerA=(NSMutableString *)answerA;
        self.answerB=(NSMutableString *)answerB;
        self.answerC=(NSMutableString *)answerC;
        self.answerD=(NSMutableString *)answerD;
        self.correctIndex=correctIndex;
        return self;
    } else {
        return nil;
    }
}

- (id)init
{
    return [self init:@"Empty Question"
              answerA:@"Empty Answer A"
              answerB:@"Empty Answer B"
              answerC:@"Empty Answer C"
              answerD:@"Empty Answer D"
         correctIndex:0];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@\nA. %@\nB. %@\nC. %@\nD. %@\ncorrect: %ld", self.question, self.answerA, self.answerB, self.answerC, self.answerD, (long)self.correctIndex];
}

@end
