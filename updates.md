# 🔄 Updates Log

This file tracks all update versions for both the **Mobile App**.

---

## ✅ Latest Versions:
- `mobileVersion = '9.11.x'`
---

## 📱 Mobile App Updates
<details>
<summary><strong>AV 9.10.54 – Profile UI Refactor & Null Safety Hardening</strong></summary>

### Profile Screen Refactor
* **Optimized Layout**: Replaced the root `Container` with `DecoratedBox` and redistributed horizontal margins as padding and inner margins for better performance and layout consistency.
* **Streamlined List Items**: Refactored the profile screen list item rendering by replacing manual `Column` and `Divider` compositions with a reusable `BottomVerticalCardListItemWidget`. This reduces code duplication and ensures consistent padding and styling.
* **Animation Improvements**: Added a smoother expansion animation to the `AuctionTileWidget` using `AnimatedSize` and implemented an animated rotation for the expansion icon with RTL support.

### Null Safety & Robustness
* **Enhanced Data Models**: Improved null safety and data parsing robustness across various data models (e.g., `CartSummaryResponse`, `VariantResponse`, `BusinessSettingsData`) by replacing unsafe `!.` assertions and `parse` calls with `?.` and `tryParse`.
* **Crash Prevention**: Addressed potential crash sources by adding default values and safe casting, ensuring the app remains stable even with unexpected API responses.

### API / Backend
* **No endpoint or schema changes.**

### Must Update (Stores)
* **No** — Client-side refactoring and stability improvements only.
</details>

<details>
<summary><strong>AV 9.10.53 – Improve Paymob Loading State and Standardize Payment Option Reset</strong></summary>

### Checkout Screen Refactoring (Fix)

* **Standardized Sub-Payment Reset**: Moved the logic for resetting `subPaymentOption` to an empty string (`''`) out of the `Builder` widget and into the main `setState` block within the `onPaymentMethodChange` handler.
    * This ensures the sub-payment selection is consistently cleared immediately upon selecting a different main payment gateway, preventing bugs where old sub-options might persist visually or logically.

***

### Paymob Integration (Feat/Enhancement)

* **Added Loading Indicator**: Implemented a visual loading state for the Paymob payment screen (`paymob_screen.dart`).
    * Introduced a new state variable, `isLoading`, initialized to `true`.
    * `isLoading` is set to `false` when the web view calls `onPageFinished`, indicating the payment page has fully loaded.
    * The `buildBody` method now uses a `Stack` to display a large, centered `CircularProgressIndicator` over the `WebViewWidget` while `isLoading` is true, providing clearer feedback to the user.
* **"Creating Order" Text Styling**: Updated the "creating order" message to use the `Theme.of(context).textTheme.headlineSmall` style for improved visibility and adherence to the app's theme.

***

### Must Update (Stores)

* No — This is a client-side logic and UI improvement.
</details>
<details>
<summary><strong>AV 9.10.52 – Filter Enabled Sub-Payments and Fix Coupon Text Field Layout</strong></summary>

### Data Model & Filtering (Payment Gateway)

* **Filter Disabled Sub-Payments**: The JSON deserialization logic for `PaymentTypeResponse` is refactored to explicitly **filter and exclude `SubPayment` entries where `status == false`**. This ensures the UI only displays active/enabled payment integrations.
    * This logic is applied inside `PaymentTypeResponse.fromJson` when mapping the `"integrations"` list.
* **Fix `SubPayment.status` Type**: Changed the type of `status` field in the `SubPayment` data model from `String?` to `bool?`.
    * Updated the `fromJson` factory to parse the incoming JSON status (which often comes as a string, e.g., `"1"`) into a proper boolean (`"${json['status']}" == "1"`).
    * Updated the `toJson` method to convert the `bool?` status back to a string `"1"` or `"0"` for API consistency.

***

### UI/UX Improvements (Checkout Screen)

* **Fixed Coupon Field Layout**: Wrapped the `Form` containing the coupon `TextFormField` in `buildApplyCouponRow` with a **`Flexible`** widget. This resolves potential overflow issues and ensures the coupon input field respects the row constraints.
* **Sub-Payment Auto-Selection**: Added logic within the checkout screen's payment method list to automatically select the single sub-payment option if only **one integration is available** for a selected payment method.
* **Code Clarity**: Renamed a local variable `integration` to `subPayment` in the checkout screen's `ListView.builder` for clarity when iterating over sub-payment options.

***

### API / Backend

* No endpoint or schema changes, but client-side models now enforce filtering based on the `status` field.

***

### Must Update (Stores)

* No — This is a client-side data model and UI logic update.
</details>

<details>
<summary><strong>AV 9.10.51 – Login UI Animation & Auth Screen Polish</strong></summary>

### Auth / UI
* Introduced **animated login transition** with `AnimatedCrossFade` and `AnimatedScale` for smoother UX.
* Added **toggleable login fields** controlled by `AppConfig.showFullLoginFields` (`bool`).
  * When `false`: shows a single “Login” button first.
  * When pressed, expands to show full fields (email/phone + password).
* Added **PopScope** logic to gracefully collapse fields on back press.
* Polished "Login with..." text:
  * Now animates size/color via `AnimatedDefaultTextStyle`.
  * Adjusts padding responsively with `AnimatedPadding`.
* Replaced red close icon with **white circular back icon** via `UsefulElements.backIcon`.

### Code
* `AppConfig`:
  * Added constant `showFullLoginFields` with full documentation.
* `login.dart`:
  * Cleaned controller disposals.
  * Extracted `loginWith(context)` builder.
* `auth_ui.dart`:
  * Updated cross button layout for LTR/RTL alignment.
  * Imported `useful_elements.dart`.

### API / Backend
* **No changes.**

### Must Update (Stores)
* **No** — client-side UX polish only.
</details>

<details>
<summary><strong>AV 9.10.50 – Mobile build upgrades: iOS 15 floor, Firebase/SDK bumps, and Flutter deps sync</strong></summary>

### Android

* Switched Firebase artifacts from **ktx** to base libs for **Auth/Analytics/Firestore** to align with BoM-managed versions.
* Kept **Firebase BoM 33.15.0**; retained **Messaging** and **Crashlytics NDK**.
* No changes to `minSdk`/`compileSdk`; desugaring unchanged.

### iOS

* Raised **deployment target to iOS 15.0** (`Podfile`).
* Updated Pods:

  * **Firebase 12.4.0** (Core / Crashlytics / Messaging)
  * **GoogleMaps 9.4.0**
  * **Facebook SDK 18.0.1**
  * **SDWebImage 5.21.3**
  * **Sentry Hybrid 8.56.2**
  * Added transitive **objective_c** pod
