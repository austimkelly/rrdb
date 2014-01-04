//
//  Artist+Extension.h
//  RockAndRollBirthdays
//

#import "Artist.h"

@interface Artist (Extension)
+ (Artist *)artistWithName:(NSString *)name bands:(NSArray *)bands birth:(NSDate *)birth birthPlace:(NSString *)place death:(NSDate *)death url:(NSURL *)url inManagedContext:(NSManagedObjectContext *)context;

+ (Artist *)artistWithName:(NSString *)name birth:(NSDate *)birth inManagedContext:(NSManagedObjectContext *)context;
@end
