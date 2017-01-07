//
//  GSAlarm.m
//  Earth Mantra 2
//
//  Created by Ian on 5/22/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import "GSAlarm.h"
#import "GSMainMenu.h"
#import "OrbView.h"
#import "math.h"
#import "BGTouchDownGestureRecognizer.h"


static NSString *reuseID = @"MyCells";
#define DEGREES_TO_RADIANS(angle) (angle/180.0*M_PI)

@implementation GSAlarm {
    
    UISwitch *firstAlarmSwitch;
    UISwitch *secondAlarmSwitch;
    UISwitch *thirdAlarmSwitch;
    UISwitch *fourthAlarmSwitch;
    
    OrbView *orb;
    float angle;
    
//    UITapGestureRecognizer *singleTap;
//    BGTouchDownGestureRecognizer* orbGestureRecognizer;
    BGTouchDownGestureRecognizer* touchDownGestureRecognizer;
}

-(GSAlarm*) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager {
    
    NSLog(@"gsAlarm initWithFrame:andManager");
    
    if (self = [super initWithFrame:frame gameSceneManager:manager]) {
        //do initializations here.
        
        [self initializeTableView];
    }
    return self;
}

-(void)initializeTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(0,
                                                                    75,
                                                                    self.bounds.size.width,
                                                                    self.bounds.size.height - 75)
                                                  style:UITableViewStylePlain];
    
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: reuseID];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [self addSubview:self.tableView];
    
    
    /*
     Create a header for the table view and attach it to the view controller. I'm not using the UITableView's tableHeaderView property
     because I don't want the header to scroll with the table view. Here I also add a label to the header.
     */
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 75)];
    header.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    
    UIView *headerDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 75, self.bounds.size.width, 1)];
    headerDivider.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0];
    [header addSubview:headerDivider];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"Alarm";
    label.font = [UIFont fontWithName:@"HelveticaNeue" size: 25.0];
    [label sizeToFit];
    [header addSubview: label];
    
    [self addSubview:header];
    
    
    /*
     Create a footer for the table view and attach it to the view controller.
     */
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 60, self.bounds.size.width, 60)];
    footer.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    
    UIView *footerDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
    footerDivider.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0];
    [footer addSubview:footerDivider];
    [self addSubview:footer];
    
    
    //-- Contrain the header -----------------------------------//
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:header attribute:NSLayoutAttributeWidth
      relatedBy:NSLayoutRelationEqual
      toItem:self attribute:NSLayoutAttributeWidth
      multiplier:1 constant:0]];
    
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:header attribute:NSLayoutAttributeHeight
      relatedBy:NSLayoutRelationEqual
      toItem:nil attribute:NSLayoutAttributeNotAnAttribute
      multiplier:1 constant:75]];
    //-- End contrain the header -----------------------------------//
    
    //-- Contrain the header label -----------------------------------//
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [header addConstraint:
     [NSLayoutConstraint
      constraintWithItem:label attribute:NSLayoutAttributeCenterY
      relatedBy:NSLayoutRelationEqual
      toItem:header attribute:NSLayoutAttributeCenterY
      multiplier:1.3 constant:0]];
    
    [header addConstraint:
     [NSLayoutConstraint
      constraintWithItem:label attribute:NSLayoutAttributeCenterX
      relatedBy:NSLayoutRelationEqual
      toItem:header attribute:NSLayoutAttributeCenterX
      multiplier:1 constant:0]];
    //-- End contrain the header label -----------------------------------//
    
    
    //-- Contrain the header divider -----------------------------------//
    
    headerDivider.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:headerDivider attribute:NSLayoutAttributeHeight
      relatedBy:NSLayoutRelationEqual
      toItem:nil attribute:NSLayoutAttributeNotAnAttribute
      multiplier:1 constant:1]];
    
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:headerDivider attribute:NSLayoutAttributeWidth
      relatedBy:NSLayoutRelationEqual
      toItem:self attribute:NSLayoutAttributeWidth
      multiplier:1 constant:0]];
    
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:headerDivider attribute:NSLayoutAttributeBottom
      relatedBy:NSLayoutRelationEqual
      toItem:header attribute:NSLayoutAttributeBottom
      multiplier:1 constant:0]];
    
    //-- End contrain the header divider -----------------------------------//
    
    
    //-- Contrain the footer -----------------------------------//
    footer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:footer attribute:NSLayoutAttributeWidth
      relatedBy:NSLayoutRelationEqual
      toItem:self attribute:NSLayoutAttributeWidth
      multiplier:1 constant:0]];
    
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:footer attribute:NSLayoutAttributeHeight
      relatedBy:NSLayoutRelationEqual
      toItem:nil attribute:NSLayoutAttributeNotAnAttribute
      multiplier:1 constant:60]];
    
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:footer attribute:NSLayoutAttributeBottom
      relatedBy:NSLayoutRelationEqual
      toItem:self attribute:NSLayoutAttributeBottom
      multiplier:1 constant:0]];
    
    //-- End contrain the footer -----------------------------------//
    
    //-- Contrain the footer divider -----------------------------------//
    
    footerDivider.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:footerDivider attribute:NSLayoutAttributeHeight
      relatedBy:NSLayoutRelationEqual
      toItem:nil attribute:NSLayoutAttributeNotAnAttribute
      multiplier:1 constant:1]];
    
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:footerDivider attribute:NSLayoutAttributeWidth
      relatedBy:NSLayoutRelationEqual
      toItem:self attribute:NSLayoutAttributeWidth
      multiplier:1 constant:0]];
    
    [self addConstraint:
     [NSLayoutConstraint
      constraintWithItem:footerDivider attribute:NSLayoutAttributeTop
      relatedBy:NSLayoutRelationEqual
      toItem:footer attribute:NSLayoutAttributeTop
      multiplier:1 constant:0]];
    
    //-- End contrain the header divider -----------------------------------//
    
