//
//  QuizViewController.m
//  DVQuiz
//

#import "QuizViewController.h"
#import "QuizOverViewController.h"
#import "DVQuizQuestion.h"
#import "QandADataBase.h"
#import <AudioToolbox/AudioToolbox.h>
#import <Firebase/Firebase.h>
#import "CoolButton.h"

enum subjectEnumType {geography, science, trick};


@interface QuizViewController ()
{
    SystemSoundID _buzzSound;
    SystemSoundID _yaySound;
}

@property (nonatomic) int answeredRight;
@property (nonatomic) int answeredTotal;
@property (nonatomic) int maxQuestions;

@property (nonatomic) UILabel *questionLabel;
@property (nonatomic) UILabel *statusLabel;
@property (nonatomic) UILabel *scoreLabel;
@property (nonatomic) UILabel *timerLabel;


@property(retain) CoolButton *answerAButton;
@property(retain) CoolButton *answerBButton;
@property(retain) CoolButton *answerCButton;
@property(retain) CoolButton *answerDButton;

@property (nonatomic) NSTimer *questionTimer;
@property (nonatomic) int questionTimerLeft;

//stall timer used for stalling display from when user presses an answer button to when it displays the next question.
@property (nonatomic) NSTimer *stallTimer;
@property (nonatomic) bool stallFlag;


@property (nonatomic) Firebase *geographyRef;
@property (nonatomic) Firebase *scienceRef;
@property (nonatomic) Firebase *trickRef;

@property (nonatomic) DVQuizQuestion *randomDVQuizQuestion;

/*@property (nonatomic) NSMutableArray *alreadyAskedQuestions;

struct trackedQuestionStruct
{
    __unsafe_unretained NSString *subject;
    int   questionId;
};

@property (nonatomic) struct trackedQuestionStruct trackedQuestion;*/

/*
@property (nonatomic) NSMutableArray *askedQuestionIdPerSubject;
@property (nonatomic) NSMutableArray *askedQuestionId;
*/

@end


@implementation QuizViewController

/*- (void)printFrame:(CGRect)frame
{
    NSLog(@"frame origin.x=%f origin.y=%f size.width=%f, size.height=%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}*/

- (NSString *)truncateString:(NSString *)stringToTruncate
{
    if ([stringToTruncate length] > 76)
        stringToTruncate = [[stringToTruncate substringToIndex:76] stringByAppendingString:@"..."];
    
    return  stringToTruncate;
}


- (void)redoFrames
{
    int statusBarOffsetInPoints = 20.0;
    int standardRectLeftOffset = self.view.frame.size.width/16.0;
    int standardRectWidth = self.view.frame.size.width*(14.0/16.0);
    int standardRectHeight = (self.view.frame.size.height-statusBarOffsetInPoints)*(1.0/16.0);
    
    int currentX = standardRectLeftOffset;
    int currentY = statusBarOffsetInPoints;
    
    self.questionLabel.frame = CGRectMake(currentX, currentY, standardRectWidth, standardRectHeight*3.0);
    
    currentY += (standardRectHeight*3.0);
    
    //[self printFrame:self.questionLabel.frame];
    
    self.statusLabel.frame = CGRectMake(currentX, currentY, standardRectWidth/3.0, standardRectHeight);
    currentX += standardRectWidth/3.0;

    self.scoreLabel.frame = CGRectMake(currentX, currentY, standardRectWidth/3.0, standardRectHeight);
    currentX += standardRectWidth/3.0;
    
    self.timerLabel.frame = CGRectMake(currentX, currentY, standardRectWidth/3.0, standardRectHeight);
    currentX = standardRectLeftOffset;
    currentY += standardRectHeight;
    
    self.answerAButton.frame = CGRectMake(currentX, currentY, standardRectWidth, standardRectHeight*3.0);
    currentY += (3.0*standardRectHeight);
    
    self.answerBButton.frame = CGRectMake(currentX, currentY, standardRectWidth, standardRectHeight*3.0);
    currentY += (3.0*standardRectHeight);
    
    self.answerCButton.frame = CGRectMake(currentX, currentY, standardRectWidth, standardRectHeight*3.0);
    currentY += (3.0*standardRectHeight);
    
    self.answerDButton.frame = CGRectMake(currentX, currentY, standardRectWidth, standardRectHeight*3.0);
    currentY += (3.0*standardRectHeight);
    
    [self.questionLabel setNeedsDisplay];
    [self.statusLabel setNeedsDisplay];
    [self.scoreLabel setNeedsDisplay];
    [self.timerLabel setNeedsDisplay];
    [self.answerAButton setNeedsDisplay];
    [self.answerBButton setNeedsDisplay];
    [self.answerCButton setNeedsDisplay];
    [self.answerDButton setNeedsDisplay];

}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


