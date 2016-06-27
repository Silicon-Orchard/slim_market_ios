/*
     File: ProgressObserver.h
*/

@protocol ProgressObserverDelegate;

// This class is a helper class which implements KVO on the NSProgress cancel and completedUnitCount properties.
// This is useful for driving a UIProgressBar for exmaple
@interface ProgressObserver : NSObject

// Human readable name string for this observer
@property (nonatomic, readonly) NSString *name;
// NSProgress this class is monitoring
@property (nonatomic, readonly) NSProgress *progress;
// Delegate for receiving change events
@property (nonatomic, weak) id<ProgressObserverDelegate> delegate;

// Designated initializer
- (id)initWithName:(NSString *)name progress:(NSProgress *)progress;

@end

// Protocol for notifying listeners of changes to the NSProgress we are observing
@protocol ProgressObserverDelegate <NSObject>

// Called when there is a change to the completion % of the resource transfer
- (void)observerDidChange:(ProgressObserver *)observer;
// Called when cancel is called on the NSProgress
- (void)observerDidCancel:(ProgressObserver *)observer;
// Called when the resource transfer is complete
- (void)observerDidComplete:(ProgressObserver *)observer;

@end