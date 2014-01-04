//
//  Artist+Extension.m
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