-(void)OrientationDidChange:(NSNotification*)notification
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    
    [self redoFrames];
    NSLog(@"Orientation changed!");
    
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
    }
}


- (UILabel *)makeLabelWithText:(NSString *)text backgroundColor:(UIColor *)backgroundColor
{
    UILabel *label = [[UILabel alloc] init];
    
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;  //(for iOS 6.0)
    label.backgroundColor = backgroundColor;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    return label;
}


- (UIButton *)makeButtonWithHandler:(SEL)selector text:(NSString *)text backgroundColor:(UIColor *)backgroundColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundColor:backgroundColor];
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    return button;
}




- (void)handleAnswer:(int)answerIndex
{
    if (!self.stallFlag && self.randomDVQuizQuestion) {
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
            self.statusLabel.text = @"Correct!";
            AudioServicesPlaySystemSound(_yaySound);
        } else {
            self.statusLabel.text = @"Wrong!";
            AudioServicesPlaySystemSound(_buzzSound);
        }
        
        self.answeredTotal++;
        [self displayScore:self.answeredRight total:(self.answeredTotal)];
        
        [self stallForTime:1.0];
    } else {
        NSLog(@"Stalling");
    }
}

- (void)answerAHandler:(UIButton *)sender
{
    [self handleAnswer:0];
}

- (void)answerBHandler:(UIButton *)sender
{
    [self handleAnswer:1];
}

- (void)answerCHandler:(UIButton *)sender
{
    [self handleAnswer:2];
}

- (void)answerDHandler:(UIButton *)sender
{
    [self handleAnswer:3];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self) {
        _questionLabel = [self makeLabelWithText:@"Blank Question" backgroundColor:[UIColor redColor]];
        _statusLabel = [self makeLabelWithText:@"Blank Status" backgroundColor:[UIColor orangeColor]];
        _scoreLabel = [self makeLabelWithText:@"Blank Score" backgroundColor:[UIColor yellowColor]];
        _timerLabel = [self makeLabelWithText:@"Blank Timer" backgroundColor:[UIColor greenColor]];
        
        _answerAButton = [CoolButton makeCoolButtonWithHandler:self selector:@selector(answerAHandler:) text:@"Blank AnswerA" color:[UIColor yellowColor]];
        _answerBButton = [CoolButton makeCoolButtonWithHandler:self selector:@selector(answerBHandler:) text:@"Blank AnswerB" color:[UIColor greenColor]];
        _answerCButton = [CoolButton makeCoolButtonWithHandler:self selector:@selector(answerCHandler:) text:@"Blank AnswerC" color:[UIColor blueColor]];
        _answerDButton = [CoolButton makeCoolButtonWithHandler:self selector:@selector(answerDHandler:) text:@"Blank AnswerD" color:[UIColor purpleColor]];

        [self.view addSubview:self.questionLabel];
        [self.view addSubview:self.statusLabel];
        [self.view addSubview:self.scoreLabel];
        [self.view addSubview:self.timerLabel];
        [self.view addSubview:self.answerAButton];
        [self.view addSubview:self.answerBButton];
        [self.view addSubview:self.answerCButton];
        [self.view addSubview:self.answerDButton];
        
        [self redoFrames];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        
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
        
        /*
         _askedQuestionIdPerSubject = [[NSMutableArray alloc] initWithCapacity:3];
         _askedQuestionId = [[NSMutableArray alloc] init];
         */
        [self resetAlreadyAsked];
        
        //DVQuizQuestion *testQuestion = [self getRandomQuestion];
        
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
}

bool alreadyAsked[3][4];

- (void)resetAlreadyAsked
{
    for (int r=0; r<3; r++) {
        for (int c=0; c<4; c++) {
            alreadyAsked[r][c] = false;
        }
    }
}


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


