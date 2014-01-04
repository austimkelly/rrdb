//
//  NSDate+Utils.m
//  RockAndRollBirthdays
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

// Convert a given date from integers to the d-mmm-yy format used in excel. 
// You might get this format in an SQLite DB if you import a csv into excel and save it there, then create the SQLite DB.
// e.g. 1-Jan-99
- (NSString *)convertDateToExcel_m_ddd {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:self];
    
    static NSArray *monthNames = nil;
    
    if (!monthNames){
        monthNames = [NSArray arrayWithObjects:
                     @"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", 
                     @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil];
        
    }
    
    return [NSString stringWithFormat:@"%d-%@", dateComponents.day, [monthNames objectAtIndex:dateComponents.month - 1] ];
}

- (NSInteger)calculateAgeInYears {
    
    NSDate* now = [NSDate date];
    NSDate *birthDate = [self copy];
    
    // Check and see if the current date is in the future
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *birthDateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:self];
    NSDateComponents *nowDateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:now];
    
#warning DIRTY HACK: Just to account for a Y2K but from importing the data from Excel. We would not accept this in the real world ; )
    if (birthDateComponents.year > nowDateComponents.year) {
        NSTimeInterval oneYear = 365*24*60*60;
        birthDate = [birthDate dateByAddingTimeInterval:-(100*oneYear)];
    }
    
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] 
                                       components:NSYearCalendarUnit 
                                       fromDate:birthDate
                                       toDate:now
                                       options:0];
    return [ageComponents year];
    
}


@end
