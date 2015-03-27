//
//  BNRQuizViewController.m
//  Quiz2
//
//  Created by Douglas Voss on 3/20/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRQuizViewController.h"
#import "DVQuizQuestion.h"

@interface BNRQuizViewController ()

@property (nonatomic) int answeredRight;
@property (nonatomic) int answeredTotal;

@property (nonatomic) int currentQuestionIndex;

/*@property (nonatomic, copy) NSArray *questions;
@property (nonatomic, copy) NSArray *answersA;
@property (nonatomic, copy) NSArray *answersB;*/
@property (nonatomic) NSMutableArray *quizQuestions;
//@property (nonatomic) DVQuizQuestion *quizQuestion;


@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *answerALabel;
@property (nonatomic, weak) IBOutlet UILabel *answerBLabel;
@property (nonatomic, weak) IBOutlet UILabel *answerCLabel;
@property (nonatomic, weak) IBOutlet UILabel *answerDLabel;
@property (nonatomic, weak) IBOutlet UILabel *timerLabel;

@property (nonatomic) int timeLeft;

@property (nonatomic) NSTimer *questionTimer;

@end

@implementation BNRQuizViewController

- (void)displayScore
{
    if (_answeredTotal != 0)
    {
        self.scoreLabel.text = [NSString stringWithFormat:@"%d/%d: %.0f%%", _answeredRight, _answeredTotal, 100*((float)_answeredRight/(float)_answeredTotal) ];
    } else {
        self.scoreLabel.text = [NSString stringWithFormat:@"0: 0%%"];
    }
}

- (IBAction)answerA:(id)sender
{
    DVQuizQuestion *quizQuestion = self.quizQuestions[_currentQuestionIndex];
    if (quizQuestion.correctIndex==0)
    {
        self.statusLabel.text = @"A. Correct!";
        self.answeredRight++;
    } else {
        self.statusLabel.text = @"A. Wrong!";
    }
    
    _answeredTotal++;
    [self displayCurrentQuestion];
    [self.questionTimer invalidate];
    self.questionTimer = nil;
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(nextQuestion)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)answerB:(id)sender
{
    DVQuizQuestion *quizQuestion = self.quizQuestions[_currentQuestionIndex];
    if (quizQuestion.correctIndex==1)
    {
        self.statusLabel.text = @"B. Correct!";
        self.answeredRight++;
    } else {
        self.statusLabel.text = @"B. Wrong!";
    }
    
    self.answeredTotal++;
    [self displayCurrentQuestion];
    [self.questionTimer invalidate];
    self.questionTimer = nil;
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(nextQuestion)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)answerC:(id)sender
{
    DVQuizQuestion *quizQuestion = self.quizQuestions[_currentQuestionIndex];
    if (quizQuestion.correctIndex==2)
    {
        self.statusLabel.text = @"C. Correct!";
        _answeredRight++;
    } else {
        self.statusLabel.text = @"C. Wrong!";
    }
    
    self.answeredTotal++;
    [self displayCurrentQuestion];
    [self.questionTimer invalidate];
    self.questionTimer = nil;
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(nextQuestion)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)answerD:(id)sender
{
    DVQuizQuestion *quizQuestion = self.quizQuestions[_currentQuestionIndex];
    if (quizQuestion.correctIndex==3)
    {
        self.statusLabel.text = @"D. Correct!";
        self.answeredRight++;
    } else {
        self.statusLabel.text = @"D. Wrong!";
    }
    
    self.answeredTotal++;
    [self displayCurrentQuestion];
    [self.questionTimer invalidate];
    self.questionTimer = nil;
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(nextQuestion)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)doQuizOver
{
    self.questionLabel.text = @"The Quiz is Over!";
    self.answerALabel.text  = @"Your final score is above";
    self.answerBLabel.text  = @"";
    self.answerCLabel.text  = @"";
    self.answerDLabel.text  = @"";
    [self displayScore];
    [self.questionTimer invalidate];
}

- (void)nextQuestion
{
    self.statusLabel.text = @"";
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == [self.quizQuestions count])
    {
        self.currentQuestionIndex = 0;
        [self doQuizOver];
    }
    else
    {
        [self displayCurrentQuestion];
        if (self.questionTimer) {
            self.questionTimer = nil;
        }
        _questionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(timerHandler)
                                                        userInfo:nil
                                                         repeats:YES];
    }
    _timeLeft=5;
}

