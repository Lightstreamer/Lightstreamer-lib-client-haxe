# Lightstreamer C++ Client Changelog

## Unreleased

*Compatible with Lightstreamer Server since 8.0.0.*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Requires a Metadata Adapter based on the v9+ Java In-Process Adapter SDK. A pre-v9 Metadata Adapter requires `support_LiteralBased_subscriptions` to be enabled for that adapter (see compatibility notes below).*

**Changed (breaking):** Removed Item Group and Field Schema support, including `Subscription.setItemGroup`, `Subscription.getItemGroup`, `Subscription.setFieldSchema`, `Subscription.getFieldSchema`, `Subscription.setCommandSecondLevelFieldSchema`, and `Subscription.getCommandSecondLevelFieldSchema`. Migrate to explicit lists through the constructor or `setItems`/`getItems`, `setFields`/`getFields`, and `setCommandSecondLevelFields`/`getCommandSecondLevelFields`. Item and field lists must be configured before subscribing; constructing an initially unconfigured subscription remains supported.

**New:** Item and field names may now contain any character, including spaces, numeric-only names, reserved characters, and Unicode. Individual names must still be non-empty. This also applies to COMMAND second-level field names and item names derived from COMMAND keys.

**New:** Added Data Adapter and Metadata Adapter health notifications through `ClientListener.onDataAdapterStateChange(state, dataAdapterName)` and `ClientListener.onMetadataAdapterStateChange(state)`. Each received notification reports one of `started`, `disabled`, `resumed`, `restarted`, or `terminated`; pre-v9 Adapters may report only `started` and `terminated`.

**New:** Added support for `STALE` and `RESUME` item notifications through `SubscriptionListener.onItemStale` and `SubscriptionListener.onItemResume`.

**Changed (breaking):** Replaced the three-argument loss callback with `onItemLostUpdates(itemName, itemPos, lostUpdates, isOverflow)`. `isOverflow` is true for Server buffer overflow (`OV`) and false for Data Adapter loss (`LOST`); `lostUpdates` is -1 when the count is unavailable.

Second-level COMMAND stale, resume, and Data Adapter loss notifications are ignored. Second-level Server overflow continues through the unchanged `onCommandSecondLevelItemLostUpdates(lostUpdates, key)` callback.

**New:** Added support for session creation error `12`, reported through `ClientListener.onServerError` without retrying when the Metadata Adapter uses the pre-v9 Java In-Process Adapter SDK and does not support explicit-list subscriptions. The `support_LiteralBased_subscriptions` setting can restore compatibility subject to its documented conditions; this setting applies to the individual Adapter.

**New:** Documented subscription errors reported through `SubscriptionListener.onSubscriptionError` with v9+ Data Adapters:

- `6`: The subscription request cannot be evaluated because the Data Adapter is disabled.
- `63`: The Data Adapter refused the subscription.
- `64`: The Data Adapter threw an unchecked exception while managing the subscription request.


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