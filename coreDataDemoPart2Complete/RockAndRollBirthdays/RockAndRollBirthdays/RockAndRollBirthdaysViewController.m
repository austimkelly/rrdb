//
//  RockAndRollBirthdaysViewController.m
//  RockAndRollBirthdays
//


#import "RockAndRollBirthdaysViewController.h"
#import "Artist.h"
#import "Artist+Extension.h"
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

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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

#pragma mark UITableViewCell

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

@end
