//
//  CMAJournal.m
//  AnglersLog
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMABait.h"
#import "CMAFishingMethod.h"
#import "CMAJournal.h"
#import "CMAJSONWriter.h"
#import "CMASpecies.h"
#import "CMAStorageManager.h"

@implementation CMAJournal {
    NSHashTable<id<CMAJournalChangeListener>> *_listeners;
}

@dynamic name;
@dynamic entries;
@dynamic userDefines;
@dynamic measurementSystem;
@dynamic entrySortMethod;
@dynamic entrySortOrder;

#pragma mark - Initialization

- (CMAJournal *)initWithName:(NSString *)aName {
    self.name = [aName capitalizedString];
    self.entries = [NSMutableOrderedSet orderedSet];
    self.userDefines = [NSMutableSet set];
    
    [self setMeasurementSystem:CMAMeasuringSystemTypeImperial];
    [self setEntrySortMethod:CMAEntrySortMethodDate];
    [self setEntrySortOrder:CMASortOrderDescending];
    
    return self;
}

- (void)handleModelUpdate {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"ModelVersion"] == MODEL_VERSION)
        return;
    
    NSLog(@"Updating journal for new model...");
    
    for (CMAEntry *e in self.entries)
        [e handleModelUpdate];
    
    for (CMABait *b in [self userDefineNamed:UDN_BAITS].baits)
        [b handleModelUpdate];
    
    [self archive];
    [[NSUserDefaults standardUserDefaults] setInteger:MODEL_VERSION forKey:@"ModelVersion"];
    
    NSLog(@"Done updating journal.");
}

- (void)initProperties {
    [self initUserDefines];
    [self initStatistics];
    
    for (CMAEntry *e in self.entries)
        [e initProperties];
    
    for (CMABait *b in [self userDefineNamed:UDN_BAITS].baits)
        [b initProperties];
}

// Initializes user define objects if they don't already exist. Used so the same CMAJournal object can be used if new defines are added later.
- (void)initUserDefines {
    if (![self userDefineNamed:UDN_SPECIES])
        [self addUserDefineNamed:UDN_SPECIES];
    
    if (![self userDefineNamed:UDN_BAITS])
        [self addUserDefineNamed:UDN_BAITS];
    
    if (![self userDefineNamed:UDN_FISHING_METHODS])
        [self addUserDefineNamed:UDN_FISHING_METHODS];
    
    if (![self userDefineNamed:UDN_LOCATIONS])
        [self addUserDefineNamed:UDN_LOCATIONS];
    
    if (![self userDefineNamed:UDN_WATER_CLARITIES])
        [self addUserDefineNamed:UDN_WATER_CLARITIES];
    
    for (id define in self.userDefines)
        [define sortByNameProperty];
    
    // remove duplicate names (fixes an earlier bug)
    [self removeDuplicateNames:[self userDefineNamed:UDN_BAITS]];
    [self removeDuplicateNames:[self userDefineNamed:UDN_LOCATIONS]];
}

// Adds a new CMAUserDefine object to [self userDefines].
- (void)addUserDefineNamed:(NSString *)aName {
    CMAUserDefine *define = [[CMAStorageManager sharedManager] managedUserDefine];
    [self.userDefines addObject:[define initWithName:aName andJournal:self]];
}

// Loops through entries and recounts statistical information. Used for compatibility with old archives.
- (void)initStatistics {
    // reset species
    CMAUserDefine *species = [self userDefineNamed:UDN_SPECIES];
    for (CMASpecies *s in [species activeSet]) {
        [s setNumberCaught:[NSNumber numberWithInteger:0]];
        [s setWeightCaught:[NSNumber numberWithInteger:0]];
        [s setOuncesCaught:[NSNumber numberWithInteger:0]];
    }
    
    // reset baits
    CMAUserDefine *baits = [self userDefineNamed:UDN_BAITS];
    for (CMABait *s in [baits activeSet]) {
        [s setFishCaught:[NSNumber numberWithInteger:0]];
    }
    
    // reset fishing spots
    CMAUserDefine *locations = [self userDefineNamed:UDN_LOCATIONS];
    for (CMALocation *l in [locations activeSet])
        for (CMAFishingSpot *f in [l fishingSpots])
            [f setFishCaught:[NSNumber numberWithInteger:0]];
    
    for (CMAEntry *e in self.entries)
        [self incStatsForEntry:e];
}