* Xcode project:

  * `objectVersion` → **77**
  * Cleared `DEVELOPMENT_TEAM` (set to empty)
  * Tidied `[CP]` script input/output lists
  * Runner scheme: **LaunchAction uses Release** build configuration

### Flutter Dependencies

* **firebase_core → 4.2.0**
* **firebase_messaging → 16.0.3**
* **firebase_crashlytics → 5.0.3**
* **connectivity_plus → 7.0.0**
* **fluttertoast → 9.0.0**
* **go_router → 16.3.0**
* Regenerated **pubspec.lock** to reflect all version changes.

---

### API / Backend

* **No endpoint or schema changes.**

---

### Must Update (Stores)

* **No** — build and dependency updates only.

---

### QA Checklist

* [ ] iOS/Android push notifications deliver and open correctly (foreground/background/terminated).
* [ ] Crash reports appear in Crashlytics with correct app version.
* [ ] Maps render on iOS (GoogleMaps 9.x) and Android without regressions.
* [ ] Facebook login still succeeds on both platforms.
* [ ] App launches on iOS 15+ devices/simulators; older (<15) correctly blocked by store settings.
* [ ] Smoke test navigation after `go_router` bump.
* [ ] No analyzer warnings from dependency updates.

---

### Notes

* After pulling, **clean & reinstall iOS pods**:

  * `cd ios && pod repo update && pod install --clean-install`
* On Android, run a **Gradle sync/clean**:

  * `./gradlew clean` then rebuild.

</details>

<details>
<summary><strong>AV 9.10.49 – Unify Pagination, Reuse Carousels, Stronger Typing & RTL Polish</strong></summary>

### UI & Pagination

* **Centralized infinite scroll:** Migrated products/brands/shops to a shared **`PagedView`** pattern with a reusable `dataBodyWidget<T>` helper.

  * Pull-to-refresh now performs a **silent refresh** (`showLoading: false`) for snappier UX.
  * Added `showLoading` support to internal `_loadFirstPage/_reset/_resetToFirstPage`.
* **Responsive grids:** `GridResponsive.aspectRatioForWidth(...)` accepts `maxSm/maxMd/maxLg` to fine-tune card aspect ratios per breakpoint.

### Search & Filter

* **Filter screen refactor:**

  * Replaced ad-hoc `ScrollController` logic and manual footers with **typed** `PagedViewController<Product/Brands/Shop>`.
  * Introduced `PageResult<T>` based loaders: `_fetchProducts`, `_fetchBrands`, `_fetchShops`.
  * Consistent empty states via `emptyBuilder` and unified padding.

### Media & Carousels

* **Reusable carousel:** Extracted **`CarouselItemCoverWidget`** and reused it in Product Details and Seller header.
* **Safer image lists:**

  * `productImageList` and seller `_carouselImageList` are now **`List<String>`**; null paths are ignored to prevent runtime issues.
  * Product Details only appends non-null photo paths.

### Components & Cards

* **Shop & Brand tiles:**

  * Hard-edge clipping + simplified image composition (less nesting) for **`ShopSquareCard`** and **`BrandSquareCard`**.
  * Layout polish: consistent symmetric paddings and card radii.

### RTL & Icons

* **Chevron icons:** Replaced multiple `CupertinoIcons.arrow_*` with platform-neutral `Icons.keyboard_arrow_*` and **directional paddings** (`EdgeInsetsDirectional`) across screens for better RTL behavior.

### Data Layer & Typing

* **`ShopRepository.getShops`** now returns **`ShopResponse`** (typed), not `dynamic`.
* Search widget’s `_shopList` strongly typed (`List<Shop>`), safer `slug/meta` null handling.

### Code Cleanup & Consistency

* Shared `dataBodyWidget<T>` reduces duplication for paged grid/list bodies.
* Removed scattered loading footers in favor of `PagedView` loading items & empty builders.

---

### API / Backend

* **No endpoint or schema changes.**

---

### Must Update (Stores)

* **No** — client-side refactors and UI polish only.

---

### Breaking Changes

* `ShopRepository.getShops(...)` → returns **`ShopResponse`**. Update any callers expecting `dynamic`.
* `ProductSliderImageWidget.productImageList` → **`List<String>?`** (was untyped `List?`).
* `GridResponsive.aspectRatioForWidth(...)` signature adds optional `maxSm/maxMd/maxLg` (defaults maintain previous behavior).

---

### QA Checklist

* [ ] Paged lists (products/brands/shops) paginate & refresh without duplicate spinners.
* [ ] Empty states show translated copy for each tab.
* [ ] Product slider opens full-screen photo; index/auto-play behaves as expected.
* [ ] Seller header carousel indicators sync with slides.
* [ ] RTL paddings/arrows render correctly across replaced screens.
* [ ] No analyzer warnings for nullability/typing in updated files.

</details>


<details>
<summary><strong>AV 9.10.48 – Centralize App Name Localization and Enhance Translation Utilities</strong></summary>

### Localization Refactor

* **App Name Decoupling:** Removed hardcoded static fields `app_name_ar` and `app_name_en` from `lib/app_config.dart`.
* **Dynamic App Name:** The application name, `appNameOnDeviceLang`, is now determined dynamically by leveraging a new translation utility to fetch the value associated with the generic key `"app_name"` based on the device's locale.
* **New Translation Utility:** Introduced `CustomLocalization.translateWithGivenLocale(String key, Locale locale)` to retrieve translations for an explicit locale.
* **String Extension:** Added the `String` extension method `trGivenLocale(Locale locale, {Map<String, String>? args})` to simplify fetching localized strings for a specific locale and supporting optional string interpolation.

***

### Code Cleanup & Consistency

* **Simplified `AppConfig`:** The removal of static name fields cleans up `lib/app_config.dart`.
* **Localization Abstraction:** Centralizing the logic for getting translations ensures a consistent approach across the application, making future language changes easier.

***

### API / Backend

* **No endpoint or schema changes.**

***

### Must Update (Stores)

* **Yes** — Localization files (`.arb` or equivalent) must be updated to include the `"app_name"` key for each supported language.
</details>

<details>
<summary><strong>AV 9.10.47 – Provider state refactor, module reorganization, and Equatable implementation</strong></summary>

### State Management (Provider Refactor)

* **Refactored `HomePresenter` to `HomeProvider`** (`lib/presenter/home_presenter.dart` renamed to `lib/presenter/home_provider.dart`). This migrates the home screen state management from a single `ChangeNotifier` to a modular Provider pattern using **`context.read`** and **`context.select`**.
* Updated almost all widget usages across the application (home screen templates, cart provider, auth screens) to access data and logic via `HomeProvider`.
* Extracted banner management logic into three new dedicated widgets: **`HomeBannersOne`**, **`HomeBannersTwo`**, and **`HomeBannersThree`** for cleaner composition.

