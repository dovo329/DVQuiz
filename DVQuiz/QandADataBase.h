//
//  QandADataBase.h
//  DVQuiz
//
//  Created by Douglas Voss on 4/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface QandADataBase : NSObject {
    sqlite3 *_database;
}

+ (QandADataBase *)database;
- (NSArray *)DVQuizQuestionInfos;

@end
