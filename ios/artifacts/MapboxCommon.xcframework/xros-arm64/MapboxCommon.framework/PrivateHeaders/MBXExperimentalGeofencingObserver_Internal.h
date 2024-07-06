// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>

@class MBXExperimentalGeofencingError;
@class MBXExperimentalGeofencingEvent;

NS_SWIFT_NAME(GeofencingObserver)
@protocol MBXExperimentalGeofencingObserver
- (void)onEntryForEvent:(nonnull MBXExperimentalGeofencingEvent *)event;
- (void)onDwellForEvent:(nonnull MBXExperimentalGeofencingEvent *)event;
- (void)onExitForEvent:(nonnull MBXExperimentalGeofencingEvent *)event;
- (void)onErrorForError:(nonnull MBXExperimentalGeofencingError *)error;
@end