//    orb =[[OrbView alloc]initWithFrame:CGRectMake((self.bounds.size.width/2)-(200/2), (self.bounds.size.height/2)-(200/2), 200, 200)];
//    orb =[[OrbView alloc]initWithFrame:CGRectMake((self.bounds.size.width/2)-(200/2), (self.bounds.size.height/2)-(200/2), 200, 200)];
    orb =[[OrbView alloc]initWithFrame:CGRectMake((self.bounds.size.width/2), (self.bounds.size.height/2), 200, 200)];
    
//    orb.center = self.center;
//       CGPoint anchorPoint = CGPointMake(0.5,0.5);
  //     [[orb layer] setAnchorPoint:anchorPoint];
    
    [self addSubview:orb];

//    orb.backgroundColor = [UIColor blueColor];
    
    
/*
    [CATransaction begin];
    
//    CGRect boundingRect = CGRectMake(-(self.bounds.size.width/2), -(self.bounds.size.height/2), self.bounds.size.width/2, self.bounds.size.width/2);
//    CGRect boundingRect = CGRectMake(-((self.bounds.size.width/2) + 0), -((self.bounds.size.height/2) + 0), self.bounds.size.width/2, self.bounds.size.width/2);
//    CGRect boundingRect = CGRectMake(-((self.bounds.size.width/2) - 75), -((self.bounds.size.height/2) - 75), self.bounds.size.width/2, self.bounds.size.width/2);

    CGRect boundingRect = CGRectMake(-((self.bounds.size.width/4) - 0), -((self.bounds.size.height/4) - 0), self.bounds.size.width/2, self.bounds.size.width/2);
    CAKeyframeAnimation *orbit = [CAKeyframeAnimation animation];
    orbit.keyPath = @"position";
    orbit.path = CFAutorelease(CGPathCreateWithEllipseInRect(boundingRect, NULL));
    orbit.duration = 4;
    orbit.additive = YES;
    orbit.repeatCount = 6; //HUGE_VALF;
    orbit.calculationMode = kCAAnimationPaced;
//    orbit.rotationMode = kCAAnimationRotateAuto;
    orbit.rotationMode = nil;
    
    [CATransaction setCompletionBlock:^{
        
        NSLog(@"gsAlarm Animation complete");
        
        
    }];
    
    [orb.layer addAnimation:orbit forKey:@"orbit"];
*/

    // Create your custom TouchDownGestureRecognizer: http://stackoverflow.com/questions/15628133/uitapgesturerecognizer-make-it-work-on-touch-down-not-touch-up
/*
    touchDownGestureRecognizer = [[BGTouchDownGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(handleTouchDown:)];
    
    touchDownGestureRecognizer.cancelsTouchesInView = NO;
    touchDownGestureRecognizer.delegate = self;
    [self addGestureRecognizer:touchDownGestureRecognizer];
*/


    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchDown:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];

    
    
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [orb setUserInteractionEnabled:YES];
    [orb addGestureRecognizer:singleTap];


    
    
}

