//
//  QuizOverViewController.m
//  DVQuiz
//
//  Created by Douglas Voss on 3/31/15.
//

#import "QuizOverViewController.h"
#import "CoolButton.h"
#import "CoolLabel.h"

@interface QuizOverViewController ()

@property (nonatomic) CoolLabel *quizOverLabel;
@property (nonatomic) UILabel *scoreLabel;
@property (nonatomic) CoolButton * startOverButton;

@end

@implementation QuizOverViewController


- (void)redoFrames
{
    int statusBarOffsetInPoints = 20.0;
    int standardRectLeftOffset = self.view.frame.size.width/16.0;
    int standardRectWidth = self.view.frame.size.width*(14.0/16.0);
    int standardRectHeight = self.view.frame.size.height*(1.0/16.0);
    int standardInterRectSpacing = self.view.frame.size.height*(2.0/128.0);
    
    self.quizOverLabel.frame = CGRectMake(standardRectLeftOffset, statusBarOffsetInPoints+1.0 + (0.0*(standardRectHeight + standardInterRectSpacing)), standardRectWidth, standardRectHeight*3.0);
    
    self.scoreLabel.frame = CGRectMake(standardRectLeftOffset, statusBarOffsetInPoints+1.0 + (4.0*(standardRectHeight + standardInterRectSpacing)), standardRectWidth, standardRectHeight*3.0);
    
    self.startOverButton.frame = CGRectMake(standardRectLeftOffset, statusBarOffsetInPoints+1.0 + (8.0*(standardRectHeight + standardInterRectSpacing)), standardRectWidth, standardRectHeight*4.0);
    
    [self.quizOverLabel setNeedsDisplay];
    [self.scoreLabel setNeedsDisplay];
    [self.startOverButton setNeedsDisplay];
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


- (void)startOverButtonHandler:(UIButton *)sender
{
    self.scoreLabel.text = @"Please dismiss me.";
    [self.navigationController popToRootViewControllerAnimated:true];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _quizOverLabel = [[CoolLabel alloc] initWithColor:[UIColor redColor]];
    self.quizOverLabel.textColor = [UIColor blackColor];
    self.quizOverLabel.highlightedTextColor = [UIColor blueColor];
    //self.quizOverLabel.backgroundColor = [UIColor blueColor];
    self.quizOverLabel.textAlignment = NSTextAlignmentCenter;  //(for iOS 6.0)
    self.quizOverLabel.text = @"Quiz Over!";
    
    _scoreLabel = [[UILabel alloc] init];
    if (self.answeredTotal > 0.0) {
        self.scoreLabel.text = [NSString stringWithFormat:@"Score is %d/%d: %.0f%%", self.answeredRight, self.answeredTotal, 100*((float)self.answeredRight/(float)self.answeredTotal)];
    } else {
        self.scoreLabel.text = [NSString stringWithFormat:@"Score is 0 and so much more text on this line to test the wrapping capabilities (but not the rapping capabilities as that would be silly)."];
    }
    self.scoreLabel.textColor = [UIColor orangeColor];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;  //(for iOS 6.0)
    self.scoreLabel.backgroundColor = [UIColor clearColor];
    self.scoreLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.scoreLabel.numberOfLines = 0;
    
    
    
    _startOverButton = [CoolButton makeCoolButtonWithHandler:self selector:@selector(startOverButtonHandler:) text:@"Start Over" color:[UIColor brownColor]];

    NSLog(@"self.answeredRight=%d", self.answeredRight);
    NSLog(@"self.answeredTotal=%d", self.answeredTotal);

    
    [self.view addSubview:self.quizOverLabel];
    [self.view addSubview:self.scoreLabel];
    [self.view addSubview:self.startOverButton];
    
    [self redoFrames];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
