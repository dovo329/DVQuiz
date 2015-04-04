//
//  BNRQuizViewController.m
//  DVQuiz
//
//  Created by Douglas Voss on 3/20/15.
//

#import "BNRQuizViewController.h"
#import "QuizOverViewController.h"
#import "DVQuizQuestion.h"
#import "QandADataBase.h"
#import <AudioToolbox/AudioToolbox.h>
#import <Firebase/Firebase.h>

enum subjectEnumType {geography, science, trick};


@interface BNRQuizViewController ()
{
    SystemSoundID _buzzSound;
    SystemSoundID _yaySound;
}

@property (nonatomic) int answeredRight;
@property (nonatomic) int answeredTotal;
@property (nonatomic) int maxQuestions;

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;


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


@property (nonatomic) Firebase *geographyRef;
@property (nonatomic) Firebase *scienceRef;
@property (nonatomic) Firebase *trickRef;

@property (nonatomic) DVQuizQuestion *randomDVQuizQuestion;

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
    if (self.answeredTotal != 0)
    {
        self.scoreLabel.text = [NSString stringWithFormat:@"%d/%d: %.0f%%", self.answeredRight, self.answeredTotal, 100*((float)self.answeredRight/(float)self.answeredTotal) ];
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
        
        DVQuizQuestion *quizQuestion = self.randomDVQuizQuestion;
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
        [self displayScore:self.answeredRight total:(self.answeredTotal+1)];
        
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
    self.answeredTotal = 0;
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
    overVC.answeredTotal = self.answeredTotal;
    NSLog(@"self.answeredRight=%d; overVC.answeredRight=%d", self.answeredRight, overVC.answeredRight);
    NSLog(@"self.currentQuestionIndex=%d; overVC.answeredTotal=%d", self.answeredTotal, overVC.answeredTotal);

    [self.navigationController pushViewController:overVC
                                         animated:YES];
}

