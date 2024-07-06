// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>
#import <MapboxCommon/MBXExperimentalAddFeatureCallback_Internal.h>
#import <MapboxCommon/MBXExperimentalAddObserverCallback_Internal.h>
#import <MapboxCommon/MBXExperimentalClearFeaturesCallback_Internal.h>
#import <MapboxCommon/MBXExperimentalConfigureCallback_Internal.h>
#import <MapboxCommon/MBXExperimentalGetFeatureCallback_Internal.h>
#import <MapboxCommon/MBXExperimentalGetOptionsCallback_Internal.h>
#import <MapboxCommon/MBXExperimentalRemoveFeatureCallback_Internal.h>
#import <MapboxCommon/MBXExperimentalRemoveObserverCallback_Internal.h>
@class MBXFeature;

@class MBXExperimentalGeofencingOptions;
@protocol MBXExperimentalGeofencingObserver;

NS_SWIFT_NAME(GeofencingInterface)
@protocol MBXExperimentalGeofencingInterface
- (void)configureForOptions:(nonnull MBXExperimentalGeofencingOptions *)options
                   callback:(nonnull MBXExperimentalConfigureCallback)callback;
- (void)getOptionsForCallback:(nonnull MBXExperimentalGetOptionsCallback)callback;
- (void)addFeatureForFeature:(nonnull MBXFeature *)feature
                    callback:(nonnull MBXExperimentalAddFeatureCallback)callback;
- (void)getFeatureForIdentifier:(nonnull NSString *)identifier
                       callback:(nonnull MBXExperimentalGetFeatureCallback)callback;
- (void)removeFeatureForIdentifier:(nonnull NSString *)identifier
                          callback:(nonnull MBXExperimentalRemoveFeatureCallback)callback;
- (void)clearFeaturesForCallback:(nonnull MBXExperimentalClearFeaturesCallback)callback;
- (void)addObserverForObserver:(nonnull id<MBXExperimentalGeofencingObserver>)observer
                      callback:(nonnull MBXExperimentalAddObserverCallback)callback;
- (void)removeObserverForObserver:(nonnull id<MBXExperimentalGeofencingObserver>)observer
                         callback:(nonnull MBXExperimentalRemoveObserverCallback)callback;
@end