- (void)archive {
    [[CMAStorageManager sharedManager] saveJournal];
}

#pragma mark - Editing

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveValue:[[name capitalizedString] mutableCopy] forKey:@"name"];
    [self didChangeValueForKey:@"name"];
}

// Called when the "Done" button is tapped in the different "add scenes" throughout the app.
// For example, called in CMAAddEntryViewController.m's clickDoneButton event.
- (void)addSceneConfirmWithObject:(id)anObjToAdd
                        objToEdit:(id)anObjToEdit
                  checkInputBlock:(BOOL(^)(void))aCheckInputBlock
                   isEditingBlock:(BOOL(^)(void))anIsEditingBlock
                  editObjectBlock:(void(^)(void))anEditBlock
                   addObjectBlock:(BOOL(^)(void))anAddObjectBlock
                    errorAlertMsg:(NSString *)anErrorMsg
                   viewController:(id)aVC
                       segueBlock:(void(^)(void))aSegueBlock
                  removeObjToEdit:(BOOL)rmObjToEdit
{
    if (aCheckInputBlock()) {
        id notifyObject = nil;
        
        if (anIsEditingBlock()) {
            anEditBlock();
            [CMAStorageManager.sharedManager deleteManagedObject:anObjToAdd saveContext:YES];
            notifyObject = anObjToEdit;
        } else {
            if (!anAddObjectBlock()) {
                [CMAStorageManager.sharedManager deleteManagedObject:anObjToAdd saveContext:YES];
                return;
            }
            
            if (rmObjToEdit) {
                [CMAStorageManager.sharedManager deleteManagedObject:anObjToEdit saveContext:YES];
            }
            
            anObjToEdit = nil;
            notifyObject = anObjToAdd;
        }
        
        [self archive];
        
        // Note that this must be done here because this is where the user defined object is
        // actually saved to the journal. If done prior, the table view's data model won't be
        // completely up to date, and won't show the updated data.
        if ([notifyObject isKindOfClass:CMAUserDefineObject.class]) {
            [self notifyUserDefineDidChange:[notifyObject userDefine].name];
        } else if ([notifyObject isKindOfClass:CMAEntry.class]) {
            [self notifyEntriesDidChange];
        }
        
        aSegueBlock();
    } else {
        [CMAStorageManager.sharedManager deleteManagedObject:anObjToAdd saveContext:YES];
    }
}

- (BOOL)addEntry:(CMAEntry *)anEntry {
    if ([self entryDated:anEntry.date] != nil) {
        NSLog(@"Duplicate entry date.");
        return NO;
    }
    
    [self incStatsForEntry:anEntry];
    [anEntry setJournal:self];
    [self sortEntriesBy:self.entrySortMethod order:self.entrySortOrder];
    
    return YES;
}

- (void)removeEntryDated:(NSDate *)aDate {
    CMAEntry *entry = [self entryDated:aDate];
    
    // remove from core data
    [[CMAStorageManager sharedManager] deleteManagedObject:entry saveContext:YES];
    
    [self decStatsForEntry:entry];
    [self.entries removeObject:entry];
    
    [self notifyEntriesDidChange];
}

// removes entry with aDate and adds aNewEntry
// no need to keep the same instance since the reference doesn't need to be kept track of
- (void)editEntryDated:(NSDate *)aDate newProperties: (CMAEntry *)aNewEntry {
    [[self entryDated:aDate] edit:aNewEntry];
    [self sortEntriesBy:self.entrySortMethod order:self.entrySortOrder];
}

