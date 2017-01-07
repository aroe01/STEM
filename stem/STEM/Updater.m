//
//  Updater.m
//  Global Mantra
//
//  Created by Ian Foster on 4/4/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import "Updater.h"
//#import "WhirlyGlobe.h"

// Note: Should import WhirlyGlobe.h here instead of doing this
//       But we can hack it for the moment

/*
static const int NUM_FRAMES = 60;
static const int FIRST_FRAME_ORDINAL = 60;
NSString static *const ORB_FILENAME = @"GlowBall_looping_240_%05d.png";
*/

static const int NUM_ORB_FRAMES = 240;
static const int FIRST_ORB_FRAME_ORDINAL = 0;
NSString static *const ORB_FILENAME = @"gb_15fps_%05d.png";

static const int NUM_USER_FRAMES = 60;
static const int FIRST_USER_FRAME_ORDINAL = 0;
NSString static *const USER_FILENAME = @"user_glow_128_%05d.png";

static const float USER_GLOBE_SIZE = (0.0000010/80.0);
static const float ORB_GLOBE_SIZE = (0.0000010/50.0);



//float width;
//float radius;

@implementation Updater
{
    NSTimeInterval start;
    float period;
    float radius;
    float width;
    UIColor *color;
    
    int orbFrameCnt;
    int userFrameCnt;

    MaplyComponentObject * people;
    MaplyCoordinate * locations;
    int numOfLocations;
    
    MaplyComponentObject *compObj;  // The animating thing
    UIImage * frames[NUM_USER_FRAMES];
//    UIImage * orb_frames[NUM_ORB_FRAMES];
    
    int degree;
    
}

- (id)initWithPeriod:(float)inPeriod people:(MaplyComponentObject *)thePeople locations:(MaplyCoordinate *)theLocations numberOfLocations:(int)count viewC:(MaplyBaseViewController *)viewC
{
    self = [super initWithViewController:viewC];
    if (!self)
        return nil;

    period = inPeriod;
    locations = theLocations;
    numOfLocations = count;
    NSLog(@"number of locations %i\n", numOfLocations);
    NSLog(@"1st Entry %f\n", locations[3].x);
    
    orbFrameCnt= 0;
    userFrameCnt= 0;
    
    degree = 0;

/*
    for (unsigned int ii=0;ii<NUM_ORB_FRAMES;ii++)
    {
        NSString *img = [NSString stringWithFormat:ORB_FILENAME, ii+FIRST_ORB_FRAME_ORDINAL];
        orb_frames[ii] = [UIImage imageNamed:img];
    }
*/
    for (unsigned int ii=0;ii<NUM_USER_FRAMES;ii++)
    {
        //        NSString *paddedStr = [NSString stringWithFormat:@"user_glow_128_%05d", ii];
        //      NSLog(@"result : %@ ",paddedStr);
        
        NSString *img = [NSString stringWithFormat:USER_FILENAME, ii+FIRST_USER_FRAME_ORDINAL];
        //        NSLog(@"result : %@ ",img);
        frames[ii] = [UIImage imageNamed:img];
    }
    
    
    start = CFAbsoluteTimeGetCurrent();
    return self;
}


- (bool)hasUpdate
{
    return true;
}

- (void)updateForFrameXXX:(id)frameInfo
{
    
    if (people)
    {
        [super.viewC removeObjects:@[people] mode:MaplyThreadCurrent];
        people = nil;
    }
    
    float t = (CFAbsoluteTimeGetCurrent()-start)/period;
    t -= (int)t;
    
    orbFrameCnt += 1;
    orbFrameCnt = orbFrameCnt % NUM_ORB_FRAMES;
    
    userFrameCnt += 1;
    userFrameCnt = userFrameCnt % NUM_USER_FRAMES;
    
    
    // To maintain a constant screen size, calculate the size as a percentage of the map scale.
    float scale = [super.viewC currentMapScale];
    float orbGlobeSize = ORB_GLOBE_SIZE * scale;
    float userGlobeSize = USER_GLOBE_SIZE * scale;
    
    
    NSMutableArray *markers = [NSMutableArray array];
    for (unsigned int ii=0;ii<numOfLocations;ii++)
    {
        MaplyMarker *marker = [[MaplyMarker alloc] init];
        if(ii == 0) {
            NSString *img = [NSString stringWithFormat:ORB_FILENAME, orbFrameCnt+FIRST_ORB_FRAME_ORDINAL];
            marker.image = [UIImage imageNamed:img];
            
            marker.size = CGSizeMake(orbGlobeSize, orbGlobeSize);
            marker.selectable = true;
        } else {
            
            marker.image = frames[userFrameCnt];
            marker.size = CGSizeMake(userGlobeSize, userGlobeSize);
            marker.selectable = false;
        }
        marker.loc = locations[ii];
        [markers addObject:marker];
    }
    people = [super.viewC addMarkers:markers desc:nil mode:MaplyThreadCurrent];
    
    [self testSine];
    
}

