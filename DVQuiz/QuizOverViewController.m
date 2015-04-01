//
//  QuizOverViewController.m
//  DVQuiz
//
//  Created by Douglas Voss on 3/31/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "QuizOverViewController.h"

@interface QuizOverViewController ()

@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;

@end

@implementation QuizOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"self.answeredRight=%d", self.answeredRight);
    NSLog(@"self.answeredTotal=%d", self.answeredTotal);
    self.scoreLabel.text = [NSString stringWithFormat:@"Score is %d/%d: %.0f%%", _answeredRight, _answeredTotal, 100*((float)_answeredRight/(float)_answeredTotal)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {

    }
    
    return self;
}


- (IBAction)startAgain:(id)sender
{
    self.scoreLabel.text = @"Please dismiss me.";
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
