//
//  RockAndRollBirthdaysViewController.m
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

#import "RockAndRollBirthdaysViewController.h"
#import "Artist+Extension.h"
#import "ArtistDetailTableViewConrtoller.h"
#import "NSDate+Utils.h"

@interface RockAndRollBirthdaysViewController () 

@property (nonatomic, strong) NSDate *selectedDate;

@end

@implementation RockAndRollBirthdaysViewController

@synthesize birthdaysDB = _birthdaysDB;
@synthesize selectedDate = _selectedDate;


// Create an NSFetchRequest to get all Artists and hook it up to our table via an NSFetchedResultsController
// (we inherited the code to integrate with NSFRC from CoreDataTableViewController)

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"artist_name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
   
    // Add predicate based on the current day and Month
    NSString *dateExp = [self.selectedDate convertDateToExcel_m_ddd];
    self.title = dateExp;
    dateExp = [dateExp stringByAppendingString:@"*"]; // add wildcard
    request.predicate = [NSPredicate predicateWithFormat:@"birthdate like %@", dateExp];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.birthdaysDB.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

//#define FAKE_DATA

- (void)useDocument
{
#ifdef FAKE_DATA
    // remove an existing database files
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.birthdaysDB.fileURL path]]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:self.birthdaysDB.fileURL error:&error];
    }
#endif
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.birthdaysDB.fileURL path]]) {
        // does not exist on disk, so create it
        NSLog(@"ERROR: We didn't find the DB. This should not happen: %@", self.birthdaysDB.fileURL.debugDescription);
        [self.birthdaysDB saveToURL:self.birthdaysDB.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSError *error = nil;
#ifdef FAKE_DATA
            // add some fake data
            [Artist artistWithName:@"Jimmy" birth:[NSDate date] inManagedContext:self.birthdaysDB.managedObjectContext];
            [Artist artistWithName:@"Homer" birth:[NSDate date] inManagedContext:self.birthdaysDB.managedObjectContext];
            [self.birthdaysDB.managedObjectContext save:&error];
#endif
            
            if (!error ) {
                [self setupFetchedResultsController];
            } else {
                NSLog(@"Error saving DB=%@", error);
            }            
        }];

    } else if (self.birthdaysDB.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.birthdaysDB openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
        }];
    } else if (self.birthdaysDB.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self setupFetchedResultsController];
    }
}


- (void)setBirthdaysDB:(UIManagedDocument *)birthdaysDB
{
    if (_birthdaysDB != birthdaysDB) {
        _birthdaysDB = birthdaysDB;
       [self useDocument];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.selectedDate = [NSDate date];
    
    if (!self.birthdaysDB){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"rrdb.sqlite"];
        // url is now "<Documents Directory>/rrdb.sqlite"
        self.birthdaysDB = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }

    // For a swipe in either direction, you need to add a swipe gesture recognizer for each direction individually!
    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doSwipe:)];
    swipeR.direction =  UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doSwipe:)];
    swipeL.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeR];
    [self.tableView addGestureRecognizer:swipeL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Birthday Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // ask NSFetchedResultsController for the NSMO at the row in question
    Artist *artist = [self.fetchedResultsController objectAtIndexPath:indexPath];
   
    // Then configure the cell using it ...
    cell.textLabel.text = artist.artist_name;
    cell.detailTextLabel.text = artist.bands_played;
    
    return cell;
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Details"]) {
        
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        Artist *artist = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [segue.destinationViewController setArtist:artist];
                
        // setup the animation for a page flip
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
        
        // commit the animations
        [UIView commitAnimations];
    } else if ([segue.identifier isEqualToString:@"All Artists"]){
        
        [[segue destinationViewController] setBirthdaysDB:self.birthdaysDB];
    }
}

- (IBAction)nextDate:(id)sender {
    // Increment one day in seconds
    self.selectedDate = [self.selectedDate dateByAddingTimeInterval:24*60*60];
    NSLog(@"%@", self.selectedDate);
    [self useDocument];
    [self.tableView reloadData];
}

- (IBAction)previousDate:(id)sender {
    // Use negative value, one day in seconds to decrement
    self.selectedDate = [self.selectedDate dateByAddingTimeInterval:-(24*60*60)];
    NSLog(@"%@", self.selectedDate);
    [self useDocument];
    [self.tableView reloadData];
}

- (void)doSwipe:(UISwipeGestureRecognizer *)swipe
{
    NSLog(@"%d", swipe.direction);
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft){
        [self nextDate:nil];
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionRight){
        [self previousDate:nil];
    }
}

@end
