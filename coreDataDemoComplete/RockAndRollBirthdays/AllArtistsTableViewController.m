//
//  AllArtistsTableViewController.m
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

#import "AllArtistsTableViewController.h"
#import "Artist.h"
#import "ArtistDetailTableViewConrtoller.h"

@interface AllArtistsTableViewController(){
   
    IBOutlet UISearchBar *artistSearch;
    IBOutlet UIBarButtonItem *editArtistsButton;
}
@end

@implementation AllArtistsTableViewController

@synthesize birthdaysDB = _birthdaysDB;

// Create an NSFetchRequest to get all Artists and hook it up to our table via an NSFetchedResultsController
// (we inherited the code to integrate with NSFRC from CoreDataTableViewController)

- (void)setupFetchedResultsController:(NSString*) searchString // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"artist_name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    if (searchString){
        // create the predicate, you must add wildcards to a variable prior to substitution
        NSString *searchExp = [NSString stringWithFormat:@"*%@*", searchString];
        // Regular experssion format is defined by: http://userguide.icu-project.org/strings/regexp
        request.predicate = [NSPredicate predicateWithFormat:@"artist_name like[c] %@", searchExp];
    }
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.birthdaysDB.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupFetchedResultsController:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:@"UITextFieldTextDidChangeNotification" object:artistSearch];	
	artistSearch.delegate = self;
}

- (void)viewDidUnload
{
    editArtistsButton = nil;
   
    artistSearch = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [artistSearch resignFirstResponder];
    
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
	return YES;
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Artist Cell";
    
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

                                                                                                    
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         NSManagedObject *objectToDelete = [[self fetchedResultsController] objectAtIndexPath:indexPath];
         [self.fetchedResultsController.managedObjectContext deleteObject:objectToDelete];
         NSError *error = nil;
         [self.birthdaysDB.managedObjectContext save:&error];
         if (error){
             NSLog(@"ERROR deleting object from database: %@", error);
             return;
         }
        [self.tableView reloadData];         
     }
 }


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)editCell:(id)sender {
    
   
    BOOL shouldEdit = ![self.tableView isEditing];
    
    if (shouldEdit){
        
        [editArtistsButton setTitle:@"Done"];
    } else {
        [editArtistsButton setTitle:@"Edit"];
    }
    
    [self.tableView setEditing:shouldEdit animated:YES];
    
}




#pragma mark UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@", searchBar.text);
    [self setupFetchedResultsController:searchBar.text];
    if (searchText.length == 0){
        // Dismiss the search bar when text has no length after typing
        [artistSearch resignFirstResponder];
    }

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}



@end
