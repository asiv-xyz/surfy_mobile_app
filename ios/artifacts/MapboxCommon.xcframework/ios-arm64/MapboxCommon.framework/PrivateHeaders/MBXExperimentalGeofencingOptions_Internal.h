// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(GeofencingOptions)
__attribute__((visibility ("default")))
@interface MBXExperimentalGeofencingOptions : NSObject

- (nonnull instancetype)init;

- (nonnull instancetype)initWithDefaultRadius:(uint32_t)defaultRadius
                     maximumMonitoredFeatures:(uint32_t)maximumMonitoredFeatures;

/** Custom radius for point geometries (in meters). */
@property (nonatomic, readonly) uint32_t defaultRadius;

/** Returns the maximum amount of monitored features. */
@property (nonatomic, readonly) uint32_t maximumMonitoredFeatures;


@end
