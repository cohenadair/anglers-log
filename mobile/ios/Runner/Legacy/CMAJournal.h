//
//  CMAJournal.h
//  AnglersLog
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CMAEntry.h"
#import "CMAConstants.h"
#import "CMAUserDefine.h"

@protocol CMAJournalChangeListener

@optional
- (void)entriesDidChange;
- (void)baitsDidChange;
- (void)locationsDidChange;
- (void)fishingMethodsDidChange;
- (void)speciesDidChange;
- (void)waterClaritiesDidChange;

@end

@interface CMAJournal : NSManagedObject

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSMutableOrderedSet *entries;
@property (strong, nonatomic)NSMutableSet *userDefines;         // set of CMAUserDefine objects
@property (nonatomic)CMAMeasuringSystemType measurementSystem;
@property (nonatomic)CMAEntrySortMethod entrySortMethod;
@property (nonatomic)CMASortOrder entrySortOrder;

// initializing
- (CMAJournal *)initWithName:(NSString *)aName;
- (void)handleModelUpdate;
- (void)initProperties;

- (void)archive;

// editing
- (void)addSceneConfirmWithObject:(id)anObjToAdd
                        objToEdit:(id)anObjToEdit
                  checkInputBlock:(BOOL(^)(void))aCheckInputBlock
                   isEditingBlock:(BOOL(^)(void))anIsEditingBlock
                  editObjectBlock:(void(^)(void))anEditBlock
                   addObjectBlock:(BOOL(^)(void))anAddObjectBlock
                    errorAlertMsg:(NSString *)anErrorMsg
                   viewController:(id)aVC
                       segueBlock:(void(^)(void))aSegueBlock
                  removeObjToEdit:(BOOL)rmObjToEdit;

- (BOOL)addEntry:(CMAEntry *)anEntry;
- (void)removeEntryDated:(NSDate *)aDate;
- (void)editEntryDated:(NSDate *)aDate newProperties:(CMAEntry *)aNewEntry;

- (BOOL)addUserDefine:(NSString *)userDefineName objectToAdd:(id)obj notify:(BOOL)notify;
- (void)removeUserDefine:(NSString *)aDefineName objectNamed:(NSString *)anObjectName;
- (void)editUserDefine:(NSString *)userDefineName
           objectNamed:(NSString *)objName
         newProperties:(id)newObj
                notify:(BOOL)notify;

- (void)addChangeListener:(id<CMAJournalChangeListener>)listener;
- (void)removeChangeListener:(id<CMAJournalChangeListener>)listener;

// accessing
- (CMAUserDefine *)userDefineNamed:(NSString *)aName;
- (NSInteger)entryCount;
- (CMAEntry *)entryDated:(NSDate *)aDate;
- (NSInteger)baitsCount;
- (NSString *)lengthUnitsAsString:(BOOL)shorthand;
- (NSString *)weightUnitsAsString:(BOOL)shorthand;
- (NSString *)depthUnitsAsString:(BOOL)shorthand;
- (NSString *)temperatureUnitsAsString:(BOOL)shorthand;
- (NSString *)speedUnitsAsString:(BOOL)shorthand;

// user define accessing
- (NSMutableOrderedSet *)baits;
- (NSMutableOrderedSet *)locations;
- (NSMutableOrderedSet *)fishingMethods;
- (NSMutableOrderedSet *)species;
- (NSMutableOrderedSet *)waterClarities;

// sorting
- (void)sortEntriesBy:(CMAEntrySortMethod)aSortMethod order:(CMASortOrder)aSortOrder;

// filtering
- (NSMutableOrderedSet *)filterEntries:(NSString *)searchText;
- (NSOrderedSet<CMABait *> *)filterBaits:(NSString *)searchText;

// visiting
- (void)accept:(id)aVisitor;

@end