### Code Cleanup & Consistency

* **`emptyWidget` Constant:** Introduced a global constant **`const SizedBox emptyWidget = SizedBox();`** in `lib/app_config.dart`. This constant is used extensively to replace direct usages of `const SizedBox()` for improved consistency and minor performance gains.
* **Data Model `Equatable`:** Implemented the `Equatable` package on several major data models to ensure reliable object comparison:
    * `Category`
    * `FlashDealResponseDatum`
    * `Product` (in `product_mini_response.dart`)
    * `AIZSlider`
    * `CurrentRemainingTime`
    * `SingleBanner`

### API / Backend

* **No endpoint or schema changes.**

### Must Update (Stores)

* **No** — Internal architecture and client-side code refactoring only.
</details>



<details>
<summary><strong>AV 9.10.46 – Release signing fix & legacy token migration</strong></summary>

### Android (Build)

* **Release signing**: switch `buildTypes.release.signingConfig` from **debug** → **release** in `android/app/build.gradle` to ensure proper signing for Play builds.
* No changes to minSdk/targetSdk or ProGuard rules.

### App Config

* `AppConfig`:

  * Added docs for `DOMAIN_PATH` usage.
  * New optional key: **`oldTokenKey`** — allows one-time migration of a previously stored auth token from `SharedPreferences` (legacy apps) to the new auth flow.

### Flutter (Bootstrap & Auth)

* `main.dart`:

  * Imports `shared_preferences`, `AuthRepository`, status helpers, and models.
  * New bootstrap step **`_getUserData()`** (runs during startup) to migrate legacy tokens:

    * Reads `SharedPreferences[AppConfig.oldTokenKey]`.
    * If present, sets `access_token`, calls `AuthRepository().getUserByTokenResponse()`.
    * On success: removes old key, persists user via `AuthHelper.setUserData(...)`, calls `saveFCMToken()`.
    * On failure: clears user data and reports via `recordError(e, st)`.
* Non-blocking; if `oldTokenKey` is empty or missing, app proceeds normally.

### API / Backend

* **No endpoint or schema changes.**
* Token validation reuses existing **getUserByToken** endpoint.

### Must Update (Stores)

* **No** — build/signing correction and silent token migration only (no manifest/plist changes, no user-visible behavior).

</details>


<details>
<summary><strong>AV 9.10.45 – Streaming downloads (no plugin), MediaStore export, and platform cleanup</strong></summary>

### Android

* Removed **flutter\_downloader** providers/custom initializer from `AndroidManifest.xml`.
* Deleted plugin notification strings from `res/values` & `values-ar`.
* Implemented native saver via `MethodChannel("media_store_saver")` in **`MainActivity.kt`**:

  * Saves to **Public Downloads** using **MediaStore** on Android 10+ (scoped storage).
  * Pre-Q fallback copies to `Environment.DIRECTORY_DOWNLOADS`.
  * Supports subfolder: `Downloads/<AppName>`, proper MIME types, and sanitized filenames.

### iOS

* Removed **flutter\_downloader** registration from `AppDelegate.swift`.
* Purged related pods from `Podfile.lock`.

### Flutter — Download stack (plugin-free)

* New streaming downloader (no external package):

  * `helpers/download/download_service.dart` – **HttpClient** with progress, speed, ETA, pause/resume/cancel, resume when server supports `Accept-Ranges`.
  * `helpers/download/download_paths.dart` – base dirs (Android temp, iOS Documents).
  * `helpers/download/media_store_saver.dart` – bridge to Android saver.
  * `providers/download_provider.dart` – state management for a single download task.
  * `ui_elements/adaptive_download_tile.dart` – reusable UI (progress bar + controls).
  * `screens/orders/download_bill.dart` – invoice download button with spinner/success state.
* Integrations:

  * `PurchasedDigitalProductCard` now shows progress and **Pause / Resume / Cancel**.
  * `OrderDetails` uses `<DownloadBill orderId=...>` instead of inline logic.
* Cleaned `ApiRequest`: removed download responsibilities (kept to pure HTTP).

### Error handling & misc

* Switched catches to `catch (e, st)` and `recordError(e, st)` across touched files for better crash reports.
* `Btn.basic` gains `disabledBackgroundColor` to avoid unwanted disabled tint.

### i18n

* Added EN/AR keys: `pause`, `resume`, `cancel`, `downloaded`, `download_canceled`, `saved_to`, `invoice_downloaded`.

### Dependencies

* Dropped `flutter_downloader` from `pubspec.yaml`.
* Minor transitive updates (`analyzer`, `build_runner`, `clarity_flutter`, `go_router`, etc.).
* Flutter SDK constraint bumped to **>= 3.35.0**.

### API / Backend

* **No endpoint or schema changes**.

### Must Update (Stores)

* **No** — native/manifest changes and user-visible download behavior.</details>


<details>
<summary><strong>AV 9.10.44 – Centralized downloads, digital items logic, and unified crash capture</strong></summary>

### Flutter — Downloads & Error Reporting

* **Centralized file downloads** in `ApiRequest.downloadFile(endPoint)`:

  * Initializes `FlutterDownloader` (registers callback) and isolates safely.
  * Creates platform-appropriate **Download** directory and requests storage permission when needed.
  * Passes **auth/headers** via `commonHeader`.
  * Shows localized toasts: `"download_started"` / `"download_failed"`.
* Replaced ad-hoc download code with the centralized helper:

  * **OrderDetails**: `_downloadInvoice(int id)` → `ApiRequest.downloadFile("/invoice/download/$id")`.
  * **PurchasedDigitalProductCard**: direct call to `ApiRequest.downloadFile("/purchased-products/download/<id>")`.
* **Crash capture**: added `recordError(e, StackTrace.current)` in multiple catch blocks:

  * `aiz_summer_note.dart`, `paged_view.dart`, `map_location.dart`, `product_details.dart`,
    `navigation_service.dart`, `execute_and_handle_remote_errors.dart`.
* `main.dart`:

  * Uses `AppConfig.isDebugMode` for `FlutterDownloader.initialize`.
  * Registers global downloader callback.
  * **Clarity**: renamed & expanded to `setCustomUserDataClarity()`; now sets `userId` and tags:
    `id`, `name`, `email`, `phone`, `language`. Updated call sites.

### Cart & Checkout (Digital items)

* **`CartItem`**:

  * New field: `isDigital` (parsed from `"is_digital"`), defaults to `false`.
  * `maxQuantity` now `999999` for digital items; otherwise `min(upperLimit, _maxQty ?? upperLimit)`.
* **Cart UI**:

  * Adjusted padding and **hide quantity controls** when `item.isDigital == true`.
