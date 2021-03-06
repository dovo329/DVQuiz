//
//  BNRQuizViewController.m
//  Quiz2
//
//  Created by Douglas Voss on 3/20/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRQuizViewController.h"
#import "QuizOverViewController.h"
#import "DVQuizQuestion.h"
#import "QandADataBase.h"
#import <AudioToolbox/AudioToolbox.h>

@interface BNRQuizViewController ()
{
    SystemSoundID _buzzSound;
    SystemSoundID _yaySound;
}

@property (nonatomic) int answeredRight;
@property (nonatomic) int currentQuestionIndex;


/*@property (nonatomic, copy) NSArray *questions;
@property (nonatomic, copy) NSArray *answersA;
@property (nonatomic, copy) NSArray *answersB;*/
@property (nonatomic) NSMutableArray *quizQuestions;
//@property (nonatomic) DVQuizQuestion *quizQuestion;


@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
/*@property (nonatomic, weak) IBOutlet UILabel *answerALabel;
@property (nonatomic, weak) IBOutlet UILabel *answerBLabel;
@property (nonatomic, weak) IBOutlet UILabel *answerCLabel;
@property (nonatomic, weak) IBOutlet UILabel *answerDLabel;*/

@property(retain) IBOutlet UIButton *answerAButton;
@property(retain) IBOutlet UIButton *answerBButton;
@property(retain) IBOutlet UIButton *answerCButton;
@property(retain) IBOutlet UIButton *answerDButton;

@property (nonatomic, weak) IBOutlet UILabel *timerLabel;

@property (nonatomic) NSTimer *questionTimer;
@property (nonatomic) int questionTimerLeft;

//stall timer used for stalling display from when user presses an answer button to when it displays the next question.
@property (nonatomic) NSTimer *stallTimer;
@property (nonatomic) bool stallFlag;


@end

@implementation BNRQuizViewController

- (void)disableQuestionTimer
{
    if (self.questionTimer)
    {
        [self.questionTimer invalidate];
        self.questionTimer = nil;
    }
    self.questionTimerLeft=5;
}

- (void)displayScore:(int)numRight total:(int)tot
{
    if (tot != 0)
    {
        self.scoreLabel.text = [NSString stringWithFormat:@"%d/%d: %.0f%%", numRight, tot, 100*((float)self.answeredRight/(float)tot) ];
    } else {
        self.scoreLabel.text = [NSString stringWithFormat:@"0/0: 0%%"];
    }
}

- (void)displayScore
{
    if (self.currentQuestionIndex != 0)
    {
        self.scoreLabel.text = [NSString stringWithFormat:@"%d/%d: %.0f%%", self.answeredRight, self.currentQuestionIndex, 100*((float)self.answeredRight/(float)self.currentQuestionIndex) ];
    } else {
        self.scoreLabel.text = [NSString stringWithFormat:@"0/0: 0%%"];
    }
}

- (void)handleAnswer:(int)answerIndex
{
    if (!self.stallFlag) {
        NSLog(@"Not stalling for answerIndex %d", answerIndex);
        if (self.questionTimer)
        {
            [self.questionTimer invalidate];
            self.questionTimer = nil;
        }
        
        DVQuizQuestion *quizQuestion = self.quizQuestions[self.currentQuestionIndex];
        if (quizQuestion.correctIndex==answerIndex)
        {
            self.answeredRight++;
            self.statusLabel.text = @"A. Correct!";
            AudioServicesPlaySystemSound(_yaySound);
        } else {
            self.statusLabel.text = @"A. Wrong!";
            AudioServicesPlaySystemSound(_buzzSound);
        }
        
        // display updated score.  It's currentQuestionIndex + 1 because you just answered the question, but currentQuestionIndex hasn't been updated yet
        // it is updated in the nextQuestion method (though should it be?)
        [self displayScore:self.answeredRight total:(self.currentQuestionIndex+1)];
        
        [self stallForTime:1.0];
    } else {
        NSLog(@"Stalling");
    }
}

- (IBAction)answerA:(id)sender
{
    [self handleAnswer:0];
}

- (IBAction)answerB:(id)sender
{
    [self handleAnswer:1];
}

- (IBAction)answerC:(id)sender
{
    [self handleAnswer:2];
}

- (IBAction)answerD:(id)sender
{
    [self handleAnswer:3];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.answeredRight = 0;
    self.currentQuestionIndex = 0;
    [self displayCurrentQuestion];
    [self disableQuestionTimer];
    self.questionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(questionTimerHandler)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self disableQuestionTimer];
}

- (void)doQuizOver
{
    QuizOverViewController *overVC =
    [[QuizOverViewController alloc] init];
    
    overVC.answeredRight = self.answeredRight;
    overVC.answeredTotal = self.currentQuestionIndex;
    NSLog(@"self.answeredRight=%d; overVC.answeredRight=%d", self.answeredRight, overVC.answeredRight);
    NSLog(@"self.currentQuestionIndex=%d; overVC.answeredTotal=%d", self.currentQuestionIndex, overVC.answeredTotal);

    [self.navigationController pushViewController:overVC
                                         animated:YES];
}

