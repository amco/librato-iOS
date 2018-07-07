### Version 1.2.2

* Fixed issue when builded as static library using cocoapods

### Version 1.1.0

Upgrade to AFNetworking ~> 2.0 (iOS 7 only)

### Version 1.0.2

* Removed the `init` override in `LibratoMetric` to fix an issue where offline cached metrics could not be rehydrated


### Version 1.0.1

* Fixed an incorrect method signature with `groupNamed:context:` that was configured to return an `NSArray` instead of being `void`
* Fixed a misspelling in the `README`


### Version 1.0.0

This is a major revision which means **APIs will break**. It is not backwards compatible with 0.1.x releases. Code from 0.1.x branches will no longer be supported. Please update!

#### Demo Project

* Added descriptions and examples on how to use various features to demo project

#### Metrics

* Added `metricNamed:valued:` to `LibratoMetric` (https://github.com/amco/librato-iOS/commit/0e10150892820ab7185bbd7752a2ec564d0cc458)
* Added `metricNamed:valued:source:measureTime:` to `LibratoMetric` (https://github.com/amco/librato-iOS/commit/0e10150892820ab7185bbd7752a2ec564d0cc458)
* Fixed `metricTime` not being set when passed in via `metricNamed:valued:options:` (https://github.com/amco/librato-iOS/commit/0e10150892820ab7185bbd7752a2ec564d0cc458)
* Changed metrics to extend Mantle instead of `NSObject` (https://github.com/amco/librato-iOS/commit/e418ff7c1dd824c55529d0588ae6677a5a4b7062)
* Changed `isValidValue` from instance to class method
* Changed maximum metric age from one year to fifteen minutes (Librato Metric rules) (https://github.com/amco/librato-iOS/commit/53fbe0bee6a22e34b698f212d01a188ea40b9468)
* Added automatic collection of device, OS, app and Librato library metrics when a `Librato` instance is initialized (https://github.com/amco/librato-iOS/commit/5ce4d5d16b49dd5a09e21c5e09eb48881157c0d4)
* Fixed `LibratoClient.metrics` to report queued metrics instead of blank `NSDictionary`
* Fixed queue firing `removeAllObjects` when `clear`ing instead of overwriting with new `NSMutableDictonary` so dictionary children are `release`d. (https://github.com/amco/librato-iOS/commit/704c245a1710ac6989d13d8b54d50d24206d8c53)

#### Collections

* Added `LibratoMetricCollection` which contains metrics based on type and handles conversion of metrics into structured JSON (https://github.com/amco/librato-iOS/commit/704c245a1710ac6989d13d8b54d50d24206d8c53)

#### Initialization

* Added `NSAsserts` in Librato, LibratoMetric and LibratoGaugeMetric `init` to disable use in favor of their custom initialization methods (https://github.com/amco/librato-iOS/commit/ebc4dcd5ed976607f1e13acff5cdaa9fdcf26adb)

#### Submission

* Added `add:` interface which is preferred over `submit:`
* Changed manual submission to an optional command as queues are automatically submitted on a configurable interval (https://github.com/amco/librato-iOS/commit/fda9cbaeaa4525e61bff0c53932d94b2a6c47190)
* Added global block handlers for submission success and failure (https://github.com/amco/librato-iOS/commit/e3e095cb26579446400e9ac61a33fb9e940ef8da)
* Changed queue to clear just before firing submission instead of after successful submission to prevent accidental double submission (https://github.com/amco/librato-iOS/commit/5ce4d5d16b49dd5a09e21c5e09eb48881157c0d4)
* Note: Queue is not cached before clearing, would could be useful if submission fails to re-queue items

#### Offline

* Added prevention of metrics submission if device is offline  (https://github.com/amco/librato-iOS/commit/704c245a1710ac6989d13d8b54d50d24206d8c53)
* Added automatic queue submission when internet becomes available
* Added storage of queue in `NSKeyedArchiver` when app is backgrounded
* Added queue hydration via `NSKeyedArchiver` when app is brought to foreground

#### Group metrics

* Added `groupNamed:valued:` to convert an `NSDictionary` into an array of `LibratoMetric`s (https://github.com/amco/librato-iOS/commit/fa4a9a5cf525e6ed04192e41b8bb709e57612a57)
* Added `groupNamed:context:` to automatically prefix any metrics created in the context with the group name

#### Notification subscription

* Added ability of `Librato` to subscribe to notifications with `listenForNotification:context:` and perform given `context` when notification is caught (https://github.com/amco/librato-iOS/commit/4a7b5a974263b596bdaa1e74943c36d586b93f51)
* Added queue specific to Librato subscriptions for `dispatch_async`ing execution of assigned `context`

#### User agent

* Added custom user agent setting available in `Librato` (https://github.com/amco/librato-iOS/commit/24e9edbc8dc03546fb8976239503a4c3ce3aab52)
* Removed `agentIdentifier` from `LibratoClient`

#### Descriptions

* Added custom descriptions for Librato, LibratoClient, LibratoMetric, LibratoMetricCollection and LibratoQueue to aid debugging (https://github.com/amco/librato-iOS/commit/704c245a1710ac6989d13d8b54d50d24206d8c53)

#### Miscellaneous

* Removed numerous `NSLog`s. Sorry about the extra noise. (https://github.com/amco/librato-iOS/commit/474fe9a115ffe308eb2e858a93af0453568e76ad, https://github.com/amco/librato-iOS/commit/7433254602cdc3d3b6d9b755766a929b82d73805)

### Version 0.1.0

Initial commit and functionality

* Code available via CocoaPods

#### Metrics

* Create counter metric
* Create group metric, statistics automatically computed
* Name and source fields automatically cleaned and trimmed
* Custom prefix available to be applied to all metric names
* Values for all fields can be manipulated after initialization

#### Submission

* Metric types offered but `NSDictionary` data automatically parsed into appropriate Metric type and queued
* Metrics only queued until manual submission
* Only available parser is direct JSON parsing

#### Queue

* Add-only, no management
* Manual submission

#### Localization

* Error messages localized for English