- (BOOL)addUserDefine:(NSString *)userDefineName objectToAdd:(id)obj notify:(BOOL)notify {
    if ([[self userDefineNamed:userDefineName] addObject:obj]) {
        if (notify) {
            [self notifyUserDefineDidChange:userDefineName];
        }
        return YES;
    }
    return NO;
}

- (void)removeUserDefine:(NSString *)aDefineName objectNamed: (NSString *)anObjectName {
    id obj = [[self userDefineNamed:aDefineName] objectNamed:anObjectName];
    
    // remove from core data
    if ([aDefineName isEqualToString:UDN_BAITS] && [obj imageData])
        [[CMAStorageManager sharedManager] deleteManagedObject:[obj imageData] saveContext:YES];
    
    [[CMAStorageManager sharedManager] deleteManagedObject:obj saveContext:YES];
    
    [[self userDefineNamed:aDefineName] removeObjectNamed:anObjectName];
    
    [self notifyUserDefineDidChange:aDefineName];
}

- (void)editUserDefine:(NSString *)userDefineName
           objectNamed:(NSString *)objName
         newProperties:(id)newObj
                notify:(BOOL)notify
{
    [[self userDefineNamed:userDefineName] editObjectNamed:objName newObject:newObj];
    [CMAStorageManager.sharedManager deleteManagedObject:newObj saveContext:YES];
    if (notify) {
        [self notifyUserDefineDidChange:userDefineName];
    }
}

#pragma mark - Listener Methods

- (void)addChangeListener:(id<CMAJournalChangeListener>)listener {
    if (_listeners == nil) {
        _listeners = [NSHashTable weakObjectsHashTable];
    }
    [_listeners addObject:listener];
}

- (void)removeChangeListener:(id<CMAJournalChangeListener>)listener {
    [_listeners removeObject:listener];
}

- (void)notifyEntriesDidChange {
    [self notifyListeners:@selector(entriesDidChange)];
    [self initStatistics];
}

- (void)notifyUserDefineDidChange:(NSString *)userDefineName {
    if ([userDefineName isEqualToString:UDN_BAITS]) {
        [self notifyListeners:@selector(baitsDidChange)];
    } else if ([userDefineName isEqualToString:UDN_LOCATIONS]) {
        [self notifyListeners:@selector(locationsDidChange)];
    } else if ([userDefineName isEqualToString:UDN_SPECIES]) {
        [self notifyListeners:@selector(speciesDidChange)];
    } else if ([userDefineName isEqualToString:UDN_FISHING_METHODS]) {
        [self notifyListeners:@selector(fishingMethodsDidChange)];
    } else if ([userDefineName isEqualToString:UDN_WATER_CLARITIES]) {
        [self notifyListeners:@selector(waterClaritiesDidChange)];
    }
    
    [self initStatistics];
}

- (void)notifyListeners:(SEL)selector {
    for (id listener in _listeners) {
        if ([listener respondsToSelector:selector]) {
            // By convention, listener methods do not return objects.
            // If they do, ARC will let them leak.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [listener performSelector:selector];
#pragma clang diagnostic pop
        }
    }
}