- (void)nextQuestion
{
    self.statusLabel.text = @"";
    
    self.currentQuestionIndex++;
    if (self.currentQuestionIndex == [self.quizQuestions count])
    {
        [self doQuizOver];
        self.currentQuestionIndex = 0;
    }
    else
    {
        [self displayCurrentQuestion];
        
        [self disableQuestionTimer];
        self.questionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(questionTimerHandler)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void)displayCurrentQuestion
{
    DVQuizQuestion *quizQuestion = self.quizQuestions[self.currentQuestionIndex];
    

    self.questionLabel.text = quizQuestion.question;
    
    [self.answerAButton setTitle:[NSString stringWithFormat:@"A. %@", quizQuestion.answerA ] forState:UIControlStateNormal];
    [self.answerBButton setTitle:[NSString stringWithFormat:@"B. %@", quizQuestion.answerB ] forState:UIControlStateNormal];
    [self.answerCButton setTitle:[NSString stringWithFormat:@"C. %@", quizQuestion.answerC ] forState:UIControlStateNormal];
    [self.answerDButton setTitle:[NSString stringWithFormat:@"D. %@", quizQuestion.answerD ] forState:UIControlStateNormal];
    
    /*self.answerALabel.text  = [NSString stringWithFormat:@"A. %@", quizQuestion.answerA ];
    self.answerBLabel.text  = [NSString stringWithFormat:@"B. %@", quizQuestion.answerB ];
    self.answerCLabel.text  = [NSString stringWithFormat:@"C. %@", quizQuestion.answerC ];
     self.answerDLabel.text  = [NSString stringWithFormat:@"D. %@", quizQuestion.answerD ];*/
    
    self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.questionLabel.numberOfLines = 0;
    [self.questionLabel sizeToFit];
    
    /*self.answerALabel.lineBreakMode = NSLineBreakByWordWrapping;
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
    [self.answerDLabel sizeToFit];*/
    
    self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.statusLabel.numberOfLines = 0;
    [self.statusLabel sizeToFit];
    
    [self displayScore];
    self.timerLabel.text = [NSString stringWithFormat:@"%d sec", _questionTimerLeft];
    
}

-(void)questionTimerHandler
{
    NSLog(@"Entered questionTimerHandler");
    self.questionTimerLeft--;
    if (self.questionTimerLeft > 0)
    {
        self.timerLabel.text = [NSString stringWithFormat:@"%d sec", _questionTimerLeft];
        
    }
    else if (self.questionTimerLeft == 0)
    {
        self.timerLabel.text = @"Buzz!";
        [self stallForTime:1.0]; // don't respond to button presses after Buzz for 1.0 second
        AudioServicesPlaySystemSound(_buzzSound);
    }
    else // questionTimerLeft < 0
    {
        [self nextQuestion];
        self.questionTimerLeft = 5;
        self.timerLabel.text = [NSString stringWithFormat:@"%d sec", _questionTimerLeft];
    }
}


-(void)stallForTime:(float)stallTimeInSeconds
{
    [self disableQuestionTimer];
    if (self.stallTimer)
    {
        [self.stallTimer invalidate];
        self.stallTimer = nil;
    }
    self.stallFlag = true;
    self.stallTimer = [NSTimer scheduledTimerWithTimeInterval:stallTimeInSeconds
                                                       target:self
                                                     selector:@selector(stallTimerHandler)
                                                     userInfo:nil
                                                      repeats:NO];
}

-(void)stallTimerHandler
{
    NSLog(@"Entered stallTimerHandler");
    self.stallFlag = false;
    [self nextQuestion];
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        NSString *buzzSoundPath = [[NSBundle mainBundle]
                                pathForResource:@"buzz" ofType:@"wav"];
        NSURL *buzzSoundURL = [NSURL fileURLWithPath:buzzSoundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)buzzSoundURL, &_buzzSound);
        
        NSString *yaySoundPath = [[NSBundle mainBundle]
                                   pathForResource:@"yay" ofType:@"wav"];
        NSURL *yaySoundURL = [NSURL fileURLWithPath:yaySoundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)yaySoundURL, &_yaySound);
        
        _answeredRight = 0;
        _currentQuestionIndex = 0;
        self.quizQuestions = [NSMutableArray array];
        
        
        NSArray *QandAFromDataBase = [QandADataBase database].DVQuizQuestionInfos;
        for (QandADataBase *info in QandAFromDataBase) {
            //NSLog(@"%@", info);
            [self.quizQuestions addObject:info];
        }
        
        self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.questionLabel.numberOfLines = 0;
        [self.questionLabel sizeToFit];
        
        self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.statusLabel.numberOfLines = 0;
        [self.statusLabel sizeToFit];
        
        _questionTimerLeft=5;
        if (_questionTimer)
        {
            [_questionTimer invalidate];
            _questionTimer = nil;
        }
        _questionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(questionTimerHandler)
                                                        userInfo:nil
                                                         repeats:YES];
        _stallFlag = false;
        if (_stallTimer)
        {
            [_stallTimer invalidate];
            _stallTimer = nil;
        }
    }
    
    return self;
}


@end
