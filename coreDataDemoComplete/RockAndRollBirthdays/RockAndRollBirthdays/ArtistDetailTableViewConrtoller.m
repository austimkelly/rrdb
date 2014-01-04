//
//  ArtistDetailTableViewConrtoller.m
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

#import "ArtistDetailTableViewConrtoller.h"
#import "NSDate+Utils.h"
#import <Twitter/Twitter.h>

@interface ArtistDetailTableViewConrtoller ()

- (BOOL)validAttribute:(NSString * )attrib;

@property (nonatomic, strong, readonly) NSArray *values;

@end

@implementation ArtistDetailTableViewConrtoller

@synthesize artist = _artist;
@synthesize values = _values;

- (void)viewWillDisappear:(BOOL)animated {
    // setup the animation for a page flip
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    
    // commit the animations
    [UIView commitAnimations];

}

- (BOOL)validAttribute:(NSString * )attrib 
{
    BOOL isValid = FALSE;
    
    NSRange range = [attrib rangeOfString:@"??" options:NSCaseInsensitiveSearch];
    NSRange range2 = [attrib rangeOfString:@"--" options:NSCaseInsensitiveSearch];
    if (range.location == NSNotFound && range2.location == NSNotFound) {
        isValid = TRUE;
    }
    
    return isValid;
}

- (NSArray *)values
{
    if (!_values) {
        NSMutableArray *mutable = [NSMutableArray array];
        [mutable addObject:[NSArray arrayWithObjects:@"Artist Name", self.artist.artist_name, nil]];
        [mutable addObject:[NSArray arrayWithObjects:@"Birthdate", self.artist.birthdate, nil]];
        
        if ([self validAttribute:self.artist.birthplace]) {
            [mutable addObject:[NSArray arrayWithObjects:@"Birthplace", self.artist.birthplace, nil]];
        }
        
        if ([self validAttribute:self.artist.died]) {
            // Death date
            [mutable addObject:[NSArray arrayWithObjects:@"Died", self.artist.died, nil]];
        } else {
            // Still alive, calculate current age
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"dd-MMM-yy"];
            NSLog(@"%@", self.artist.birthdate.description);
            NSDate *birthdate = [formatter dateFromString:self.artist.birthdate];
            
            NSInteger yearsOld = [birthdate calculateAgeInYears];
            NSString *yearsOldString = [NSString stringWithFormat:@"%d", yearsOld];
            [mutable addObject:[NSArray arrayWithObjects:@"Current Age", yearsOldString , nil]];
        }
        
        if ([self validAttribute:self.artist.bands_played]) {
            [mutable addObject:[NSArray arrayWithObjects:@"Bands Played", self.artist.bands_played, nil]];
        }
        
        if ([self validAttribute:self.artist.url]) {
            [mutable addObject:[NSArray arrayWithObjects:@"Wikipedia link", self.artist.url, nil]];
        }
        
        NSLog(@"values=%@", mutable);
        
        _values = mutable;
    }
    return _values;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    id value = [self.values objectAtIndex:indexPath.row];
    cell.textLabel.text = [value objectAtIndex:0];
    cell.detailTextLabel.text = [value objectAtIndex:1];
    
    return cell;
}

- (IBAction)showURL:(UIBarButtonItem *)sender {
    NSURL *url = [NSURL URLWithString:self.artist.url];
    if (url.scheme.length < 4 || [url.scheme compare:@"http" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)] != NSOrderedSame) {
        NSArray *subs = [self.artist.artist_name componentsSeparatedByString:@" "];
        NSString *arg = [subs componentsJoinedByString:@"+"];
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/search?q=%@", arg]];
    }
    [[UIApplication sharedApplication] openURL:url];
}
- (IBAction)tweet:(id)sender {
    
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet = 
        [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"Happy Birthday %@!", self.artist.artist_name]];
	    [self presentModalViewController:tweetSheet animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"                                                          
                                  delegate:self                                              
                                  cancelButtonTitle:@"OK"                                                   
                                  otherButtonTitles:nil];
        [alertView show];
    }    
}

@end
