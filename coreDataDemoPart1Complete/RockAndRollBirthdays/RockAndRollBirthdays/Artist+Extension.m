//
//  Artist+Extension.m
//  RockAndRollBirthdays
//

#import "Artist+Extension.h"

@implementation Artist (Extension)
+ (NSString *)stringForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    return [dateFormatter stringFromDate:date];
}

+ (Artist *)artistWithName:(NSString *)name bands:(NSArray *)bands birth:(NSDate *)birth birthPlace:(NSString *)place death:(NSDate *)death url:(NSURL *)url inManagedContext:(NSManagedObjectContext *)context
{
    Artist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
    artist.artist_name = [name copy];
    artist.bands_played = [bands componentsJoinedByString:@", "];
    artist.birthplace = [place copy];
    artist.birthdate = [self stringForDate:birth];
    artist.died = [self stringForDate:death];
    artist.url = [url absoluteString];
    
    return artist;
}

+ (Artist *)artistWithName:(NSString *)name birth:(NSDate *)birth inManagedContext:(NSManagedObjectContext *)context
{
    return [self artistWithName:name bands:nil birth:birth birthPlace:nil death:nil url:nil inManagedContext:context];
}

@end
