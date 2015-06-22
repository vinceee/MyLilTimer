//
//  TimerTestViewController.m
//  MyLilTimer
//
//  Created by Jonathon Mah on 2014-01-12.
//  This is free and unencumbered software released into the public domain.
//

#import "TimerTestViewController.h"

#import "MyLilTimer.h"


@interface TimerTestViewController ()

@property (nonatomic) IBOutlet UILabel *hourglassLabel;
@property (nonatomic) IBOutlet UILabel *pauseOnSystemSleepLabel;
@property (nonatomic) IBOutlet UILabel *obeySystemClockChangesLabel;

@end


@implementation TimerTestViewController {
    NSMutableArray *_validTimers;
    NSTimer *_updateLabelsTimer;
    NSNumberFormatter *_numberFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _validTimers = [NSMutableArray array];
    _numberFormatter = [[NSNumberFormatter alloc] init];
    _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    _numberFormatter.minimumFractionDigits = _numberFormatter.maximumFractionDigits = 1;
    
    //wos test self created textfield
    int InLeft, InTop, InWidth, InFontSize;
    InLeft = 100;
    InTop = 300;
    InWidth = 280;
    InFontSize = 30;
    
    //register once
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNoify:) name:UIKeyboardWillShowNotification object:nil];
    
    CGRect AdjustFrame = CGRectMake(InLeft, InTop, InWidth, InFontSize);
    UITextField* pTextFiled = [[UITextField alloc] initWithFrame:AdjustFrame];
    pTextFiled.delegate =  self;
    pTextFiled.font = [pTextFiled.font fontWithSize:InFontSize];
    //pTextFiled.textColor = [UIColor whiteColor];
    //pTextFiled.placeholder = @"I'm waiting";
    //[pTextFiled setBackgroundColor:[UIColor grayColor]];
    pTextFiled.autocorrectionType = UITextAutocorrectionTypeNo;
    pTextFiled.keyboardType = UIKeyboardTypeDefault;
    pTextFiled.returnKeyType = UIReturnKeyDone;
    pTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    pTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    pTextFiled.delegate = self;
    
    //NSString* TestLocStr = NSLocalizedString(@"TESTLan1", "Nothing");
    NSString* TestLocStr = [NSString stringWithCString:"123" encoding:NSUTF8StringEncoding];

    [self.view addSubview:pTextFiled];
    //pTextFiled removef
    //wos test end
}

- (void) MoveViewByKeywoard:(int)InOffset
{
    CGRect FrameSize = [[UIScreen mainScreen] bounds];

    float movementDuration = 0.f;
    if (InOffset < 0)//move up case
    {
        FrameSize.origin.y += InOffset;
        movementDuration = 0.3f;
    }
    else
    {
        movementDuration = 0.1f;
    }
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = FrameSize;
    [UIView commitAnimations];
}

//record current focus text field widget's frame info
static CGRect sCurrentEditingTextFieldFrame;
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    sCurrentEditingTextFieldFrame = textField.frame;
    return YES;
}

-(void)keyboardWillShowNoify:(NSNotification*)aNotification
{
    //viewport size
    CGRect FrameSize = [[UIScreen mainScreen] bounds];
    //keyboard size
    NSDictionary* info = [aNotification userInfo];
    NSValue* KeyboardBounds = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardSize = [KeyboardBounds CGRectValue];
    int ToBottomOffset = FrameSize.size.height - (sCurrentEditingTextFieldFrame.origin.y + sCurrentEditingTextFieldFrame.size.height);
    ToBottomOffset -= keyboardSize.size.height;
    [self MoveViewByKeywoard:ToBottomOffset];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self MoveViewByKeywoard:10];//give a positive value
    return NO;
}
//wos textfield delegate end

- (IBAction)restartTimers:(id)sender
{
    [_updateLabelsTimer invalidate];
    for (MyLilTimer *timer in _validTimers) {
        [timer invalidate];
    }
    [_validTimers removeAllObjects];

    static const NSTimeInterval interval = 60;

    [_validTimers addObject:[MyLilTimer scheduledTimerWithBehavior:MyLilTimerBehaviorHourglass timeInterval:interval target:self selector:@selector(timerFired:) userInfo:self.hourglassLabel]];
    [_validTimers addObject:[MyLilTimer scheduledTimerWithBehavior:MyLilTimerBehaviorPauseOnSystemSleep timeInterval:interval target:self selector:@selector(timerFired:) userInfo:self.pauseOnSystemSleepLabel]];
    [_validTimers addObject:[MyLilTimer scheduledTimerWithBehavior:MyLilTimerBehaviorObeySystemClockChanges timeInterval:interval target:self selector:@selector(timerFired:) userInfo:self.obeySystemClockChangesLabel]];

    _updateLabelsTimer = [NSTimer scheduledTimerWithTimeInterval:(1. / 10.) target:self selector:@selector(updateLabelsTimerFired:) userInfo:nil repeats:YES];
    [_updateLabelsTimer fire];
}

- (void)updateLabelsTimerFired:(NSTimer *)timer
{
    for (MyLilTimer *timer in _validTimers) {
        [self updateLabelForTimer:timer];
    }
}

- (void)updateLabelForTimer:(MyLilTimer *)timer
{
    UILabel *label = timer.userInfo;
    NSTimeInterval timeSinceFireDate = timer.timeSinceFireDate;
    if (timeSinceFireDate < 0) {
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor blackColor];
    } else {
        label.backgroundColor = [UIColor greenColor];
        label.textColor = [UIColor whiteColor];
    }

    label.text = [_numberFormatter stringFromNumber:@(timeSinceFireDate)];
}

- (void)timerFired:(MyLilTimer *)timer
{
    [_validTimers removeObject:timer];
    [self updateLabelForTimer:timer];

    if (!_validTimers.count) {
        [_updateLabelsTimer invalidate];
        _updateLabelsTimer = nil;
    }
}

@end
