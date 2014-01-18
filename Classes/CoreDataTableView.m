//
//  CoreDataTableView.m
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

#import "CoreDataTableView.h"

@interface CoreDataTableView () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic) UISearchBar *aSearchBar;

@property (nonatomic) UIBarButtonItem *add;
@property (nonatomic) UIBarButtonItem *edit;

@end

@implementation CoreDataTableView
{
    NSPredicate *_searchlessPredicate;
}

- (void)setup
{
    self.delegate = self;
    self.dataSource = self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

#define DONE @"Done"
#define EDIT @"Edit"

- (UIBarButtonItem *)add
{
    if (_add) {
        return _add;
    }
    _add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    return _add;
}

- (UIBarButtonItem *)edit
{
    if (_edit) {
        return _edit;
    }
    _edit = [[UIBarButtonItem alloc] initWithTitle:EDIT style:UIBarButtonItemStylePlain target:self action:@selector(editing:)];
    return _edit;
}

- (void)setEditable:(BOOL)editable
{
    _editable = editable;
    if (editable) {
        [self.coreDataTableViewDelegate.navigationItem setLeftBarButtonItem:self.edit];
    }
    else [self.coreDataTableViewDelegate.navigationItem setLeftBarButtonItem:nil];
}

- (void)setAddButton:(BOOL)addButton
{
    _addButton = addButton;
    if (_addButton)
        self.coreDataTableViewDelegate.navigationItem.rightBarButtonItem = self.add;
}

- (void)setSearchBar:(BOOL)searchBar
{
    _searchBar = searchBar;
    if (_searchBar) {
        [self addSearchDisplayController];
    }
    if (self.searchBar) {
        [_aSearchBar setHidden:NO];
    }
    else if (!self.searchBar) {
        [self.aSearchBar setHidden:YES];
    }
}

- (void)editing:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:EDIT]) {
        [self setEditing:YES animated:YES];
        sender.title = DONE;
        sender.style = UIBarButtonItemStyleDone;
    }
    
    else if ([sender.title isEqualToString:DONE]) {
        [self setEditing:NO animated:YES];
        sender.title = EDIT;
        sender.style = UIBarButtonItemStylePlain;
    }
}

#pragma mark - FetchedResultsController

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    _fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
    if (![_fetchedResultsController.fetchedObjects count]) {
        NSError *error = nil;
        [_fetchedResultsController performFetch:&error];
        if (error) {
            NSLog(@"error: %@, user info: %@", error, [error userInfo]);
        }
    }
}

- (void)refresh
{
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error fetching saved data" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [errorAlert show];
    }
    [self reloadData];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *moc = self.fetchedResultsController.managedObjectContext;
    if (moc != nil) {
        if ([moc hasChanges] && ![moc save:&error]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.coreDataTableViewDelegate configureCell:cell withObject:managedObject forTableView:self];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.sectionIndex) {
        return self.fetchedResultsController.sectionIndexTitles;
    }
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.coreDataTableViewDelegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [self.coreDataTableViewDelegate tableView:self canEditRowAtIndexPath:indexPath];
    }
    if (self.editable || self.swipeToDelete) {
        return YES;
    }
    else return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.coreDataTableViewDelegate respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        return [self.coreDataTableViewDelegate tableView:self canMoveRowAtIndexPath:indexPath];
    }
    return self.reOrderable;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    if ([self.coreDataTableViewDelegate respondsToSelector:@selector(tableView:didReOrderObject:atIndexPath:toIndexPath:)]) {
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
        [self.coreDataTableViewDelegate tableView:self didReOrderObject:object atIndexPath:sourceIndexPath toIndexPath:newIndexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if ([self.coreDataTableViewDelegate respondsToSelector:@selector(tableView:shoudlMoveRowAtIndexPath:toIndexPath:)]) {
        if ([self.coreDataTableViewDelegate tableView:self shouldMoveRowAtIndexPath:sourceIndexPath toIndexPath:proposedDestinationIndexPath]) {
            return proposedDestinationIndexPath;
        }
        else return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([self.coreDataTableViewDelegate respondsToSelector:@selector(accessoryButtonTappedForRowWithIndexPath:inTableView:)]) {
        [self.coreDataTableViewDelegate accessoryButtonTappedForRowWithIndexPath:indexPath inTableView:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.coreDataTableViewDelegate respondsToSelector:@selector(tableView:didSelectObject:atIndexPath:)]) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self.coreDataTableViewDelegate tableView:self didSelectObject:object atIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    
    if (_swipeToDelete) {
        return UITableViewCellEditingStyleDelete;
    }

    return UITableViewCellEditingStyleNone;
}

#pragma mark - SearchBar
- (UISearchBar *)aSearchBar
{
    if (!_aSearchBar) {
        _aSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, self.bounds.size.width, 44)];
        _aSearchBar.delegate = self;
        _aSearchBar.placeholder = @"Search";
        return _aSearchBar;
    }
    return _aSearchBar;
}

- (void)addSearchDisplayController
{
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.aSearchBar contentsController:self.coreDataTableViewDelegate];
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    self.tableHeaderView = self.aSearchBar;
}

#pragma mark - SearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        self.fetchedResultsController.fetchRequest.predicate = nil;
    }
    else if ([self.coreDataTableViewDelegate respondsToSelector:@selector(predicateForString:inTableView:)]) {
        self.fetchedResultsController.fetchRequest.predicate = [self.coreDataTableViewDelegate predicateForString:searchText inTableView:self];
    }
    [self.fetchedResultsController performFetch:nil];
    [self reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (_searchlessPredicate == nil) {
        _searchlessPredicate = self.fetchedResultsController.fetchRequest.predicate;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.fetchedResultsController.fetchRequest.predicate = _searchlessPredicate;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.fetchedResultsController.managedObjectContext deleteObject:anObject];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self reloadData];
            break;
    }
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
    NSEntityDescription *entity = self.fetchedResultsController.fetchRequest.entity;
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:context];
    if ([self.coreDataTableViewDelegate respondsToSelector:@selector(configureNewObject:forTableView:)]) {
        [self.coreDataTableViewDelegate configureNewObject:newManagedObject forTableView:self];
    }
    else NSLog(@"Please implement - (void)configureNewObject:(NSManagedObject *)object;");
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self endUpdates];
}

@end
