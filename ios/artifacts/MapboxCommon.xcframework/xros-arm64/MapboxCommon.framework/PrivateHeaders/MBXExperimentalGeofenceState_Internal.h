// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>
@class MBXFeature;

NS_SWIFT_NAME(GeofenceState)
__attribute__((visibility ("default")))
@interface MBXExperimentalGeofenceState : NSObject

// This class provides custom init which should be called
- (nonnull instancetype)init NS_UNAVAILABLE;

// This class provides custom init which should be called
+ (nonnull instancetype)new NS_UNAVAILABLE;

- (nonnull instancetype)initWithFeature:(nonnull MBXFeature *)feature
                              timestamp:(nullable NSDate *)timestamp
                                  extra:(nullable id)extra;

/** The feature linked to this event */
@property (nonatomic, readonly, nonnull) MBXFeature *feature;

/** The time when the geofence was activated. Null if the user is not within the geofence. */
@property (nonatomic, readonly, nullable) NSDate *timestamp;

/** Additional information */
@property (nonatomic, readonly, nullable, copy) id extra;


@end