- (void)nextQuestion
{
    [self queryRandomQuestion];
    
    self.statusLabel.text = @"";
    
    self.answeredTotal++;
    if (self.answeredTotal >= self.maxQuestions)
    {
        [self doQuizOver];
        self.answeredTotal = 0;
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
    if (self.randomDVQuizQuestion)
    {
        DVQuizQuestion *quizQuestion = self.randomDVQuizQuestion;

        self.questionLabel.text = quizQuestion.question;
        
        [self.answerAButton setTitle:[NSString stringWithFormat:@"A. %@", quizQuestion.answerA ] forState:UIControlStateNormal];
        [self.answerBButton setTitle:[NSString stringWithFormat:@"B. %@", quizQuestion.answerB ] forState:UIControlStateNormal];
        [self.answerCButton setTitle:[NSString stringWithFormat:@"C. %@", quizQuestion.answerC ] forState:UIControlStateNormal];
        [self.answerDButton setTitle:[NSString stringWithFormat:@"D. %@", quizQuestion.answerD ] forState:UIControlStateNormal];
        
        self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.questionLabel.numberOfLines = 0;
        [self.questionLabel sizeToFit];
        
        self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.statusLabel.numberOfLines = 0;
        [self.statusLabel sizeToFit];
        
        [self displayScore];
        self.timerLabel.text = [NSString stringWithFormat:@"%d sec", _questionTimerLeft];
    } else {
        self.questionLabel.text = @"Querying from database";
        
        [self.answerAButton setTitle:@"" forState:UIControlStateNormal];
        [self.answerBButton setTitle:@"" forState:UIControlStateNormal];
        [self.answerCButton setTitle:@"" forState:UIControlStateNormal];
        [self.answerDButton setTitle:@"" forState:UIControlStateNormal];
        
        self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.questionLabel.numberOfLines = 0;
        [self.questionLabel sizeToFit];
        
        self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.statusLabel.numberOfLines = 0;
        [self.statusLabel sizeToFit];
        
        [self displayScore];
        self.timerLabel.text = @"";
    }
    
}

-(void)questionTimerHandler
{
    
    if (self.randomDVQuizQuestion) {
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
    //NSLog(@"Entered stallTimerHandler");
    self.stallFlag = false;
    [self nextQuestion];
}


- (void)queryRandomQuestion
{
    self.randomDVQuizQuestion = nil;
    enum subjectEnumType subjectType = ((int)(arc4random()%3));
    NSNumber *randomId = [NSNumber numberWithInt:((int)(arc4random() % 3))];
    
    Firebase *dbRef;
    switch (subjectType)
    {
        case 0: dbRef = self.geographyRef; break;
        case 1: dbRef = self.scienceRef; break;
        case 2: dbRef = self.trickRef; break;
        default: dbRef = self.geographyRef; break;
    }
    
    void(^dbBlock)(FDataSnapshot *snapshot);
    dbBlock = ^void(FDataSnapshot *snapshot) {
        self.randomDVQuizQuestion = nil;
        self.randomDVQuizQuestion = [[DVQuizQuestion alloc]     init:snapshot.value[@"question"]
                                                             answerA:snapshot.value[@"answerA"]
                                                             answerB:snapshot.value[@"answerB"]
                                                             answerC:snapshot.value[@"answerC"]
                                                             answerD:snapshot.value[@"answerD"]
                                                        correctIndex:[snapshot.value[@"correctIndex"] integerValue]];
        //NSLog(@"queriedRandomQuizQuestion == %@", self.randomDVQuizQuestion);
        [self displayCurrentQuestion];
    };
    [[
     [dbRef queryOrderedByChild:@"id"]
     queryEqualToValue:randomId]
     observeEventType:FEventTypeChildAdded withBlock:dbBlock];
}

/*
- (DVQuizQuestion *)getRandomQuestion
{
    enum subjectEnumType subjectType = ((int)(arc4random()%3));
    NSNumber *randomId = [NSNumber numberWithInt:((int)(arc4random() % 3))];
    __block DVQuizQuestion *returnQuestion;

    
    NSLog(@"checkpoint b");
    Firebase *dbRef;
    switch (subjectType)
    {
        case 0: dbRef = self.geographyRef; break;
        case 1: dbRef = self.scienceRef; break;
        case 2: dbRef = self.trickRef; break;
        default: dbRef = self.geographyRef; break;
    }
    
    void(^dbBlock)(FDataSnapshot *snapshot);
    dbBlock = ^void(FDataSnapshot *snapshot) {
        //NSLog(@"Checkit id: %@, question: %@, answerA: %@, answerB: %@, answerC: %@, answerD: %@", snapshot.value[@"id"], snapshot.value[@"question"], snapshot.value[@"answerA"], snapshot.value[@"answerB"], snapshot.value[@"answerC"], snapshot.value[@"answerD"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            returnQuestion = nil;
            returnQuestion = [[DVQuizQuestion alloc]     init:snapshot.value[@"question"]
                                                                 answerA:snapshot.value[@"answerA"]
                                                                 answerB:snapshot.value[@"answerB"]
                                                                 answerC:snapshot.value[@"answerC"]
                                                                 answerD:snapshot.value[@"answerD"]
                                                            correctIndex:[snapshot.value[@"correctIndex"] integerValue]];
            NSLog(@"checkpoint c");
        });
    };
    
    [[
     [dbRef queryOrderedByChild:@"id"]
     queryEqualToValue:randomId]
     observeEventType:FEventTypeChildAdded withBlock:dbBlock];
    

    NSLog(@"checkpoint d");
    //dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    //while (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW))
    //{
    //    [[NSRunLoop currentRunLoop] runMode:@"connectionRunLoopMode" beforeDate:[NSDate distantFuture]];
    //};
    //dispatch_release(sema);
    
    NSLog(@"after it is returnQuestion %@", returnQuestion);
    return returnQuestion;
}*/


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
        _answeredTotal = 0;
        _maxQuestions = 10;
        //_currentQuestionIndex = 0;
        //self.quizQuestions = [NSMutableArray array];
        
        
        /*NSArray *QandAFromDataBase = [QandADataBase database].DVQuizQuestionInfos;
        for (QandADataBase *info in QandAFromDataBase) {
            //NSLog(@"%@", info);
            [self.quizQuestions addObject:info];
        }*/

        _geographyRef = [[Firebase alloc] initWithUrl:@"https://dazzling-fire-8210.firebaseio.com/subjects/Geography"];
        _scienceRef = [[Firebase alloc] initWithUrl:@"https://dazzling-fire-8210.firebaseio.com/subjects/Science"];
        _trickRef = [[Firebase alloc] initWithUrl:@"https://dazzling-fire-8210.firebaseio.com/subjects/Trick"];
        
        [self queryRandomQuestion];

        //DVQuizQuestion *testQuestion = [self getRandomQuestion];
        
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