* **ShippingInfo**:

  * For digital items with `quantity == 1`, show `price_ucf: <price>` instead of `qty × price = total`.

### Product Details

* Description overlay refactor:

  * Replaced fixed `Positioned.fill` with **`AnimatedPositioned`** for smoother “view more/less” transitions.
  * Added error reporting around `runJavaScriptReturningResult`.

### i18n

* Added keys (EN/AR):

  * `"download_started"`, `"download_failed"`, `"Newest"`, `"Oldest"`, `"Smallest"`, `"Largest"`.
* **UploadFile** sort labels now localized via `.tr()`.

### Cleanups

* Removed duplicated platform download helpers and scattered downloader init.
* Minor imports alignment (`main.dart` & others).

### API / Backend

* **No endpoint or schema changes.**

### Must Update (Stores)

* **No** – runtime behavior only (downloads/error capture/i18n). No manifest/plist changes in this patch.

</details>





<details>
<summary><strong>AV 9.10.43 – iOS Crashlytics & safer WebView link handling</strong></summary>

### iOS
- Added **Firebase Crashlytics** integration:
  - Pod dependencies (`Firebase/Crashlytics`, `FirebaseSessions`, `FirebaseRemoteConfigInterop`).
  - Xcode build phase **“Firebase Crashlytics”** run script.
  - Set `DEBUG_INFORMATION_FORMAT` to **dwarf-with-dsym** to ensure symbolicated reports.
- `Info.plist`: added `facetime` to **LSApplicationQueriesSchemes**.

### Flutter (WebView & Navigation)
- `CommonWebviewScreen` & `ProductDetails`:
  - Do **not** intercept navigation during the **initial page load**.
  - Intercept external/deep links **after** `onPageFinished` only.
- `NavigationService.handleUrls(...)`:
  - Now returns `Future<bool>` (true when handled).
  - Deep links to `${AppConfig.DOMAIN_PATH}` are routed via `GoRouter`.
  - Ignores paths containing `/mobile-page` to allow router fallback pages to render inside WebView.
  - External URLs launched via `url_launcher`; errors surface via `SnackBar`.

### API / Backend
- No endpoint or schema changes.

### Must Update (Stores)
- **Yes** — iOS native build config + user-visible link handling behavior.

</details>


<details>
<summary><strong>AV 9.10.42 – Monitoring & Error Tracking Integration</strong></summary>

### Features
- Integrated **Firebase Crashlytics (NDK)** for fatal error reporting.
- Added **Sentry** for extended monitoring (optional via `sentry_dsn` from Business Settings).
- Added **Microsoft Clarity** session recording (optional via `clarity_project_id`).
- Unified error handler: forwards Flutter and platform errors to Crashlytics and Sentry.
- Clarity sets `user_id` or `temp_user_id` when available.

### API / Backend
- `BusinessSettingsData` now maps optional keys:
  - `"sentry_dsn"` → `sentryDSN`
  - `"clarity_project_id"` → `clarityProjectId`
- No existing endpoint schema changes.

### Must Update (Stores)
- **No** – adds new monitoring behavior and Crashlytics NDK.

</details>

<details>
<summary><strong>AV 9.10.41 – External link handling & package visibility</strong></summary>

### Android
- Added **package visibility** queries for `mailto:`, `sms:`, `tel:`, `http:`, and `https:` under `android/app/src/main/AndroidManifest.xml` to ensure `url_launcher` can resolve external handlers on Android 11+.
- No runtime permission changes.

### iOS
- Updated **LSApplicationQueriesSchemes** in `ios/Runner/Info.plist` to include `mailto`, `ms-outlook`, `googlegmail`, `tel`, `sms`, `http`, `https`, `comgooglemaps`, and `waze` for safer `canOpenURL` checks.

### Flutter
- Hardened `NavigationService.handleUrls()` logic:
  - Treats router-relative paths (e.g., `/product/1?ref=...`) as in-app routes.
  - Routes links with host **`${AppConfig.DOMAIN_PATH}`** via `GoRouter`.
  - Opens all other schemes/hosts externally via `url_launcher` with `LaunchMode.externalApplication`.
  - Preserves translated error message on invalid URLs.

### API / Backend
- No endpoint or schema changes.

### Must Update (Stores)
- **Yes** – manifest/plist changes + user-visible link handling.

</details>

<details>
<summary><strong>AV 9.10.40 – OTP input LTR consistency</strong></summary>

### Why
Users on RTL locales (e.g., Arabic) saw OTP cells flow right-to-left, which is confusing for numeric codes.

### Changes
- Force LTR for OTP entry by wrapping `Pinput` with `Directionality(textDirection: TextDirection.ltr)`.

### UX
- OTP digits always fill from left to right, across locales.

### API / Backend
- No endpoint or schema changes.

### Store update required?
- **Yes** (client-side UX fix).

</details>

<!-- Update the Latest Versions block if you keep it in-sync -->

<details>
<summary><strong>AV 9.10.39 – Checkout settings & OTP flow polish</strong></summary>

### UI/UX
- Checkout: Show optional `checkout_message` above payment methods (auto RTL/LTR).
- Address: Conditionally hide **Email** (`hide_email_checkout`) and **Postal Code** (`hide_postal_code_checkout`) fields; validation adapts accordingly.

### Auth / Flow
- Registration: When OTP is required but no provider selected, refresh OTP providers and prompt selection.
- Routing: Simplified mail verification gating in `AIZRoute` (broader coverage).

### Cart
- Totals parsing made null-safe for currency code/symbol.

### Guest Checkout
- Send `email` only if non-empty; safer form prefill.

### API / Backend
- No endpoint changes. Client now consumes new business settings keys:
  - `hide_email_checkout`, `hide_postal_code_checkout`, `checkout_message`.

### Must Update (Stores)
- **No** – client-side UI/flow only.
</details>

<details>
<summary><strong>AV 9.10.38 – Filter grid stabilization & debug logging</strong></summary>

### UI/UX
- Filter: Replaced `MasonryGridView.count` with `GridView.builder` + `SliverGridDelegateWithFixedCrossAxisCount(2)` and fixed `childAspectRatio = 0.63` (centralized in `AppDimensions.productGridChildAspectRatio`) to stabilize the layout and reduce masonry-related issues during load-more.

### Infra / Debug
- `ProductRepository.getFilteredProducts`: Added `dart:developer log()` to print the response body for easier troubleshooting during development.

### API / Backend
- No changes to endpoints or schema.

### Must Update (Stores)
- **No** – UI layout and logging only.
</details>


<details>
<summary><strong>AV 9.10.37 – Home sliver pagination, masonry shimmer, and orders null-safety</strong></summary>