//  Implement the UIGestureRecognizerDelegate delegate to allow both gestureRecognizer and otherGestureRecognizer to recognize their gestures simultaneously.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)handleTouchDown:(BGTouchDownGestureRecognizer *)touchDown{
    NSLog(@"Down");
    if([orb isAwake] == NO) {
        [orb wakeUpWithDelay:0.0];
    }
}

-(void)tapDetected{
    NSLog(@"single Tap on imageview");
    NSLog(@"ORB AWAKE: %hhd", [orb isAwake]);
    
    if([orb isAwake] == YES) {
        [m_pManager doSceneChange:[GSMainMenu class]];
    }

}

- (void) update:(double)delta {

    if(orb) {
//        if([orb isAwake] == YES) {
            [orb animateOrb:orb boundedByParent:self];
  //      }
    }
}


-(void) animateOrb:(UIView *) view {
    
    // http://stackoverflow.com/questions/17765841/draw-moving-circles
    
    float x;
    float y;
    //    float w = (self.bounds.size.width-200)/2;
    //  float h = (self.bounds.size.width-200)/2;
    
    //    float w = (320-200)/2;
    //  float h = (320-200)/2;
    float w = (320)/2;
    float h = (320)/2;
    
    //    NSLog(@"######## %f", self.bounds.size.width);
    
    
    
    x = w + w * cos(angle * M_PI / 180);
    y = h + h * sin(angle * M_PI / 180);
    
    CGRect br = CGRectMake(((self.bounds.size.width/2)) - (x/2) - 20, (self.bounds.size.height/2)-(y/2), 200, 200);
    //    CGRect br = CGRectMake(((self.bounds.size.width/2)), (self.bounds.size.height/2), 200, 200);
    //    NSLog(@"######## %f", br.origin.x);
    
    //    br.origin.x -= x;
    //  br.origin.y -= y;
    [view setFrame:br];
    
    /*
     CGRect r = [view frame];
     r.origin.x = x - (320/2);
     r.origin.y = y;
     [view setFrame:r];
     */
    
    angle+=2;
    if (angle > 360) {
        angle = 0;
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([tableView isEqual:self.tableView]){
        return 1;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // Number of rows / alarms in table view
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:reuseID
                                    forIndexPath:indexPath];
    if (![cell viewWithTag:1]) {
        
        cell.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0];
        
        UILabel* lab = [UILabel new];
        lab.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size: 50.0];
        lab.textColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:142.0f/255.0f alpha:1.0];
        lab.tag = 1;
        [cell.contentView addSubview:lab];
        
        UILabel* lab2 = [UILabel new];
        lab2.font = [UIFont fontWithName:@"Helvetica-Light" size: 20.0];
        lab2.textColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:142.0f/255.0f alpha:1.0];
        lab2.tag = 2;
        [cell.contentView addSubview:lab2];
        
        
        UILabel* lab3 = [UILabel new];
        lab3.font = [UIFont fontWithName:@"HelveticaNeue" size: 14.0];
        lab3.textColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:142.0f/255.0f alpha:1.0];
        lab3.tag = 3;
        [cell.contentView addSubview:lab3];
        
        
        // position using constraints
        lab.translatesAutoresizingMaskIntoConstraints = NO;
        lab2.translatesAutoresizingMaskIntoConstraints = NO;
        lab3.translatesAutoresizingMaskIntoConstraints = NO;
        
        [cell.contentView addConstraint:
         [NSLayoutConstraint
          constraintWithItem:lab attribute:NSLayoutAttributeHeight
          relatedBy:NSLayoutRelationEqual
          toItem:nil attribute:NSLayoutAttributeNotAnAttribute
          multiplier:1 constant:50]];
        
        [cell.contentView addConstraint:
         [NSLayoutConstraint
          constraintWithItem:lab2 attribute:NSLayoutAttributeHeight
          relatedBy:NSLayoutRelationEqual
          toItem:nil attribute:NSLayoutAttributeNotAnAttribute
          multiplier:1 constant:20]];
        
        [cell.contentView addConstraint:
         [NSLayoutConstraint
          constraintWithItem:lab2 attribute:NSLayoutAttributeBottom
          relatedBy:0
          toItem:lab attribute:NSLayoutAttributeBottom
          multiplier:1 constant:-5]];
        
        NSDictionary* d = NSDictionaryOfVariableBindings(lab, lab2, lab3);
        
        [cell.contentView addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"H:|-15-[lab]-5-[lab2]"
          options:0 metrics:nil views:d]];
        
        [cell.contentView addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"H:|-20-[lab3]"
          options:0 metrics:nil views:d]];
        
        [cell.contentView addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"V:|-25-[lab]-0-[lab3]"
          options:0 metrics:nil views:d]];
    }
    
    
    
    UILabel* lab = (UILabel*)[cell.contentView viewWithTag: 1];
    UILabel* lab2 = (UILabel*)[cell.contentView viewWithTag: 2];
    switch ((long)indexPath.row) {
            
        case 0: {
            
            lab.text = [NSString stringWithFormat: @"9:00"];
            lab2.text = [NSString stringWithFormat: @"AM"];
            firstAlarmSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 100, 0, 0)];
            cell.accessoryView = firstAlarmSwitch;
            
            BOOL state = [self getSavedAlarmState: (long)indexPath.row];
            [firstAlarmSwitch setOn: state animated:NO];
            [firstAlarmSwitch addTarget:self
                                 action:@selector(alarmSwitchChanged:)
                       forControlEvents:UIControlEventValueChanged];
            
            break;
        }
        case 1: {
            
            lab.text = [NSString stringWithFormat: @"1:00"];
            lab2.text = [NSString stringWithFormat: @"PM"];
            secondAlarmSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 100, 0, 0)];
            cell.accessoryView = secondAlarmSwitch;
            
            BOOL state = [self getSavedAlarmState: (long)indexPath.row];
            [secondAlarmSwitch setOn: state animated:NO];
            [secondAlarmSwitch addTarget:self
                                  action:@selector(alarmSwitchChanged:)
                        forControlEvents:UIControlEventValueChanged];
            
            break;
        }
        case 2: {
            
            lab.text = [NSString stringWithFormat: @"6:00"];
            lab2.text = [NSString stringWithFormat: @"PM"];
            thirdAlarmSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 100, 0, 0)];
            cell.accessoryView = thirdAlarmSwitch;
            
            BOOL state = [self getSavedAlarmState: (long)indexPath.row];
            [thirdAlarmSwitch setOn: state animated:NO];
            [thirdAlarmSwitch addTarget:self
                                 action:@selector(alarmSwitchChanged:)
                       forControlEvents:UIControlEventValueChanged];
            
            break;
        }
        case 3: {
            
            lab.text = [NSString stringWithFormat: @"12:00"];
            lab2.text = [NSString stringWithFormat: @"AM"];
            fourthAlarmSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 100, 0, 0)];
            cell.accessoryView = fourthAlarmSwitch;
            
            BOOL state = [self getSavedAlarmState: (long)indexPath.row];
            [fourthAlarmSwitch setOn: state animated:NO];
            [fourthAlarmSwitch addTarget:self
                                  action:@selector(alarmSwitchChanged:)
                        forControlEvents:UIControlEventValueChanged];
            
            break;
        }
    }
    
    
    UILabel* lab3 = (UILabel*)[cell.contentView viewWithTag: 3];
    lab3.text = [NSString stringWithFormat: @"Alarm"];
    
    
    
    return cell;
    
}