- (void)incStatsForEntry:(CMAEntry *)anEntry {
    // fish quantity
    if ([anEntry.fishQuantity integerValue] > 0)
        [anEntry.fishSpecies incNumberCaught:[anEntry.fishQuantity integerValue]];
    else
        [anEntry.fishSpecies incNumberCaught:1];
    
    // fish weight
    if ([anEntry.fishWeight integerValue] > 0) {
        [anEntry.fishSpecies incWeightCaught:[anEntry.fishWeight integerValue]];
        
        // handle ounces for imperial users
        if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
            if ([anEntry.fishOunces integerValue] > 0) {
                [anEntry.fishSpecies incOuncesCaught:[anEntry.fishOunces integerValue]];
                
                if ([anEntry.fishSpecies.ouncesCaught integerValue] >= OUNCES_PER_POUND) {
                    [anEntry.fishSpecies incWeightCaught:1];
                    [anEntry.fishSpecies decOuncesCaught:OUNCES_PER_POUND];
                }
            }
        }
    }
    
    // bait used
    if (anEntry.baitUsed) {
        if ([anEntry.fishQuantity integerValue] > 0)
            [anEntry.baitUsed incFishCaught:[anEntry.fishQuantity integerValue]];
        else
            [anEntry.baitUsed incFishCaught:1];
    }
    
    // location
    if ([anEntry.fishQuantity integerValue] > 0)
        [anEntry.fishingSpot incFishCaught:[anEntry.fishQuantity integerValue]];
    else
        [anEntry.fishingSpot incFishCaught:1];
}

- (void)decStatsForEntry:(CMAEntry *)anEntry {
    // quantity
    if ([anEntry.fishQuantity integerValue] > 0)
        [anEntry.fishSpecies decNumberCaught:[anEntry.fishQuantity integerValue]];
    else
        [anEntry.fishSpecies decNumberCaught:1];
    
    // weight
    if ([anEntry.fishWeight integerValue] > 0)
        [anEntry.fishSpecies decWeightCaught:[anEntry.fishWeight integerValue]];
    
    // fish weight
    if ([anEntry.fishWeight integerValue] > 0) {
        [anEntry.fishSpecies decWeightCaught:[anEntry.fishWeight integerValue]];
        
        // handle ounces for imperial users
        if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
            if ([anEntry.fishOunces integerValue] > 0) {
                [anEntry.fishSpecies decOuncesCaught:[anEntry.fishOunces integerValue]];
                
                if ([anEntry.fishSpecies.ouncesCaught integerValue] < 0) {
                    [anEntry.fishSpecies decWeightCaught:1];
                    [anEntry.fishSpecies incNumberCaught:OUNCES_PER_POUND];
                }
            }
        }
    }
    
    // bait used
    if (anEntry.baitUsed) {
        if ([anEntry.fishQuantity integerValue] > 0)
            [anEntry.baitUsed decFishCaught:[anEntry.fishQuantity integerValue]];
        else
            [anEntry.baitUsed decFishCaught:1];
    }
    
    // location
    if ([anEntry.fishQuantity integerValue] > 0)
        [anEntry.fishingSpot decFishCaught:[anEntry.fishQuantity integerValue]];
    else
        [anEntry.fishingSpot decFishCaught:1];
}

#pragma mark - Accessing

- (CMAUserDefine *)userDefineNamed:(NSString *)aName {
    for (CMAUserDefine *define in [self userDefines])
        if ([[define name] isEqualToString:aName])
            return define;
        
    return nil;
}

- (NSInteger)entryCount {
    return [self.entries count];
}

- (NSInteger)baitsCount {
    return self.baits.count;
}

// returns nil if no entry with aDate exist, otherwise returns entry with aDate
- (CMAEntry *)entryDated: (NSDate *)aDate {
    // calender stuff is needed so only certain date units are compared
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger calendarComponents = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute);
    
    NSDateComponents *aDateComponents = [calendar components:calendarComponents fromDate:aDate];
    aDate = [calendar dateFromComponents:aDateComponents];
    
    for (CMAEntry *entry in self.entries) {
        NSDateComponents *entryDateComponents = [calendar components:calendarComponents fromDate:entry.date];
        NSDate *entryDate = [calendar dateFromComponents:entryDateComponents];
        
        if ([entryDate isEqualToDate:aDate])
            return entry;
    }
    
    return nil;
}