### UX / Performance
- Replaced nested scrolls with true **sliver-based** *All Products* section.
- Infinite scroll now uses `NotificationListener<ScrollUpdateNotification>` + `paginationListener(ScrollMetrics)` with prefetch at **80%** of scroll extent.
- Centered overlay loading container; **Masonry sliver** shimmer placeholders while loading more.
- Replaced `WillPopScope` with `PopScope` across home templates for safer back navigation.

### Tech
- New `ShimmerHelper.buildProductSliverGridShimmer()` for sliver grids.
- New `HomeAllProductsSliver` widget (replaces `HomeAllProducts2`) and `allProductsSliver(...)` helper.
- Removed `mainScrollController` / per-grid controllers in favor of metrics-based pagination.
- Guarded duplicate fetch when at exact `maxScrollExtent`.

### Orders
- `OrderRepository.getOrderItems()` now returns **OrderItemResponse** instead of dynamic.
- `OrderDetails`: typed list, null-safety for fields, uses `StringHelper.direction` for product name, safer price string.
- `Order` model: added color for **picked_up** status.

### Lists
- `OrderList`: initial skeleton now scrollable; switched to `ListView.separated` with `AlwaysScrollableScrollPhysics`.

### API impact
- **None** (no endpoint/path changes).

### Store update
- must update in play store or apple store: **Yes** fixes a client-side crash/assertion (Products not get with pagination successfully in home ).
</details>

<details>
<summary><strong>AV 9.10.36 - Fix: remove pirated logo ticker animation to prevent disposal crash</strong></summary>

### Bugfix
- Removed bouncing animation for “pirated” logo to stop `_WidgetTicker` assertion during language changes and rapid navigation.
- Replaced `AnimatedBuilder` with a static image.
- Cleaned up all calls to `initPiratedAnimation` and controller disposals.

### API
- No changes.

### Must update (Stores)
- **Yes** — fixes a client-side crash/assertion.
</details>

<details>
<summary><strong>AV 9.10.35 – Address & Auth UX hardening</strong></summary>

### Highlights
- Safe back navigation with `PopScope`: fallback to Home when users cannot pop.
- Global `Directionality` at app root; removed redundant screen wrappers.
- Address workflow:
  - Awaited auth persistence to avoid race conditions.
  - Prefetch addresses post-login/OTP/registration/guest flows.
  - Auto-redirect to Address screen only when required; back can be blocked until a default address is set.
  - Immediate in-memory default address assignment on selection.
  - Logout now clears default address state.

### UI/UX
- Filter: compact sort dialog (RadioGroup), AppBar polish, consistent borders; better search suggestion subtitles and text direction.
- Blog list: prevent title overflow.
- Profile: correct text direction for name/phone, safer loading dialog context.
- Misc: Useful `backButton(onPressed)`, home app bar address tap fixed, pagination guard formatting.

### API / Backend
- No endpoint or schema changes.

### Must Update (Stores)
- **Yes** – fixes user-visible navigation/state issues after login and ensures address requirement flow works reliably.
</details>



<details>
<summary><strong>AV 9.10.34 – Search & Filter UX polish</strong></summary>

### Helpers
- Extracted `shimmerInGrid(int)` in `lib/helpers/shimmer_helper.dart` and reused in grids.

### Search
- `lib/repositories/search_repository.dart`
  - GET `${AppConfig.BASE_URL}/get-search-suggestions?query_key=<q>&type=<type>`
  - Header: `App-Language` now dynamic:
    - If `query_key` non-empty → `query_key.langCode`
    - Else → `app_language.$!`
  - Response schema unchanged. Expected codes: 200 / 4xx / 5xx (unchanged).

### Filter Screen
- Unified loading containers to show “no more …” only when data finished.
- Show shimmer placeholders at the end of lists while loading more.
- TypeAhead wired with controller and submit via `onSearch`.

### i18n
- No new keys. Stopped using `loading_more_*_ucf` in filter.

### Must Update (Stores)
- No.
</details>


<details>
<summary><strong>AV 9.10.33 – Product details description render fix</strong></summary>

### Bug Fix
- Ensure product **description** height is measured only **after** the HTML is injected and the first frame is rendered.
- Removed artificial delay from `getDescriptionHeight()` and eliminated early post-frame measure in `initState`.
- Effect: fixes cases where the description collapsed (height=0) and remained invisible on first open.

### UX / Stability
- `HomePresenter`: safer load-more condition when `totalAllProductData` is null.
- `MiniProductCard`: remove unused rating import/variable to keep `flutter analyze` clean.

### API / Store
- **No endpoint changes**.
- **must update in play store or apple store: yes** (fixing a Flutter client bug against a working endpoint).

</details>


<details>
<summary><strong>AV 9.10.32 – Multi-OTP provider flow & safer navigation</strong></summary>

### Auth / OTP
- Added optional OTP provider support across **registration**, **login**, **password reset**, and **guest checkout** flows.
- `Otp` screen now accepts `isPhone`, `emailOrPhone`, and initial `provider` and auto-submits on completion.
- Android: resilient SMS User Consent (retry on failure); iOS keeps one-time-code hint.
- Resend timer increased to **90s**.

### Routing / UX
- `AIZRoute.push/slideLeft/slideRight` extended to accept OTP context (`emailOrPhone`, `provider`, `isPhone`) and auto-redirect to OTP when needed.
- Error screen back behavior hardened: respects `Navigator.canPop(context)` before allowing pop.

### i18n
- New key: `please_select_otp_provider` (en/ar).

### API / Store
- **POST** `/auth/signup` — client optionally sends `"otp_provider"` when `mustOtp` is enabled. Expected: `200 OK` or validation errors.
- **GET** `/auth/resend_code` — now supports query `?otp_provider={type}` when provided. Expected: `200 OK` (boolean `result` + `message`).
- must update in play store or apple store: **no** (client-side flow & UX only; optional request fields).

### Notes
- **Breaking (internal):** Call sites that navigate to OTP should use the new `AIZRoute` signatures or pass `null`/`false` defaults.
- Widgets: new reusable `SelectOTPProviderWidget`; `OtpInputWidget` gains `isDigitOnly`.

</details>


<details>
<summary><strong>AV 9.10.31 – OTP input revamp & Flutter 3.35.2 polish</strong></summary>

### Auth / OTP
- Replaced `sms_autofill` with `pinput` + `smart_auth` (Android User Consent API).
- New `OtpInputWidget` and `OtpInputController` with auto-fill (Android) and iOS one-time-code hint.
- Added `otp_provider` field to password-forget flow; selectable provider UI.

### UX
- Highlight selected 3rd-party login option.
- `Loading.show(context, canPop)` to allow/deny dismiss; safer `close()`.

### Infra
- Logging via `dart:developer log` in API POST.

