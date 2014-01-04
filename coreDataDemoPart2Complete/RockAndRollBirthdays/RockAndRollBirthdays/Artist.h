//
//  Artist.h
//  RockAndRollBirthdays
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Artist : NSManagedObject

@property (nonatomic, retain) NSString * artist_name;
@property (nonatomic, retain) NSString * bands_played;
@property (nonatomic, retain) NSString * birthplace;
@property (nonatomic, retain) NSString * birthdate;
@property (nonatomic, retain) NSString * died;
@property (nonatomic, retain) NSString * url;

@end