- (NSString *)lengthUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_LENGTH_SHORTHAND;
        else
            return UNIT_IMPERIAL_LENGTH;
    }
    
    if (shorthand)
        return UNIT_METRIC_LENGTH_SHORTHAND;
    else
        return UNIT_METRIC_LENGTH;
}

- (NSString *)weightUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_WEIGHT_SHORTHAND;
        else
            return UNIT_IMPERIAL_WEIGHT;
    }
    
    if (shorthand)
        return UNIT_METRIC_WEIGHT_SHORTHAND;
    else
        return UNIT_METRIC_WEIGHT;
}

- (NSString *)depthUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_DEPTH_SHORTHAND;
        else
            return UNIT_IMPERIAL_DEPTH;
    }
    
    if (shorthand)
        return UNIT_METRIC_DEPTH_SHORTHAND;
    else
        return UNIT_METRIC_DEPTH;
}

- (NSString *)temperatureUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_TEMPERATURE_SHORTHAND;
        else
            return UNIT_IMPERIAL_TEMPERATURE;
    }
    
    if (shorthand)
        return UNIT_METRIC_TEMPERATURE_SHORTHAND;
    else
        return UNIT_METRIC_TEMPERATURE;
}

- (NSString *)speedUnitsAsString: (BOOL)shorthand {
    if (self.measurementSystem == CMAMeasuringSystemTypeImperial) {
        if (shorthand)
            return UNIT_IMPERIAL_SPEED_SHORTHAND;
        else
            return UNIT_IMPERIAL_SPEED;
    }
    
    if (shorthand)
        return UNIT_METRIC_SPEED_SHORTHAND;
    else
        return UNIT_METRIC_SPEED;
}

#pragma mark - User Define Accessing

- (NSMutableOrderedSet *)baits {
    return [self userDefineNamed:UDN_BAITS].activeSet;
}

- (NSMutableOrderedSet *)locations {
    return [self userDefineNamed:UDN_LOCATIONS].activeSet;
}

- (NSMutableOrderedSet *)fishingMethods {
    return [self userDefineNamed:UDN_FISHING_METHODS].activeSet;
}

- (NSMutableOrderedSet *)species {
    return [self userDefineNamed:UDN_SPECIES].activeSet;
}

- (NSMutableOrderedSet *)waterClarities {
    return [self userDefineNamed:UDN_WATER_CLARITIES].activeSet;
}

#pragma mark - Sorting

- (void)sortEntriesBy: (CMAEntrySortMethod)aSortMethod order: (CMASortOrder)aSortOrder {
    self.entrySortOrder = aSortOrder;
    self.entrySortMethod = aSortMethod;
    
    NSArray *sortedArray = nil;
    
    switch (self.entrySortMethod) {
        case CMAEntrySortMethodDate:
            sortedArray = [self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.date compare:e2.date];
            }];
            break;
            
        case CMAEntrySortMethodSpecies:
            sortedArray = [self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.fishSpecies.name compare:e2.fishSpecies.name];
            }];
            break;
        
        case CMAEntrySortMethodLocation:
            sortedArray = [self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                NSString *fullLoc1 = [NSString stringWithFormat:@"%@%@%@", e1.location.name, TOKEN_LOCATION, e1.fishingSpot.name];
                NSString *fullLoc2 = [NSString stringWithFormat:@"%@%@%@", e2.location.name, TOKEN_LOCATION, e2.fishingSpot.name];
                return [fullLoc1 compare:fullLoc2];
            }];
            break;
        
        case CMAEntrySortMethodLength:
            sortedArray = [self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.fishLength compare:e2.fishLength];
            }];
            break;
        
        case CMAEntrySortMethodWeight:
            sortedArray = [self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.fishWeight compare:e2.fishWeight];
            }];
            break;
        
        case CMAEntrySortMethodBaitUsed:
            sortedArray = [self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [e1.baitUsed.name compare:e2.baitUsed.name];
            }];
            break;
            
        case CMAEntrySortMethodResult:
            sortedArray = [self.entries sortedArrayUsingComparator:^NSComparisonResult(CMAEntry *e1, CMAEntry *e2){
                return [[NSNumber numberWithInteger:e1.fishResult] compare:[NSNumber numberWithInteger:e2.fishResult]];
            }];
            break;
            
        default:
            NSLog(@"Invalid CMASortMethod in [aCMAJournal sortEntriesBy].");
            break;
    }
    
    if (sortedArray)
        self.entries = [NSMutableOrderedSet orderedSetWithArray:sortedArray];
    
    // reverse the array order if needed
    if (self.entrySortOrder == CMASortOrderDescending) {
        self.entries = [[self.entries reversedOrderedSet] mutableCopy];
    }
}