- (BOOL)getSavedAlarmState:(int)alarm {
    
    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"alarm%d",alarm]];
    return state;
}

- (void)setAndSaveAlarm:(int)alarm state:(BOOL)state {
    
    switch (alarm) {
            
        case 0: {
            [firstAlarmSwitch setOn:state animated:NO];
            [[NSUserDefaults standardUserDefaults] setBool:firstAlarmSwitch.on forKey:[NSString stringWithFormat:@"alarm%d",alarm]];
            
            if(state){
/*
                NSDateComponents *dcs = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
                                         NSCalendarUnitMonth |
                                         NSCalendarUnitYear fromDate:[NSDate date]];

                dcs.hour = 9;
                dcs.minute = 0;
                dcs.second = 0;
*/
                
                NSDateComponents *dcs = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
                                         NSCalendarUnitMonth |
                                         NSCalendarUnitYear |
                                         NSCalendarUnitHour |
                                         NSCalendarUnitMinute fromDate:[NSDate date]];
                
                dcs.minute = ((dcs.minute + 2) % 60);
                dcs.second = 0;
                
                [self setAlarm: alarm withDateComponents: dcs];
                
                NSLog(@"%ld", (long)dcs.minute);
                
                
            } else {
                [self cancelAlarm: alarm];
            }
            break;
        }
        case 1: {
            [secondAlarmSwitch setOn:state animated:NO];
            [[NSUserDefaults standardUserDefaults] setBool:secondAlarmSwitch.on forKey:[NSString stringWithFormat:@"alarm%d",alarm]];
            
            if(state){
                
                // See http://stackoverflow.com/questions/3694867/nsdate-get-year-month-day
                // Get the day, month, and year from the current system calendar for the current day.
                // (Note: this isn't necessarily the current user-specified calendar, just the default system one.)
                NSDateComponents *dcs = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
                                         NSCalendarUnitMonth |
                                         NSCalendarUnitYear fromDate:[NSDate date]];
                dcs.hour = 13;
                dcs.minute = 0;
                dcs.second = 0;
                [self setAlarm: alarm withDateComponents: dcs];
                
            } else {
                [self cancelAlarm: alarm];
            }
            break;
        }
        case 2: {
            [thirdAlarmSwitch setOn:state animated:NO];
            [[NSUserDefaults standardUserDefaults] setBool:thirdAlarmSwitch.on forKey:[NSString stringWithFormat:@"alarm%d",alarm]];
            
            if(state){
                
                NSDateComponents *dcs = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
                                         NSCalendarUnitMonth |
                                         NSCalendarUnitYear fromDate:[NSDate date]];
                dcs.hour = 18;
                dcs.minute = 0;
                dcs.second = 0;
                [self setAlarm: alarm withDateComponents: dcs];
                
            } else {
                [self cancelAlarm: alarm];
            }
            break;
        }
        case 3: {
            [fourthAlarmSwitch setOn:state animated:NO];
            [[NSUserDefaults standardUserDefaults] setBool:fourthAlarmSwitch.on forKey:[NSString stringWithFormat:@"alarm%d",alarm]];
            
            if(state){
                
                NSDateComponents *dcs = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
                                         NSCalendarUnitMonth |
                                         NSCalendarUnitYear fromDate:[NSDate date]];
                dcs.hour = 0;
                dcs.minute = 0;
                dcs.second = 0;
                [self setAlarm: alarm withDateComponents: dcs];
                
            } else {
                [self cancelAlarm: alarm];
            }
            break;
        }
    }
}

