//
//  RideListController.h
//  glogger
//
//  A Controller for a list of Rides.
//  This is just a small customization of nnCoreDataTableViewController
//
//  Created by Brice Tebbs on 7/27/10.
//  Copyright northNitch Studios, Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nnCoreDataTableViewController.h"
#import "nnCounterTableViewCell.h"



@interface RideListController : nnCoreDataTableViewController  <UITextFieldDelegate,
                                                nnCustomTableViewCellDelegate>
{
    
    // this is basically here to be loaded in by a nib for the controller.
    // The Nib is owned by the TableviewController each time a new cell is needed and this gets populated
    nnCounterTableViewCell* countCell;
}



// Cell templates that get loaded in
@property (nonatomic, retain) IBOutlet nnCounterTableViewCell* countCell;



@end
