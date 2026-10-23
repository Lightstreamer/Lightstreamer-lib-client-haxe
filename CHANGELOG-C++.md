# Lightstreamer C++ Client Changelog

## Unreleased

**New:** Added support for `STALE` and `RESUME` item notifications through `SubscriptionListener.onItemStale` and `SubscriptionListener.onItemResume`, preserving cached values and snapshots.

**Changed (breaking):** Replaced the three-argument loss callback with `onItemLostUpdates(itemName, itemPos, lostUpdates, isOverflow)`. `isOverflow` is true for Server buffer overflow (`OV`) and false for Data Adapter loss (`LOST`); `lostUpdates` is -1 when the count is unavailable.

Second-level COMMAND stale, resume, and Data Adapter loss notifications are ignored. Second-level Server overflow continues through the unchanged `onCommandSecondLevelItemLostUpdates(lostUpdates, key)` callback. All new notifications participate in session-recovery counting and replay suppression.


## 1.0.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 25 Feb 2025*

Changed HTTP `Content-Type` header to use `text/plain` instead of `application/x-www-form-urlencoded`.


## 1.0.0-beta.1
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*May not be compatible with code developed with the previous version.*<br/>
*Made available on 29 Oct 2024*

Changed the behavior of the listener `ClientListener.onPropertyChange` to be called whenever the value of a property is changed by the server or by the user through a property setter.


## 1.0.0-alpha.1
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Made available on 30 Jul 2024*

First release of the Lightstreamer C++ Client SDK.