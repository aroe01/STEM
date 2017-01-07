//
//  GSAlarm.h
//  Earth Mantra 2
//
//  Created by Ian on 5/22/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import "GameScene.h"

@interface GSAlarm : GameScene <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UITableView *tableView;

@end