- (void)alarmSwitchChanged:(UISwitch *)paramSender {
    
    if(paramSender == firstAlarmSwitch) {
        
        NSLog(@"%@", @"First Alarm");
        [self setAndSaveAlarm: 0 state:[paramSender isOn]];
        
    } else if(paramSender == secondAlarmSwitch) {
        
        NSLog(@"%@", @"Second Alarm");
        [self setAndSaveAlarm: 1 state:[paramSender isOn]];
        
    } else if(paramSender == thirdAlarmSwitch) {
        
        NSLog(@"%@", @"Third Alarm");
        [self setAndSaveAlarm: 2 state:[paramSender isOn]];
        
    } else if(paramSender == fourthAlarmSwitch) {
        
        NSLog(@"%@", @"Fourth Alarm");
        [self setAndSaveAlarm: 3 state:[paramSender isOn]];
        
    }
}

- (void)setAlarm:(int)alarm withDateComponents:(NSDateComponents *) dcs {
    
    NSTimeZone *tz = [NSTimeZone timeZoneWithName: @"America/New_York"];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorianCalendar dateFromComponents:dcs];
    
    UILocalNotification *ln = [UILocalNotification new];
    ln.fireDate = date;
    ln.timeZone = tz;
    ln.alertBody = @"Time for world meditation";
    ln.hasAction = YES;
    ln.soundName = UILocalNotificationDefaultSoundName;
    ln.repeatInterval = NSCalendarUnitDay;
        
    // Define a unique id. When cancelling a notification, you'll need this.
    ln.userInfo = @{@"uid" : [NSString stringWithFormat: @"alarm%d",alarm]};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:ln];
    
}

- (void)cancelAlarm:(int)alarm {
    
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications] ;
    for (UILocalNotification *localNotification in localNotifications) {
        
        NSDictionary *userInfo = localNotification.userInfo;
        NSString *uid = [NSString stringWithFormat:@"%@",[userInfo valueForKey:@"uid"]];
        if ([uid isEqualToString:[NSString stringWithFormat: @"alarm%d",alarm]])
        {
            // Cancelling local notification
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0){
        return 60.0f;
    }
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    //Set the background color of the View
    view.tintColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0];
}


@end
