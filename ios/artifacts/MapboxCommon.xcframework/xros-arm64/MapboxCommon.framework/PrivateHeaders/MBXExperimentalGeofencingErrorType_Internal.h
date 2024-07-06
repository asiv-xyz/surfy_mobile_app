// This file is generated and will be overwritten automatically.

#import <Foundation/Foundation.h>

// NOLINTNEXTLINE(modernize-use-using)
typedef NS_ENUM(NSInteger, MBXExperimentalGeofencingErrorType)
{
    /** Geofencing API object is not available. */
    MBXExperimentalGeofencingErrorTypeNotAvailable,
    /** Default radius is too large. */
    MBXExperimentalGeofencingErrorTypeDefaultRadiusTooLarge,
    /** Maximum amount of monitored features limit has been reached. */
    MBXExperimentalGeofencingErrorTypeMonitoredFeaturesLimitReached,
    /** Location Service API is unavailable. */
    MBXExperimentalGeofencingErrorTypeLocationServiceUnavailable,
    /** Location usage is not authorized by the user. */
    MBXExperimentalGeofencingErrorTypeLocationServiceUnauthorized,
    /** Location data is inaccurate. */
    MBXExperimentalGeofencingErrorTypeLocationServiceInaccurate,
    /** An error occurred in the device location provider. */
    MBXExperimentalGeofencingErrorTypeDeviceLocationProviderError,
    /** The given feature is already monitored. */
    MBXExperimentalGeofencingErrorTypeFeatureAlreadyAdded,
    /** The given feature is not being monitored. */
    MBXExperimentalGeofencingErrorTypeFeatureNotFound,
    /** The given feature is invalid. */
    MBXExperimentalGeofencingErrorTypeFeatureInvalid,
    /** The given geofence observer is already included. */
    MBXExperimentalGeofencingErrorTypeObserverAlreadyAdded,
    /** The given geofence observer is not found. */
    MBXExperimentalGeofencingErrorTypeObserverNotFound,
    /** The given feature could not be added to the permanent storage. */
    MBXExperimentalGeofencingErrorTypeFeatureNotStored
} NS_SWIFT_NAME(GeofencingErrorType);
