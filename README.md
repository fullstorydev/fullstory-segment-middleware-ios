# FullStory Segment Middleware iOS

## Note: This project is currently under development. 
Segment is a customer data platform that unifies data collection and provides data to every team in your company. The middleware is a easy way to integrate FullStory with the Segment Analytics for iOS SDK.

With minimal code change, the FullStory Segment Middleware provide developers the ability to send Segment Analytics data to FullStory, and adding FullStory session replay links to Segment events.


### More information:
--- 
[Segment Middleware for iOS](https://segment.com/docs/connections/sources/catalog/libraries/mobile/ios/middleware/)

FullStory's KB Article: [FullStory Integration with Segment Technical Guide - Mobile](https://help.fullstory.com/hc/en-us/articles/360051691994-FullStory-Integration-with-Segment-Technical-Guide-Mobile-Beta-)


## Sending data to FullStory using Middleware
---

<br />

### Handle Login/Logout 

- Identify a user and their traits at login:

Similar to `FS.identify` Segment has an `Analytics.identify` API that lets you tie a user’s identity to their actions and recordings in order to help you understand their journey.

With this API, you can also record what Segment calls traits (`userVars` in FullStory) about your users, like their email, name, preferences, etc. 

The middleware automatically hook into Segment API: `Analytics.identify` that sends user ID and traits to FullStory

<br />

- Anonymize the user at logout

If your app supports login/logout, then you need to anonymize logged in users when they log out by calling `Analytics.reset` to clear Segment cache and anonymize this user. 

Alternatively, you can manually call `FS.anonymize` after Analytics.reset, see below section "Client side integration - Manual" for more information

<br />

### Custom events
Similar to identify, we can automatically hook into `Analytics.track` and `Analytics.screen` events and funnel the data to FullStory session replay.

Note that by default, no track or screen events are recorded as custom events. Learn more about our [Privacy by Default](https://help.fullstory.com/hc/en-us/articles/360044349073-FullStory-Private-by-Default) approach.

When initiating the middleware, allowlist the events that you would like to send to FullStory. If you wish to enable all events, set `allowlistAllTrackEvents` to true. See below section "Implementation Guide" for code examples.

We will log to FullStory that a Segment API is called but omit all data if the event is not allowlisted.

All custom events are searchable in FullStory. You can find and view sessions that match your search criteria.

 <br />

## Add FS session replay URL to Segment events using Middleware
---
With FullStory for Mobile Apps, you can retrieve a link to the session replay and attach it to any Segment event.

- By default we automatically insert the FullStory session replay URL as part of the Segment track and screen event properties, and all event contexts.

- Depending on the destinations, some may receive only properties, others may be able to parse information in event context.

- This enables you to receive FullStory session replay links at your destinations and easily identify and navigate to the session of interest.

- You can disable this behavior by setting enableFSSessionURLInEvent to false

<br />


## Implementation Guide: 
--- 
1. Before you begin, make sure you have both FullStory and Segment setup in your application: 
    - Add FullStory to your iOS app
    - Use CocoaPods to add to project:

      ```
      pod 'FullStorySegmentMiddleware', :git => 'https://github.com/fullstorydev/fullstory-segment-middleware-ios.git',:tag => '1.0'
      ```

    - Alternatively, download the files manually:
      - Add the files inside [FullStoryMiddleware](https://github.com/fullstorydev/fullstory-segment-middleware-ios/tree/sabrina/dev/FullStoryMiddleware)  to your iOS project


2. Add the middleware during the initialization of your segment analytics client to enable FullStory.

    - Create FullStoryMiddleware with appropriate settings 
      ```
      let fullStoryMiddleware: FullStoryMiddleware
            = FullStoryMiddleware.init(allowlistEvents:
                    ["Order Completed",
                      "Viewed Checkout Step",
                      "Completed Checkout Step"])

      // allow all events to be tracked by FS, default to false
      fsm.allowlistAllTrackEvents = true
      // allow FS session URL to be added in Segemnt event properties, default to true
      fsm.enableFSSessionURLInEvents = true
      // enable to send group traits as userVars, default to false
      fsm.enableGroupTraitsAsUserVars = true
      // enable to send FS custom events on screen event, default to false
      fsm.enableSendScreenAsEvents = true

      configuration.middlewares = [fsm]
      SEGAnalytics.setup(with: configuration)
      ```

3. Your integration is now ready. 
