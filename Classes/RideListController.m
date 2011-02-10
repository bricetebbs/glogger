//
//  RideListController.m
//  glogger
//
//  Just manages a list of all the rides saved in the history
//
//  Created by Brice Tebbs on 7/27/10.
//  Copyright northNitch Studios, Inc. 2010. All rights reserved.
//

#import "RideListController.h"
#import "LiveRecordingViewController.h"


@implementation RideListController

@synthesize countCell;
#pragma mark -
#pragma mark View lifecycle


- (void)dealloc {
    [countCell release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];

     self.title = @"Recordings";
}


// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem; // This is the only reason we overrode this.

}


 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}
 

- (void)configureCell:(UITableViewCell *)cell forItem:(Recording *)item 
{
    
    nnCounterTableViewCell* ccell = (nnCounterTableViewCell*)cell;
    ccell.cellLabel.text = item.label;
    ccell.userData = item;
    
    NSInteger count = [item.samples count];
    
    [ccell.bumpButton setTitle: [NSString stringWithFormat:@"%d", count] forState:UIControlStateNormal]; 
}



- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	Recording *item = [fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell: cell forItem: item];
}



-(void)newValue: (double)value forCell: (nnCustomTableViewCell*)cell
{
    
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CounterItemCell";
    Recording *item = [fetchedResultsController objectAtIndexPath:indexPath];

    
    nnCounterTableViewCell* cell = ( nnCounterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"CustomTableCell" owner:self options:nil];
        cell  = countCell;
        cell.delegate = self;
    }
        // Configure the cell.
    [self configureCell:cell forItem:item];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    Recording* objectToEdit = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    // Don't allow deleting the active current recording
    if([adel.recordingManager.currentRecording objectID] == [objectToEdit objectID])
    {
        return NO;
    }
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Recording* objectToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
        
        // Don't allow deleting the active current recording
        if([adel.recordingManager.currentRecording objectID] == [objectToDelete objectID])
        {
            return;
        }
        
        // Delete the managed object for the given index path
        // We know the fetchedResultsController is use our base class's managedObject Context
        [self.coreDataManager deleteObject: objectToDelete];
        
        [self.coreDataManager saveContext];
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    // Create and setup a Live Record View for the selected item
    
    LiveRecordingViewController *mvc = [[LiveRecordingViewController alloc] 
                                       initWithNibName:@"LiveRecordingViewController" bundle: nil];
     
    mvc.preferenceManager = adel.preferenceManager;
    
    // Tell the recording manager this one is now current
    [adel.recordingManager setRecording:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
   
    [self.navigationController pushViewController:mvc animated:YES];

    [mvc release];
}

#pragma mark -
#pragma mark FetchRequest

// Overrides the one in the nnCoreDataTableViewController class

-(void)setupFetchRequest: (NSFetchRequest *)fetchRequest
{
    
    
    //
    // Setup the entity we are going to use for this list
    //
	NSEntityDescription *entity = [self.coreDataManager getEntityDescription:@"Recording"];
    
    
	[fetchRequest setEntity:entity];

    //
    // Setup how we are going to sort the list
    //
	NSSortDescriptor *dateDesciptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];   
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:dateDesciptor, nil];
    
	[fetchRequest setSortDescriptors:sortDescriptors];
    
	[dateDesciptor release];
	[sortDescriptors release];

}




@end

