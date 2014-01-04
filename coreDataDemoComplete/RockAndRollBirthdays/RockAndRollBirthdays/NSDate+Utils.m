//
//  NSDate+Utils.m
//  RockAndRollBirthdays
//
//The MIT License (MIT)
//
//Copyright (c) <2011-2014> <Fizzy Artwerks>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.
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
