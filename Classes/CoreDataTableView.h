//
//  CoreDataTableView.h
//  CoreDataTableView
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Kevin Randrup
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol CoreDataTableViewDelegate;

@interface CoreDataTableView : UITableView <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> //Default cell identifier is "Cell"
@property (nonatomic) UIViewController <CoreDataTableViewDelegate>* coreDataTableViewDelegate;

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
//Defaults are all NO
@property (nonatomic, getter = isEditable) BOOL editable; //Displays an edit button that puts the tableview into edit mode.
@property (nonatomic) BOOL addButton; //An add button is displayed in edit mdoe. ConfigureNewObject called when tapped;
@property (nonatomic, getter = isReOrderable) BOOL reOrderable; //Enables reordering. Implement didReOrderObject:atIndexPath:toIndexPath
@property (nonatomic) BOOL searchBar; //Adds a search bar. Implement predicateForString:inTableView:  - called when user types in search bar
@property (nonatomic, getter = canSwipeToDelete) BOOL swipeToDelete; //Deletes a cell and the object the cell is displaying when the cell is swiped.

@property (nonatomic) BOOL sectionIndex; //Displays the first letter of the section name on the right.

- (void)refresh; //Calls perform fetch, handles any errors, then reloads the tableview
- (void)saveContext; //Saves the NSManagedObjectContext and handles any error

@end


@protocol CoreDataTableViewDelegate <NSObject>
@required //Delegate must provide an method that returns an NSFetchedResultsController.
- (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object forTableView:(CoreDataTableView *)tableView;


@optional //CoreDataTableView implements the following UITableViewDelegate methods, if you want to keep those methods but still want to be notified of any of the following methods, implement them in the coreDataTableViewDelegate
- (void)accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath inTableView:(CoreDataTableView *)tableView;
- (void)tableView:(CoreDataTableView *)tableView didSelectObject:(NSManagedObject *)object atIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(CoreDataTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(CoreDataTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(CoreDataTableView *)tableView shouldMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)proposedDestinationIndexPath;

//Aditional features
- (NSPredicate *)predicateForString:(NSString *)searchString inTableView:(CoreDataTableView *)tableView;//Return a predicate for the given searchString
- (void)configureNewObject:(NSManagedObject *)object forTableView:(CoreDataTableView *)tableView; //Called when plus button tapped in edit mode
- (void)tableView:(CoreDataTableView *)tableView didReOrderObject:(NSManagedObject *)object atIndexPath:(NSIndexPath*)sourceIndexPath toIndexPath:(NSIndexPath *)newIndexPath;

@end

