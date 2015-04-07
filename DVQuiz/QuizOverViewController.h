//
//  QuizOverViewController.h
//  DVQuiz
//
//  Created by Douglas Voss on 3/31/15.
//

#import <UIKit/UIKit.h>

@interface QuizOverViewController : UIViewController

@property (nonatomic, readwrite) int answeredRight;
@property (nonatomic, readwrite) int answeredTotal;

-(NSUInteger)supportedInterfaceOrientations;

@end