- (void)viewWillAppear:(BOOL)animated
{
    self.answeredRight = 0;
    self.answeredTotal = 0;
    [self queryRandomQuestion];
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
    [self resetAlreadyAsked];
    [self disableQuestionTimer];
    
    QuizOverViewController *overVC =
    [[QuizOverViewController alloc] init];
    
    overVC.answeredRight = self.answeredRight;
    overVC.answeredTotal = self.answeredTotal;
    NSLog(@"self.answeredRight=%d; overVC.answeredRight=%d", self.answeredRight, overVC.answeredRight);
    NSLog(@"self.currentQuestionIndex=%d; overVC.answeredTotal=%d", self.answeredTotal, overVC.answeredTotal);

    [self.navigationController pushViewController:overVC
                                         animated:YES];
    
    self.answeredRight = 0;
    self.answeredTotal = 0;
}

- (void)nextQuestion
{
    /*[self.askedQuestionIdPerSubject[0] ];
    _askedQuestionId = [[NSMutableArray alloc] init];*/
    
    [self queryRandomQuestion];
    
    self.statusLabel.text = @"";
    
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
        
        [self.answerAButton setTitle:[NSString stringWithFormat:@"A. %@", [self truncateString:quizQuestion.answerA]] forState:UIControlStateNormal];
        [self.answerBButton setTitle:[NSString stringWithFormat:@"B. %@", [self truncateString:quizQuestion.answerB]] forState:UIControlStateNormal];
        [self.answerCButton setTitle:[NSString stringWithFormat:@"C. %@", [self truncateString:quizQuestion.answerC]] forState:UIControlStateNormal];
        [self.answerDButton setTitle:[NSString stringWithFormat:@"D. %@", [self truncateString:quizQuestion.answerD]] forState:UIControlStateNormal];
        
        [self displayScore];
        self.timerLabel.text = [NSString stringWithFormat:@"%d sec", _questionTimerLeft];
    } else {
        self.questionLabel.text = @"Querying from database";
        
        [self.answerAButton setTitle:@"" forState:UIControlStateNormal];
        [self.answerBButton setTitle:@"" forState:UIControlStateNormal];
        [self.answerCButton setTitle:@"" forState:UIControlStateNormal];
        [self.answerDButton setTitle:@"" forState:UIControlStateNormal];
        
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
            self.answeredTotal++;
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


- (void)printAlreadyAsked
{
    for (int r=0; r<3; r++) {
        for (int c=0; c<3; c++) {
            NSLog(@"alreadyAsked[%d][%d]==%d", r, c, alreadyAsked[r][c]);
        }
    }
}

- (bool)haveAllBeenAsked
{
    bool allAsked = true;
    for (int r=0; r<3; r++) {
        for (int c=0; c<3; c++) {
            //NSLog(@"alreadyAsked[%d][%d]==%d", r, c, alreadyAsked[r][c]);
            if (!alreadyAsked[r][c]) {
                allAsked = false;
            }
        }
    }
    return allAsked;
}


- (void)queryRandomQuestion
{
    self.randomDVQuizQuestion = nil;
    enum subjectEnumType subjectType = ((int)(arc4random()%3));
    int randomIdInt = ((int)(arc4random() % 4));
    NSNumber *randomId = [NSNumber numberWithInt:randomIdInt];
    
    
    NSLog(@"totalQuestionsAsked = %d", self.answeredTotal);
    [self printAlreadyAsked];
    
    bool allAsked = [self haveAllBeenAsked];
    NSLog(@"allAsked=%d", allAsked);
    
    if (allAsked)
    {
        [self doQuizOver];
        self.answeredTotal = 0;
    } else {
        
        while (alreadyAsked[subjectType][randomIdInt])
        {
            NSLog(@"random selection was already asked for alreadyAsked[%d][%d]==%d", subjectType, randomIdInt, alreadyAsked[subjectType][randomIdInt]);
            [self printAlreadyAsked];
            randomIdInt++;
            if (randomIdInt >= 4) {
                subjectType++;
                if (subjectType >= 3) {
                    subjectType = 0;
                }
                randomIdInt = 0;
            }
            randomId = [NSNumber numberWithInt:randomIdInt];
            NSLog(@"new random selection is alreadyAsked[%d][%d]==%d", subjectType, randomIdInt, alreadyAsked[subjectType][randomIdInt]);
        }
       
        subjectType = 2;
        randomId = [NSNumber numberWithInt:0];
        
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
            self.randomDVQuizQuestion =
            [[DVQuizQuestion alloc]
                init:snapshot.value[@"question"]
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
        
         NSLog(@"Setting alreadyAsked[%d][%d] to true", subjectType, randomIdInt);
         alreadyAsked[subjectType][randomIdInt] = true;
    }
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


@end