- (void)updateForFrame:(id)frameInfo
{
    
    if (people)
    {
        [super.viewC removeObjects:@[people] mode:MaplyThreadCurrent];
        people = nil;
    }
    
    float t = (CFAbsoluteTimeGetCurrent()-start)/period;
    t -= (int)t;
    
    orbFrameCnt += 1;
    orbFrameCnt = orbFrameCnt % NUM_ORB_FRAMES;

    userFrameCnt += 1;
    userFrameCnt = userFrameCnt % NUM_USER_FRAMES;
    
    
    // To maintain a constant screen size, calculate the size as a percentage of the map scale.
    float scale = [super.viewC currentMapScale];
    float orbGlobeSize = ORB_GLOBE_SIZE * scale;
    float userGlobeSize = USER_GLOBE_SIZE * scale;

    
    NSMutableArray *markers = [NSMutableArray array];

    MaplyMarker *marker = [[MaplyMarker alloc] init];
    NSString *img = [NSString stringWithFormat:ORB_FILENAME, orbFrameCnt+FIRST_ORB_FRAME_ORDINAL];
    marker.image = [UIImage imageNamed:img];
    marker.size = CGSizeMake(orbGlobeSize, orbGlobeSize);
    marker.selectable = true;
    marker.loc = locations[0];
    [markers addObject:marker];
    
    
    int numUsers = 0;
    EMUser* users = [self getUserUpdatesWithCount:&numUsers];
    if(numUsers) {
        
        for (unsigned int ii=0;ii<numUsers;ii++)
        {
            MaplyMarker *marker = [[MaplyMarker alloc] init];
            marker.size = CGSizeMake(userGlobeSize, userGlobeSize);
            
            NSArray *colors = @[
                                (id)[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.985].CGColor,
                                (id)[UIColor colorWithRed:25.0f/255.0f green:218.0f/255.0f blue:227.0f/255.0f alpha:0.985*.6].CGColor,
                                (id)[UIColor colorWithRed:25.0f/255.0f green:218.0f/255.0f blue:227.0f/255.0f alpha:0.1].CGColor,
                                ];
            
            marker.image = [self createRadialGradientWithColors: colors timeCreated:users[ii].timeCreated];
            marker.selectable = false;
            marker.loc = users[ii].location;
            [markers addObject:marker];
        }
    }
    
    people = [super.viewC addMarkers:markers desc:nil mode:MaplyThreadCurrent];
    
    [self testSine];
    
}



- (void)shutdown
{
    if (people)
    {
        [super.viewC removeObjects:@[people] mode:MaplyThreadCurrent];
        people = nil;
    }
}

- (void) testSine
{

    width = 100;
    degree += 1;
    degree = degree % 360;
    float radians = degree * 180 / 3.14;
//    float rad = fabs(sin(radians) * (width / 4.0));
    float rad = sin(radians);
//    rad += (width/4);
    NSLog(@"RADIUS:%f", rad);

    
    
}


- (UIImage *)createRadialGradientWithColors:(NSArray *)colors timeCreated:(NSTimeInterval)timeCreated {
    // http://stackoverflow.com/questions/16788305/how-to-create-uiimage-with-vertical-gradient-using-from-color-and-to-color
    
    //    width = 100;
    width = 25;
    
    NSTimeInterval time = [[NSDate date] timeIntervalSinceReferenceDate];
    time = timeCreated - time;
    double t = time;
    radius = fabs(sin(t) * (width / 4.0));
    radius += (width/4);
    
    
    NSLog(@"Updater.m: RADIUS: %f", radius);
    
    
    
    
    
    //    radius = width / 2;         // Fixed radius
    
    
    
    
    
    
    
    
    
    float w = width;
    float h = w;
    
    //    NSLog(@"Updater.m Line 417: WIDTH: %f", w);
    
    CGSize size = CGSizeMake(w, h);
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(!context) {
        NSLog(@"CONTEXT FAILED!");
        return nil;
    }
    
    
    CGGradientRef gradient;
    CGColorSpaceRef colorspace;
    //    CGFloat xlocations[3] = { 0.0, 0.7, 1.0};
    CGFloat xlocations[3] = { 0.0, 0.5, 1.0};
    
    //    CGFloat xlocations[3] = { 0.0, 0.2, 1.0};
    
    
    /*
     NSArray *colors = @[
     (id)[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:0.985].CGColor,
     (id)[UIColor colorWithRed:77.0f/255.0f green:101.0f/255.0f blue:181.0f/255.0f alpha:0.985*.6].CGColor,
     (id)[UIColor colorWithRed:77.0f/255.0f green:101.0f/255.0f blue:181.0f/255.0f alpha:0.0].CGColor,
     ];
     */
    /*
     NSArray *colors = @[
     (id)[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.985].CGColor,
     (id)[UIColor colorWithRed:77.0f/255.0f green:101.0f/255.0f blue:181.0f/255.0f alpha:0.985*.6].CGColor,
     (id)[UIColor colorWithRed:77.0f/255.0f green:101.0f/255.0f blue:181.0f/255.0f alpha:0.1].CGColor,
     ];
     */
    colorspace = CGColorSpaceCreateDeviceRGB();
    
    gradient = CGGradientCreateWithColors(colorspace,
                                          (CFArrayRef)colors, xlocations);
    
    CGPoint startPoint, endPoint;
    CGFloat startRadius, endRadius;
    
    float x = w/2;
    float y = w/2;
    
    startPoint.x = x;
    startPoint.y = y;
    endPoint.x = x;
    endPoint.y = y;
    startRadius = 0;
    //    endRadius = w/2;
    endRadius = radius;
    
    
    CGContextDrawRadialGradient (context, gradient, startPoint,
                                 startRadius, endPoint, endRadius,
                                 0);
    
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
    
}