### API / Store
- Endpoint: `POST /auth/password/forget_request`—request may include `"otp_provider": "<provider-type>"`.
- must update in play store or apple store: **no** (feature-level changes without breaking endpoints).

</details>


<details>
<summary><strong>AV 9.10.30 – Flutter 3.35.2 platform/tooling upgrades</strong></summary>

### Build System
- Android: compileSdk **36**, AGP **8.6.0**, Kotlin **2.1.0**, Google Services **4.4.3**.
- iOS: MinimumOSVersion **13.0**, updated Runner scheme (LLDB init + GPU validation).

### Dependencies
- Firebase BoM **33.15.0**, `firebase-messaging` managed via BoM.
- Google Play Services Auth **21.3.0**.
- Dart `intl` **0.20.2**.

### Notes
- Regenerate lockfiles with `dart pub get` and `pod install`.

### API / Store
- No API changes.
- must update in play store or apple store: **no** (tooling upgrades only).

</details>

<details>
<summary><strong>AV 9.10.29 – Search term highlighting in products & suggestions</strong></summary>

### UX
- Highlight matching search terms in product names across Brand, Category, and Wishlist grids.
- TypeAhead suggestions now highlight the typed text (title + subtitle).
- No visual change when the search box is empty.

### Tech
- New reusable `HighlightedSearchedWord` widget powered by `highlight_text` (v1.8.0).
- `ProductCard` now accepts optional `searchedText` and callers pass current `_searchKey`.

### API impact
- None.

### Store update
- **No** (UI-only enhancement).

</details>

<details>
<summary><strong>AV 9.10.28 – UX – Paged list controller & category search flow</strong></summary>

### Frontend
- Added `PagedViewController` to control `PagedView` (refresh/reset/loadNextPage/jumpToTop).
- Improved `PagedView` lifecycle: safely jump to top before reloading first page to avoid Masonry layout assertions; re-attach controller on widget updates.
- Category products screen now uses `PagedViewController` + `Debouncer` and `PopScope` to provide smoother search and back navigation.

### API impact
- None.

### Store update
- **No** (internal UI/UX enhancements).
</details>

<details>
<summary><strong>AV 9.10.27 – Normalize CartItem.shippingCost type</strong></summary>

### Model
- Changed `CartItem.shippingCost` type from `int?` to `double?` with safe JSON parsing to accept both integer and floating values.

### Impact
- Internal refactor only; verified `CartItem.shippingCost` is **not referenced** anywhere else in the app (project-wide search across `lib/`).

### Store update
- **No** (non-user-facing model normalization; no behavioral change).

</details>

<details>
<summary><strong>AV 9.10.26 – Android build: 16KB alignment & Java 17</strong></summary>

### Build System
- Pin NDK r28 and upgraded AGP to 8.5.1 to support default 16KB zip alignment on uncompressed `.so` files.
- Moved Java/Kotlin to 17 (`sourceCompatibility`/`targetCompatibility`/`jvmTarget=17`).
- Enabled core library desugaring; added `com.android.tools:desugar_jdk_libs:2.1.4`.
- Set `packagingOptions.jniLibs.useLegacyPackaging=false` to keep modern packaging.
- Removed `jcenter()` from repositories.

### Notes
- No app code or API changes.
- Store update: **no** (build/infra only).
</details>


<details>
<summary><strong>AV 9.10.25 – Profile refresh on return & dependency updates</strong></summary>

### UX
- Enabled `onPopped(value)` after returning from `ProfileEdit` so the Profile screen refreshes user data immediately.

### Dependencies
- Bumped multiple packages (e.g., `permission_handler` 12.x, `share_plus` 11.x, `flutter_local_notifications` 19.x, `sign_in_with_apple` 7.x, `package_info_plus` 8.x, `image_picker` 1.2.0, etc.). See `pubspec.yaml`/`pubspec.lock` for exact versions.

### Notes
- No API changes.
- Store update: **no** (minor UX refresh + dependency bumps).
</details>




<details>
<summary><strong>AV 9.10.24 – Dynamic OTP providers & login flow</strong></summary>

### Features
- Added dynamic OTP login providers fetched at app startup.
- Login screen now renders provider-specific OTP buttons with icon (network or local fallback) and label.

### API
- **GET** `/api/v2/activated-otp-login` → returns list of providers (`id`, `type`, `send_otp_text`, `image`). Expected: `200 OK`, JSON array.
- **POST** `/api/v2/auth/send-otp` → request body now includes `"provider"`. Expected: `200 OK` with `LoginResponse` (`result`, `message`, ...).

### i18n
- Added `by` key used to show “By {provider}” on OTP login header.

### Notes
- No breaking changes to existing endpoints.
- Store update: **no** (feature uses new endpoints; client-side addition only).
</details>

<details>
<summary><strong>AV 9.10.23 – Profile & Auth UI visual polish</strong></summary>

### UI/UX
- Added a subtle shadow (`spreadRadius: 0.08`) to profile containers and the Auth UI form card.
- Streamlined the classified section visibility condition with login check.
- Reworked the privacy policy entry and gated the "Delete my account" section behind a divider only when logged in.

### Notes
- No API changes.
- Store update: **no** (visual tweaks only).
</details>

<details>
<summary><strong>AV 9.10.22 – Router fallback to WebView + domain update</strong></summary>

### Routing
- Added `errorPageBuilder` to `GoRouter` that opens unknown routes in `CommonWebviewScreen` with `backHome=true` and URL `${RAW_BASE_URL}/mobile-page{path}`.
- `CommonWebviewScreen` now intercepts navigation and forwards it to `NavigationService` (deep links use router; external links use `url_launcher`).
- Back behavior: go back within WebView if possible; otherwise navigate to `/`.

### Config
- Updated `DOMAIN_PATH` to `sellerwise.devefinance.com`.

### Tech
- `NavigationService.handleUrls` now supports `useGo` to choose between `context.go` and `context.push`.

### Notes
- No API path changes.
- Store update: **yes** (routing behavior visible to users).
</details>


<details>
<summary><strong>AV 9.10.21 – Positive-only stock handling & simplified stock label</strong></summary>

### Logic
- Added `NumEx.onlyPositive` to normalize negative numbers to zero.
- Product details now use a sanitized stock getter (`_s`) for `maxQuantity`.

### UI/UX
- Simplified stock label to use `_stock_txt` directly from backend, keeping red color when out of stock.

### Notes
- No API changes.
- Store update: **no** (internal helper + UI logic tweak).
</details>

<details>
<summary><strong>AV 9.10.20 – Point API to local dev server</strong></summary>

### Config
- `DOMAIN_PATH` set to `sellerwise.devefinance.com`.
- `RAW_BASE_URL` switched to `http://192.168.100.200:8080/devef` (overrides `PROTOCOL + DOMAIN_PATH`).
- Effective `BASE_URL`: `http://192.168.100.200:8080/devef/api/v2`.

