// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>
#import <MapboxCommon/MBXExperimentalGeofencingErrorType_Internal.h>

NS_SWIFT_NAME(GeofencingError)
__attribute__((visibility ("default")))
@interface MBXExperimentalGeofencingError : NSObject

// This class provides custom init which should be called
- (nonnull instancetype)init NS_UNAVAILABLE;

// This class provides custom init which should be called
+ (nonnull instancetype)new NS_UNAVAILABLE;

- (nonnull instancetype)initWithType:(MBXExperimentalGeofencingErrorType)type
                             message:(nonnull NSString *)message
                               extra:(nullable id)extra;

@property (nonatomic, readonly) MBXExperimentalGeofencingErrorType type;
@property (nonatomic, readonly, nonnull, copy) NSString *message;
/** Additional information */
@property (nonatomic, readonly, nullable, copy) id extra;


@end
