//
//  QandADataBase.m
//  DVQuiz
//
//  Created by Douglas Voss on 4/1/15.
//

#import "QandADataBase.h"
#import "DVQuizQuestion.h"

@implementation QandADataBase

static QandADataBase *_database;

+ (QandADataBase *)database {
    if (_database == nil) {
        _database = [[QandADataBase alloc] init];
    }
    return _database;
}

- (id)init {
    if ((self = [super init])) {
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"QandA"
                                                             ofType:@"sqlite3"];
        
        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
}


- (NSArray *)DVQuizQuestionInfos {
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT id, question, answerA, answerB, answerC, answerD, correctIndex FROM QandA ORDER BY id DESC";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //int uniqueId = sqlite3_column_int(statement, 0);
            char *questionChars = (char *) sqlite3_column_text(statement, 1);
            char *answerAChars = (char *) sqlite3_column_text(statement, 2);
            char *answerBChars = (char *) sqlite3_column_text(statement, 3);
            char *answerCChars = (char *) sqlite3_column_text(statement, 4);
            char *answerDChars = (char *) sqlite3_column_text(statement, 5);
            int correctIndex = sqlite3_column_int(statement, 6);
            NSString *question = [[NSString alloc] initWithUTF8String:questionChars];
            NSString *answerA = [[NSString alloc] initWithUTF8String:answerAChars];
            NSString *answerB = [[NSString alloc] initWithUTF8String:answerBChars];
            NSString *answerC = [[NSString alloc] initWithUTF8String:answerCChars];
            NSString *answerD = [[NSString alloc] initWithUTF8String:answerDChars];
            DVQuizQuestion *quizQuestion = [[DVQuizQuestion alloc] init:question
                answerA:answerA
                answerB:answerB
                answerC:answerC
                answerD:answerD
           correctIndex:correctIndex];
            
            [retval addObject:quizQuestion];
        }
        sqlite3_finalize(statement);
    }
    return retval;
}
@end