### Notes
- No endpoint path changes; only the base URL changed.
- **Store update: yes** (changing the app’s API base requires shipping a new build).
- On Android 9+, ensure cleartext HTTP is allowed (e.g., `usesCleartextTraffic=true` or network security config).
</details>

<details>
<summary><strong>AV 9.10.19 – Guard product details UI against negative stock</strong></summary>

### UI/UX
- When `_stock < 0`, the product details screen now shows:
  - total price as `0`,
  - quantity field fixed to `0`,
  - left stock text as `0`,
  - “out of stock” label active,
  - add-to-cart button disabled (grey, no shadow).

### Notes
- No API changes.
- Store update: **no** (logic/UI safeguards only).
</details>


<details>
<summary><strong>AV 9.10.18 – Add rating stars to MiniProductCard</strong></summary>

### UI/UX
- Added star rating row to `MiniProductCard` using `RatingBarIndicator`.
- Reduced bottom padding of the name line from 6 to 0 to make room for stars.

### Tech
- Optional `rating` parameter (int) on `MiniProductCard`; internally clamped to 0–5.
- Reuses existing `flutter_rating_bar` dependency already present in the project.

### Notes
- No API changes.
- Store update: **no** (minor UI enhancement).
</details>
<details>
<summary><strong>AV 9.10.17 – Order details spacing & top selling card padding</strong></summary>

### UI/UX
- Added a small left padding for order status labels (“Order placed”, “Confirmed”, “On the way”, “Delivered”) to improve alignment in the timeline row.
- Reduced bottom padding from 14 to 10 in the Top Selling product card content.

### Notes
- No API changes.
- Store update: **no** (minor UI tweaks).
</details>
<details>
<summary><strong>AV 9.10.16 – Arabic copy fix for orders string</strong></summary>

### UI/UX
- Corrected Arabic translation for `your_ordered_all_lower` from "طلبت" to "طلباتك".

### Notes
- No API changes.
- Store update: **no** (copy-only change).
</details>

<details>
<summary><strong>AV 9.10.15 – Order status colors moved to model</strong></summary>

### UI/UX
- Consolidated payment/delivery color logic into the `Order` model (`paymentColor`, `deliveryColor`).
- Order list now uses model-provided colors instead of inline UI conditions.

### Tech
- Added `material.dart` import in the order mini response model.

### Notes
- No API changes.
- Store update: **no** (UI-only refactor).
</details><details>
<summary><strong>AV 9.10.22 – Router fallback to WebView + domain update</strong></summary>

### Routing
- Added `errorPageBuilder` to `GoRouter` that opens unknown routes in `CommonWebviewScreen` with `backHome=true` and URL `${RAW_BASE_URL}/mobile-page{path}`.
- `CommonWebviewScreen` now intercepts navigation and forwards it to `NavigationService` (deep links use router; external links use `url_launcher`).
- Back behavior: go back within WebView if possible; otherwise navigate to `/`.

### Config
- Updated `DOMAIN_PATH` to `sellerwise.devefinance.com`.

### Tech
- `NavigationService.handleUrls` now supports `useGo` to choose between `context.go` and `context.push`.

### Notes
- No API path changes.
- Store update: **yes** (routing behavior visible to users).
</details>



<details>
<summary><strong>AV 9.10.14 – OTP Login, LTR phone row & Auth UI polish</strong></summary>

### APIs (new)
- **POST** `/auth/send-otp` — Sends an OTP to the provided phone.
  - **Request (JSON)**: `{ "phone": string, "country_code": string, "identity_matrix": string, "temp_user_id": string }`
  - **Expected**: `200 OK` with `{ result, message, ... }`
  - **Errors**: `400/422` (validation), `401/429` (auth/rate limit)
- **POST** `/auth/verify-otp` — Verifies the OTP and logs the user in.
  - **Request (JSON)**: `{ "phone": string, "country_code": string, "otp_code": string, "identity_matrix": string, "temp_user_id": string, "device_info"?: object }`
  - **Expected**: `200 OK` with `LoginResponse` payload
  - **Errors**: `400/422` for invalid code

### UI/UX
- New **OTP** login provider (visible when `login_with_otp=1`).
- Phone input row is now **forced LTR** across locales.
- Unified third-party login icons via `LoginWith3rd` widget.
- Auth container uses `AlignmentDirectional` / `PositionedDirectional` and removes the outer `Directionality`.

### Settings
- Added `allowOTPLogin` and aggregated getter `otherLogins` in `BusinessSettingsData`.

### Notes
- No breaking changes to existing endpoints.
- Store update: **no** (feature addition only).
</details>




<details>
<summary><strong>AV 9.10.13 – Auth/Phone LTR & Registration fields refactor</strong></summary>

### UI/UX
- Phone input row now enforced as **LTR** regardless of app locale.
- Registration form fields refactored into a reusable `_SignUpField` to reduce duplication and keep consistent styling.

### Tech
- Reused existing input decorations, theme, and phone input widget.
- No API changes.

### Notes
- Requires Flutter version supporting `Column(spacing:)`; otherwise, replace with `SizedBox` spacing.
</details>


<details>
<summary><strong>AV 9.10.12 – Profile contact display cleanup</strong></summary>

### UI/UX
- **Profile**: prefer showing **Phone** if available; fallback to **Email**.
- **Profile Edit**: hide **Phone** block when empty; hide **Email** block when empty (no more empty fields).

### Infra / Widgets
- Reused existing `CustomInternationalPhoneNumberInput` and current input decorations/shadows.

### Notes
- No API changes.
- No store updates required.
</details>


<details>
<summary><strong>AV 9.10.11 – PagedView modularization</strong></summary>

### Infra / Widgets
- Split monolithic PagedView into separate files:
  - `lib/custom/paged_view/models/page_result.dart`
  - `lib/custom/paged_view/paged_view.dart`
  - `lib/helpers/grid_responsive.dart`
- Updated imports in:
  - `lib/screens/product/top_selling_products.dart`
  - `lib/screens/wholesales_screen.dart`
- UX/Perf: load-more triggers at bottom edge; prefetch when first page doesn't fill viewport.

### Notes
- No API changes.
- No store updates required.
</details>


<details>
<summary><strong>AV 9.10.10</strong></summary>