- (EMUser*)getUserUpdatesWithCount:(int*)numOfUsers {
    
    static const int NUM_USERS = 9;
    
    EMUser *pUsers = malloc(NUM_USERS * sizeof(EMUser));
    if (NULL != pUsers) {
        
        /*
         NSDateComponents *comps = [[NSDateComponents alloc] init];
         [comps setDay:28];
         [comps setMonth:3];
         [comps setYear:2016];
         [comps setHour:1];
         [comps setMinute:1];
         [comps setSecond:1];
         
         NSCalendar *gregorian = [[NSCalendar alloc]
         initWithCalendarIdentifier:NSGregorianCalendar];
         NSDate *date = [gregorian dateFromComponents:comps];
         NSTimeInterval timeInterval = [date timeIntervalSinceReferenceDate];
         */
        
        
        pUsers[0].ID = 1;
        pUsers[0].numUsersInSet = 50;
        pUsers[0].timeCreated = [self getRandomTime:1];
        pUsers[0].location = MaplyCoordinateMakeWithDegrees(130.966667, 14.583333);
        
        
        pUsers[1].ID = 2;
        pUsers[1].numUsersInSet = 1;
        pUsers[1].timeCreated = [self getRandomTime:3];
        pUsers[1].location = MaplyCoordinateMakeWithDegrees(55.75, 37.616667);
        
        pUsers[2].ID = 3;
        pUsers[2].numUsersInSet = 1;
        pUsers[2].timeCreated = [self getRandomTime:6];
        pUsers[2].location = MaplyCoordinateMakeWithDegrees(-0.1275, 51.507222);
        
        pUsers[3].ID = 4;
        pUsers[3].numUsersInSet = 1;
        pUsers[3].timeCreated = [self getRandomTime:9];
        pUsers[3].location = MaplyCoordinateMakeWithDegrees(-66.916667, 10.5);
        
        pUsers[4].ID = 5;
        pUsers[4].numUsersInSet = 1;
        pUsers[4].timeCreated = [self getRandomTime:12];
        pUsers[4].location = MaplyCoordinateMakeWithDegrees(139.6917, 35.689506);
        
        pUsers[5].ID = 6;
        pUsers[5].numUsersInSet = 1;
        pUsers[5].timeCreated = [self getRandomTime:15];
        pUsers[5].location = MaplyCoordinateMakeWithDegrees(166.666667, -77.85);
        
        pUsers[6].ID = 7;
        pUsers[6].numUsersInSet = 1;
        pUsers[6].timeCreated = [self getRandomTime:18];
        pUsers[6].location = MaplyCoordinateMakeWithDegrees(-58.383333, -34.6);
        
        pUsers[7].ID = 8;
        pUsers[7].numUsersInSet = 1;
        pUsers[7].timeCreated = [self getRandomTime:21];
        pUsers[7].location = MaplyCoordinateMakeWithDegrees(-74.075833, 4.598056);
        
        pUsers[8].ID = 9;
        pUsers[8].numUsersInSet = 1;
        pUsers[8].timeCreated = [self getRandomTime:24];
        pUsers[8].location = MaplyCoordinateMakeWithDegrees(-79.516667, 8.983333);
        
        *numOfUsers = NUM_USERS;
    }
    
    return pUsers;
}

- (NSTimeInterval)getRandomTime:(int)minute {
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:minute];
    [comps setMonth:3];
    [comps setYear:2016];
    [comps setHour:1];
    [comps setMinute:minute];
    [comps setSecond:minute];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:comps];
    NSTimeInterval timeInterval = [date timeIntervalSinceReferenceDate];
    
    return timeInterval;
}

@end