- (void)displayCurrentQuestion
{
    DVQuizQuestion *quizQuestion = self.quizQuestions[_currentQuestionIndex];
    
    
    
    self.questionLabel.text = quizQuestion.question;
    self.answerALabel.text  = [NSString stringWithFormat:@"A. %@", quizQuestion.answerA ];
    self.answerBLabel.text  = [NSString stringWithFormat:@"B. %@", quizQuestion.answerB ];
    self.answerCLabel.text  = [NSString stringWithFormat:@"C. %@", quizQuestion.answerC ];
    self.answerDLabel.text  = [NSString stringWithFormat:@"D. %@", quizQuestion.answerD ];
    
    self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.questionLabel.numberOfLines = 0;
    [self.questionLabel sizeToFit];
    
    self.answerALabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.answerALabel.numberOfLines = 0;
    [self.answerALabel sizeToFit];
    
    self.answerBLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.answerBLabel.numberOfLines = 0;
    [self.answerBLabel sizeToFit];
    
    self.answerCLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.answerCLabel.numberOfLines = 0;
    [self.answerCLabel sizeToFit];
    
    self.answerDLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.answerDLabel.numberOfLines = 0;
    [self.answerDLabel sizeToFit];
    
    self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.statusLabel.numberOfLines = 0;
    [self.statusLabel sizeToFit];
    
    [self displayScore];
}

-(void)timerHandler
{
    if (_timeLeft > 0)
    {
        self.timerLabel.text = [NSString stringWithFormat:@"%d sec", _timeLeft];
        _timeLeft--;
    }
    else if (_timeLeft == 0)
    {
        self.timerLabel.text = @"Buzz!";
        _timeLeft--;
    }
    else
    {
        _timeLeft = 5;
        self.timerLabel.text = [NSString stringWithFormat:@"%d sec", _timeLeft];
        _timeLeft--;
        
        self.answeredTotal++;
        [self nextQuestion];
    }
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _answeredRight = 0;
        _answeredTotal = 0;
        self.quizQuestions = [NSMutableArray array];
        
        DVQuizQuestion *tempQuestion1 = [[DVQuizQuestion alloc]
                                        init:@"What is the capital of Utah?"
                                        answerA:@"Ogden"
                                        answerB:@"Salt Lake City"
                                        answerC:@"Provo"
                                        answerD:@"Orem"
                                        correctIndex:1];
        [self.quizQuestions addObject:tempQuestion1];
        
        tempQuestion1 = nil;
        tempQuestion1 = [[DVQuizQuestion alloc]
                                        init:@"What is the capital of California?"
                                        answerA:@"Sacramento"
                                        answerB:@"Los Angeles"
                                        answerC:@"Bakersfield"
                                        answerD:@"Hesperia"
                                        correctIndex:0];
        [self.quizQuestions addObject:tempQuestion1];
        
        tempQuestion1 = nil;
        tempQuestion1 = [[DVQuizQuestion alloc]
                         init:@"Who was the inventor of the Hokey Pokey song and dance?"
                         answerA:@"Jimmy Kennedy"
                         answerB:@"Robert Degan and Joe Brier"
                         answerC:@"Al Tabor"
                         answerD:@"No one knows"
                         correctIndex:3];
        [self.quizQuestions addObject:tempQuestion1];
        
        tempQuestion1 = nil;
        tempQuestion1 = [[DVQuizQuestion alloc]
                         init:@"What, is your favorite color?"
                         answerA:@"Blue... No, Red!"
                         answerB:@"Clear"
                         answerC:@"Fuschia"
                         answerD:@"Burnt Umber"
                         correctIndex:2];
        [self.quizQuestions addObject:tempQuestion1];
        
        
        //NSLog(@"tempQuestion1: %@\n\n", tempQuestion1);
        //NSLog(@"tempQuestion2: %@\n\n", tempQuestion2);
        
        //NSLog(@"[self.quizQuestions count]=%d", [self.quizQuestions count]);
        /*for (int i=0; i<[self.quizQuestions count]; i++) {
            NSLog(@"self.quizQuestions[%d]: %@\n\n", i, self.quizQuestions[i]);
        }*/
        
        //NSLog(@"self.quizQuestions[0]: %@\n\n", self.quizQuestions[0]);
        //NSLog(@"self.quizQuestions[1]: %@\n\n", self.quizQuestions[1]);
        
        self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.questionLabel.numberOfLines = 0;
        [self.questionLabel sizeToFit];
        
        self.answerALabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.answerALabel.numberOfLines = 0;
        [self.answerALabel sizeToFit];

        self.answerBLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.answerBLabel.numberOfLines = 0;
        [self.answerBLabel sizeToFit];
 
        self.answerCLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.answerCLabel.numberOfLines = 0;
        [self.answerCLabel sizeToFit];
        
        self.answerDLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.answerDLabel.numberOfLines = 0;
        [self.answerDLabel sizeToFit];
        
        self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.statusLabel.numberOfLines = 0;
        [self.statusLabel sizeToFit];
        
        _timeLeft=5;
        _questionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(timerHandler)
                                                        userInfo:nil
                                                         repeats:YES];
        
    }
    
    return self;
}


@end
