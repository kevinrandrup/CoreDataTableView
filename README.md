CoreDataTableView
=================

Eliminates boilerplate code involved with an NSFetchedResultsController and a UITableView.


Typical Usage

1. Create a reference to the tableview.
2. Open your storboard, create a tableview and set its class to CoreDataTableView.
3. Set the fetchedResultsController property and the coreDataTableViewDelegate property.
4. Implement the CoreDataTableViewDelegate protocol
5. Implement the one required method


Sample Implementation
=====================

    @interface MyViewController () <CoreDataTableViewDelegate>
    @property (nonatomic, weak) IBOutlet CoreDataTableView *tableView;
    @property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
    @end
    
    @implementation MyViewController
    
    - (void)viewDidLoad
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
        NSSortDescriptor *lastName = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
        NSSortDescriptor *firstName = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        [fetchRequest setSortDescriptors:@[lastName, firstName]];
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"age" cacheName:nil];

        self.tableView.fetchedResultsController = frc;
        self.tableView.coreDataTableViewDelegate = self;
    }

    - (void)configureCell:(UITableViewCell *)cell withObject:(NSManagedObject *)object forTableView:(CoreDataTableView *)tableView
    {
        NSString *firstName = [object valueForKey:@"lastName"];
        NSString *lastName = [object valueForKey:@"firstName"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }


More Stuff to do
================

Allows the user to delete a cell by swiping - removes the cell and the backing object in Core Data.

    self.tableView.swipeToDelete = YES;


Displays an edit button in the top left corner that toggles editing on and off.

    self.tableView.editable = YES;
    
    
Displays a plus button in the top right corner that creates a new NSManagedObject and calls the delegate method.

    self.tableView.addButton = YES;
    
    - (void)configureNewObject:(NSManagedObject *)object forTableView:(CoreDataTableView *)tableView
    {
        NSLog(@"New object: %@. Yay!", object);
    }


Allows the user to reorder cells when in edit mode.

    self.tableView.reOrderable = YES;
    
    - (void)tableView:(CoreDataTableView *)tableView didReOrderObject:(NSManagedObject *)object atIndexPath:(NSIndexPath*)sourceIndexPath toIndexPath:(NSIndexPath *)newIndexPath
    {
        object.order = newIndexPath.row; //Simplified, but you get the idea.
    }


Adds a search bar to search through the tableview. Implement the search predicate delegate method.

    self.tableView.searchBar = YES;

    - (NSPredicate *)predicateForString:(NSString *)searchString inTableView:(CoreDataTableView *)tableView;//Return a predicate for the given searchString
    {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.searchString contains[cd] %@", searchString];
        return searchPredicate;
    }


Self-explanatory methods

    - (void)accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath inTableView:(CoreDataTableView *)tableView;
    - (void)tableView:(CoreDataTableView *)tableView didSelectObject:(NSManagedObject *)object atIndexPath:(NSIndexPath *)indexPath;
    - (BOOL)tableView:(CoreDataTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
    - (BOOL)tableView:(CoreDataTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
    - (BOOL)tableView:(CoreDataTableView *)tableView shouldMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)proposedDestinationIndexPath;