#pragma mark - Filtering

- (NSMutableOrderedSet *)filterEntries:(NSString *)searchText {
    NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSet];
    
    for (CMAEntry *e in self.entries) {
        NSMutableArray *searchStrings = [NSMutableArray array];
        
        if (e.date)                     [searchStrings addObject:[e dateAsString]];
        if (e.fishSpecies)              [searchStrings addObject:e.fishSpecies.name];
        if (e.fishLength)               [searchStrings addObject:[e.fishLength stringValue]];
        if (e.fishWeight)               [searchStrings addObject:[e.fishWeight stringValue]];
        if (e.fishOunces)               [searchStrings addObject:[e.fishOunces stringValue]];
        if (e.fishQuantity)             [searchStrings addObject:[e.fishQuantity stringValue]];
        if (e.baitUsed)                 [searchStrings addObject:e.baitUsed.name];
        if (e.baitUsed &&
            e.baitUsed.baitDescription) [searchStrings addObject:e.baitUsed.baitDescription];
        if (e.location)                 [searchStrings addObject:e.location.name];
        if (e.fishingSpot)              [searchStrings addObject:e.fishingSpot.name];
        if (e.waterTemperature)         [searchStrings addObject:[e.waterTemperature stringValue]];
        if (e.waterClarity)             [searchStrings addObject:e.waterClarity.name];
        if (e.waterDepth)               [searchStrings addObject:[e.waterDepth stringValue]];
        if (e.notes)                    [searchStrings addObject:e.notes];
        [searchStrings addObject:(e.fishResult == CMAFishResultKept) ? @"Kept" : @"Released"];
        
        for (CMAFishingMethod *m in e.fishingMethods)
            [searchStrings addObject:m.name];
        
        for (NSString *str in searchStrings)
            if ([[str lowercaseString] containsString:[searchText lowercaseString]])
                [result addObject:e];
    }
    
    return result;
}

- (NSOrderedSet<CMABait *> *)filterBaits:(NSString *)searchText {
    return [self.baits filteredOrderedSetUsingPredicate:[NSPredicate predicateWithBlock:
            ^BOOL(CMABait *bait, NSDictionary<NSString *, id> *bindings) {
                return [bait containsSearchText:searchText];
            }]];
}

- (void)removeDuplicateNames:(CMAUserDefine *)aUserDefine {
    NSMutableOrderedSet *objs = [aUserDefine activeSet];
    NSMutableDictionary *frequencies = [NSMutableDictionary new];
    
    for (CMAUserDefineObject *obj in objs)
        if ([frequencies objectForKey:obj.name] == nil)
            [frequencies setObject:[NSNumber numberWithLong:1] forKey:obj.name];
        else
            [frequencies setObject:[NSNumber numberWithLong:[[frequencies objectForKey:obj.name] longValue] + 1] forKey:obj.name];
    
    // remove all objects with the same name (except one)
    for (NSString *key in frequencies)
        if ([[frequencies objectForKey:key] longValue] > 1)
            [self removeUserDefine:aUserDefine.name objectNamed:key];
}

#pragma mark - Visiting

- (void)accept:(id)aVisitor {
    [aVisitor visitJournal:self];
}

@end