### Stability & Null-Safety
- **ClassifiedAdsResponse**: resilient JSON parsing (nullable `links`/`meta`, strict `success`, empty list when `data` isn't a List).
- **UserInfoResponse**: same guards; strict boolean `success`.
- **ProfileRepository.getUserInfoResponse()**: return type → `UserInfoResponse` (was `dynamic`).
- **My Classified Ads**: null-safe checks before accessing first element.
- **Guest Checkout / Map**: null-safe `animateCamera` with controller existence check.
- **Profile screen**: show Classifieds entry only if feature enabled **and** user is logged in.

### Notes
- **No API changes** → _no MUST UPDATE_ for server.
- Suggested app version: `9.10.10+91010`.
</details>


<details>
<summary><strong>AV 9.10.9</strong></summary>

### Widgets / Infra
- New generic **`PagedView<T>`** with infinite scroll, pull-to-refresh, and flexible layouts (**list / grid / masonry**).
- Supports `preloadTriggerFraction`, custom `itemBuilder`, `loadingItemBuilder`, `emptyBuilder`, and scroll `physics`.
- Grid tuning via `gridCrossAxisCount`, `gridAspectRatio`, `gridMainAxisExtent`. Sliver-based for performance.

### Product Screens
- **TopSellingProducts** migrated to `PagedView<Product>`; single-shot fetch (`hasMore=false`), masonry 2-col, shimmer placeholders.
- **Wholesale** screen migrated to `PagedView<Product>` with real paging via `getWholesaleProducts(page)`; shimmer while loading more.
- Wholesale badge now shows **only if**: wholesale addon installed **and** `BusinessSettingsData.showWholesaleLabel` is true.

### Models
- `BusinessSettingsData`: add `showWholesaleLabel` (maps backend key `wholesale_lable == "1"`).
- `ProductMiniResponse`: `success` -> **required non-nullable bool**; JSON parsed with `json["success"] == true`.

### UI
- `ShimmerHelper`: add `loadingItemBuilder(int index)` helper.
- `MyTheme`: normalize color fields; prefer `const` where safe.

### Notes
- **No API endpoint changes** → _no MUST UPDATE_ for server.
- Suggested app version: `9.10.9+91009`.
</details>


<details>
<summary><strong>AV 9.10.8</strong></summary>

### Config
- **RAW_BASE_URL** now points to local dev server: `http://192.168.100.200:8080/devef` (dynamic domain commented).  
  ⚠️ Dev-only — revert before production.

### Repository / API
- `getWholesaleProducts` now accepts `int page` and calls `/wholesale/all-products?page={page}`.

### Wholesale Screen
- Implemented **pagination + infinite scroll** (prefetch at ~70%), **pull-to-refresh**, and **shimmer** placeholders while loading more.
- Replaced `FutureBuilder` with state-driven flow (`page`, `_isLoading`, `_isLoadingMore`, `_hasMoreProducts`).
- Fixed item count/index issues; proper controller disposal; extracted `AppBar` builder.

### Product Details
- **pkg price** line: show strikethrough **only if discounted** (`firstPrice != price`) to avoid false strikes.

### Notes
- Suggested app version: `9.10.8+91008`.
</details>


<details>
<summary><strong>AV 9.10.7</strong></summary>

### Android
- AGP → **8.1.1** (settings.gradle).
- Temporarily use **debug signing** for `release` (testing only).
- Ensure **AndroidX** & **Jetifier** enabled.

### iOS
- `firebase_core` → **3.15.2**, `firebase_messaging` → **15.2.10**.
- Added `geolocator_apple`, `sms_autofill`.

### Dependencies
- Added: `geolocator`, `geolocator_android`.
- Updates: `go_router` **16.1.0**, `http` **1.5.0**, `google_maps_flutter*`, `webview_flutter*`, `shared_preferences_android`, etc.

### Location & Maps
- New `HandlePermissions.getCurrentLocation()` (Geolocator) with denied/forever/service-off handling.
- Map: auto-center to GPS if no coords, **myLocationEnabled**, recenter **FAB**, smooth camera, safer placemark try/catch.

### UI/UX
- `Btn.basic`: new `isLoading` (disables press + themed disabled color).
- Loading bar height **36 → 40**.
- Map pin tinted with theme; action bar lifted to avoid FAB overlap.

### Notes
- Suggest `version: 9.10.7+91007` in `pubspec.yaml`.
- **Before production**: restore `release { signingConfig signingConfigs.release }`.
</details>



<details>
<summary><strong>AV 9.10.6</strong></summary>

- Improved shared value loading (`user_id`, `is_logged_in`) in `main.dart`.
- Added conditional headers (`user_id`, `device_info`) to Business Settings API.
- Added error handling to `getProductDetails()` with translated fallback message.
- Handled product detail API failure:
  - Added `errorMessage` state.
  - Displayed `CustomErrorWidget` on failure.
  - Prevented rendering of bottom app bar when product is invalid.
- Handled seller image failure using `imageErrorBuilder`.
- Fixed wishlist logic with proper boolean check.
- Conditionally rendered flash deal in profile screen.
- Marked review submit failures with `isError: true`.

</details>


<details>
<summary><strong>AV 9.10.5</strong></summary>

- Added a `Loading.isLoading` getter to prevent showing duplicate loading dialogs.
- Improved **loading behavior** during:
  - Registration
  - Adding a new address
- Integrated `OneContext` for global context handling in registration and address flows.
- Fixed potential null/empty issues with the email field during sign-up.
- Enhanced `commonHeader` to include `Authorization` header if access token is available.
- Ensured cart data is fetched when returning to home screen via `HomePresenter`.
- Improved UI consistency by calling `reset()` before re-fetching home data.

</details>


<details>
<summary><strong>AV 9.10.4</strong></summary>

- Integrated **sms_autofill** package to support automatic SMS code detection during password reset.
- Updated password reset flow:
  - `getPasswordForgetResponse()` now requires `app_signature`.
  - Auto-fills OTP code using `CodeAutoFill` and `TextFieldPinAutoFill`.
- Extended OTP timer duration from 20 to 90 seconds.
- Fixed minor formatting issues and improved error handling in password reset process.
- Added safety around `device_info` usage with better spacing and conditionals.

</details>


<details>
<summary><strong>AV 9.10.3</strong></summary>

- Added a confirmation dialog when changing the default address if **sellerWiseShipping** is enabled, warning users that the cart will be cleared.
- Integrated `ShippingInfo` screen dynamically based on business setting instead of always using `SelectAddress`.
- Enhanced safety by switching from `double.parse()` to `double.tryParse()` in the `ShippingCostResponse` model to prevent crashes.
- Added new localization key: `change_default_address_make_cart_empty` (Arabic + English).

</details>


<details>
<summary><strong>AV 9.10.2</strong></summary>

- Implemented a new layout and functionality for the **wholesale** system across the entire app.
- Improved user experience on the product details screen.
</details>


<details>
<summary><strong>AV 9.10.1</strong></summary>

- Fixed a login issue that occurred under poor network conditions.
- Improved automatic language loading from the server.
</details>