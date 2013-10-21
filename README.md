librato-iOS
===========

`librato-iOS` integrates with your iOS application (via [CocoaPods](http://cocoapods.org/)) to make reporting your metrics to [Librato](http://librato.com/) super easy. Reporting is done asynchronously and is designed to stay out of your way while allowing you to dig into each report's details, if you want.

Metrics are automatically cached while the network is unavailable and saved if the app closes before they're submitted. Don't worry about submitting metrics, we make sure they don't go missing before they can be handed off to Librato's service.

Currently iOS versions 6 and 7 are supported and the wonderful [AFNetworking](https://github.com/AFNetworking/AFNetworking) is used to handle network duties.

# Quick Start

After installing `librato-iOS` into your workspace with CocoaPods just create a Librato instance with your credentials and start adding metrics.

```objective-c
#import "Librato.h"

...
// The prefix is optional but recommended as it helps you organize across your different projects
Librato *librato = [Librato.alloc initWithEmail:@"user@somewhere.com" apiKey:@"abc123..." prefix:@""];

// You can provide an NSDictionary with values for the optional "source" and "measure_time" fields
LibratoMetric *filesOpened = [LibratoMetric metricNamed:@"files.opened" valued:@42 options:nil];
// Optional values can be set directly on the metric object as well.
// NOTE: The maximum age for any submitted metric is fifteen minutes, as dictated by Librato.
filesOpened.measureTime = [NSDate.date dateByAddingTimeInterval:-10];

[librato submit:filesOpened];
```

# Installation

In your `Podfile` add:

```
pod 'librato-iOS'
```

Then run `pod install`.

# Configuration

Configuring your Libratro instance's email and token is an exercise left to the implementer but keeping those values out of the code itself is always a good idea.

Suggested methods

* Compile-time replacement from a file containing project credentials (that is outside of source control)
* Decrypting values from a plist
* Choose your own adventure!

# Custom measurements

Two types of measurement are currently available: counts and groups. These act as single and aggregate points of information.

### Counter

This is the default metric type and requires only an NSString name and NSNumber value.

```objective-c
LibratoMetric *metric = [LibratoMetric metricNamed:@"downloads" valued:@42 options:nil];
```

Additionally, you can provide optional `source` and `measureTime`. The `source` is useful when reviewing data to determine from where measurements with the same name originate. The `measureTime` is automatically generated if not provided but you can set a unique time if you have events that occurred in the past and want to add them to the stack. Metrics must be marked as happening within the last year's time.

**Note**: Both `name` and `source` must be fewer than 255 characters and be composed of “A-Za-z0-9.:-_”. These values will automatically be sanitized and any invalid characters will be replaced with a dash.

These values can be provided in the `options` NSDictionary or stated explicitly after the object has been instantiated.

```objective-c
LibratoMetric *metric = [LibratoMetric metricNamed:@"downloads" valued:@42 options:@{@"source": @"the internet", @"measureTime": [NSDate.date dateByAddingTimeInterval:-(3600 * 24)]}];

// or...

LibratoMetric *metric = [LibratoMetric metricNamed:@"downloads" valued:@42 options:nil];
metric.source = @"the internet";
metric.measureTime = [NSDate.date dateByAddingTimeInterval:-(3600 * 24)]
```

Optionally, you can create one or more counters inline with an NSDictionary when submitting.

```objective-c
[<some librato instance> submit:@{@"downloads": @13, @"plutonium": @{@"value": @238, @"source": @"Russia, with love"}}];
```

### Grouping

Groups are aggregated metrics of multiple data points with related, meaningful data. These are created with an array of counter metrics.

```objective-c
LibratoMetric *bagelMetric1 = [LibratoMetric metricNamed:@"bagels" valued:@13 options:nil];
LibratoMetric *bagelMetric2 = [LibratoMetric metricNamed:@"bagels" valued:@10 options:nil];
LibratoMetric *bagelMetric3 = [LibratoMetric metricNamed:@"bagels" valued:@9 options:nil];
LibratoMetric *bagelMetric4 = [LibratoMetric metricNamed:@"bagels" valued:@8 options:nil];
LibratoMetric *bagelMetric5 = [LibratoMetric metricNamed:@"bagels" valued:@2 options:nil];
LibratoMetric *bagelMetric6 = [LibratoMetric metricNamed:@"bagels" valued:@1 options:nil];
LibratoMetric *bagelMetric7 = [LibratoMetric metricNamed:@"bagels" valued:@0 options:nil];
LibratoMetric *bagelMetric8 = [LibratoMetric metricNamed:@"bagels" valued:@0 options:nil];

NSArray *bagels = @[bagelMetric1, bagelMetric2, bagelMetric3, bagelMetric4, bagelMetric5, bagelMetric6, bagelMetric7, bagelMetric8];
LibratoGaugeMetric *bagelGuage = [LibratoGaugeMetric metricNamed:@"bagel_guage" measurements:bagels];
```

The `LibratoGroupMetric` automatically generates the count, sum, minimum, maximum and square values for the aggregate data for use in the reporting tool.

# Custom Prefix

There's an optional but highly-recommended prefix you can set which will automatically be added to all metric names. This is a great way to isolate data or quickly filter metrics.

# Offline Metric Gathering

If the device loses network availability all new metrics are cached until the network (WiFi or cell) becomes again available.

While offline every metric is stored in app memory so if memory consumption is a concern you may want to configure your app to reduce the amount of metrics gathered or turn off measurements after a certain amount have been gathered. Metrics themselves are very small so this should only be a concern if you're collecting many metrics per minute and will be offline for a lengthy period.

# Persisting Metrics

If the app caches metrics while offline and is then closed all cached metrics are stored in an `NSKeyedArchiver`. This archive is emptied into the queue the next time the app is opened. An `NSKeyedArchiver` is great for this purpose but it does not allow for any kind of querying of the data which means all archived metrics are blindly submitted, regardless of type or data.

# Contribution

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project and submit a pull request from a feature or bugfix branch.
* Please include tests. This is important so we don't break your changes unintentionally in a future version.
* Please don't modify the podspec, version, or changelog. If you do change these files, please isolate a separate commit so we can cherry-pick around it.

# Copyright

Copyright (c) 2013 Amco International Education Services, LLC. See LICENSE for more details.
