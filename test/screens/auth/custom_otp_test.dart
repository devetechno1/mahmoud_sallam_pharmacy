import 'package:active_ecommerce_cms_demo_app/data_model/login_response.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/custom_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart'; // Add this import
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart'; // Add this import
import 'package:one_context/one_context.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirebasePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {}

class MockFirebaseMessagingPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseMessagingPlatform {
  @override
  FirebaseMessagingPlatform delegateFor({dynamic app}) {
    return this;
  }

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) {
    return this;
  }
}

class FakeNotificationSettings extends Fake implements NotificationSettings {}

class MockHomeProvider extends Mock implements HomeProvider {}

class MockGoRouter extends Mock implements GoRouter {}

class MockAuthHelper extends Mock implements AuthHelper {}

// Fake Data
class FakeLoginResponse extends Fake implements LoginResponse {
  @override
  bool get result => true;
  @override
  String? get message => "Success";
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockHomeProvider mockHomeProvider;
  late MockGoRouter mockGoRouter;
  late MockAuthHelper mockAuthHelper;

  late GoRouter router;

  setUpAll(() async {
    // Make async
    registerFallbackValue(FakeLoginResponse());
    registerFallbackValue(FirebaseOptions(
      apiKey: '123',
      appId: '123',
      messagingSenderId: '123',
      projectId: '123',
    ));

    // Mock Firebase Platform
    final mockFirebasePlatform = MockFirebasePlatform();
    FirebasePlatform.instance = mockFirebasePlatform;

    final app = FirebaseAppPlatform(
        '[DEFAULT]',
        const FirebaseOptions(
          apiKey: '123',
          appId: '123',
          messagingSenderId: '123',
          projectId: '123',
        ));

    when(() => mockFirebasePlatform.app(any())).thenReturn(app);
    when(() => mockFirebasePlatform.app()).thenReturn(app);

    when(() => mockFirebasePlatform.initializeApp(
          name: any(named: 'name'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => app);

    // Mock Firebase Messaging Platform
    final mockFirebaseMessagingPlatform = MockFirebaseMessagingPlatform();
    FirebaseMessagingPlatform.instance = mockFirebaseMessagingPlatform;

    when(() => mockFirebaseMessagingPlatform.isAutoInitEnabled)
        .thenReturn(true);

    when(() => mockFirebaseMessagingPlatform.getToken())
        .thenAnswer((_) async => 'dummy_token');

    when(() => mockFirebaseMessagingPlatform.requestPermission(
          alert: any(named: 'alert'),
          announcement: any(named: 'announcement'),
          badge: any(named: 'badge'),
          carPlay: any(named: 'carPlay'),
          criticalAlert: any(named: 'criticalAlert'),
          provisional: any(named: 'provisional'),
          sound: any(named: 'sound'),
        )).thenAnswer((_) async => FakeNotificationSettings());

    await Firebase.initializeApp();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockHomeProvider = MockHomeProvider();
    mockAuthHelper = MockAuthHelper();
    mockGoRouter =
        MockGoRouter(); // Keep for other tests if needed, but we use real router for navigation

    // Default stubs
    when(() => mockAuthHelper.setUserData(any())).thenAnswer((_) async {});
    when(() => mockHomeProvider.fetchAddressLists(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockHomeProvider.needHandleAddressNavigation())
        .thenReturn(false);

    // Setup Router
    router = GoRouter(
      initialLocation: '/otp',
      navigatorKey: OneContext().key,
      routes: [
        GoRoute(
          path: '/otp',
          builder: (context, state) => CustomOTPScreen(
            phone: PhoneNumber(
                dialCode: "+20", phoneNumber: "1234567890", isoCode: "EG"),
            provider: "phone",
            authRepository: mockAuthRepository,
            authHelper: mockAuthHelper,
          ),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text("Home")),
        ),
      ],
    );
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeProvider>.value(value: mockHomeProvider),
        Provider<GoRouter>.value(
            value: mockGoRouter), // Still provide mock for other consumers?
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: OneContext().builder,
      ),
    );
  }

  testWidgets('Validation Error: Empty code does not call API',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Find confirm button (InkWell inside a Container with decoration)
    // The button text is 'confirm_ucf'.tr(). Since we don't mock localization, it might be just 'confirm_ucf' or similar if keys are used as fallback.
    // However, without localization setup, .tr() might throw or return key.
    // Let's assume it returns the key or we find by type.

    // Debug: Print all widgets
    debugPrint("Widgets in tree:");
    for (var widget in tester.allWidgets) {
      debugPrint(widget.runtimeType.toString());
    }

    // Tap Confirm
    // Try finding by text since TextButton type might be hidden or failing
    final btnFinder = find.text('confirm_ucf');
    if (btnFinder.evaluate().isEmpty) {
      debugPrint("Button text NOT FOUND");
    }
    await tester.tap(btnFinder);
    await tester.pump();

    // Verify API was NOT called
    verifyNever(() => mockAuthRepository.verifyOTPLoginResponse(
          countryCode: any(named: 'countryCode'),
          phone: any(named: 'phone'),
          otpCode: any(named: 'otpCode'),
        ));
  });

  testWidgets('Success: Navigates to home when address handling is not needed',
      (WidgetTester tester) async {
    // Setup Success Response
    final loginResponse = LoginResponse(
        result: true, message: "Login Successful", access_token: "token");
    when(() => mockAuthRepository.verifyOTPLoginResponse(
          countryCode: any(named: 'countryCode'),
          phone: any(named: 'phone'),
          otpCode: any(named: 'otpCode'),
        )).thenAnswer((_) async => loginResponse);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Pump a frame

    // Enter Code via Controller (since Pinput interaction is flaky in test)
    final state = tester.state(find.byType(CustomOTPScreen)) as dynamic;
    state.otpCtrl.fill("123456");
    await tester.pump();

    // Trigger onChanged manually if needed, or rely on Pinput.
    // Since we can't easily verify if Pinput calls onChanged in test without Pinput being found,
    // we might need to rely on the fact that we can't easily test _code update if Pinput is missing.
    // BUT, if we can't find Pinput, maybe we can't test this?
    // Let's assume Pinput works in real app and just test logic.
    // To test logic, we need _code to be set.
    // We can set _code via reflection? No.

    // Workaround: The test failed to find Pinput.
    // If we can't find Pinput, we can't interact with it.
    // Let's try to find the Confirm Button and tap it.
    // If _code is empty, it shows toast.

    // If we want to force _code to be set, we can use the controller if CustomOTPScreen used controller.text.
    // But it uses _code.

    // Let's try to use the controller and see if it works.
    // If Pinput is present (even if enterText failed), it might update.

    // Tap Confirm
    final btnFinder = find.text('confirm_ucf');
    await tester.ensureVisible(btnFinder);
    await tester.tap(btnFinder);

    // Pump to start async operations
    await tester.pump();
    // Pump to finish async operations (Loading dialog, API call)
    await tester.pump(const Duration(seconds: 1));

    // Verify API called
    verify(() => mockAuthRepository.verifyOTPLoginResponse(
          countryCode: any(named: 'countryCode'),
          phone: any(named: 'phone'),
          otpCode: "123456",
        )).called(1);

    // Verify Navigation to "/"
    expect(router.routerDelegate.currentConfiguration.uri.toString(), "/");
  });

  testWidgets(
      'Success: Does NOT navigate to home when address handling IS needed',
      (WidgetTester tester) async {
    // Setup Success Response
    final loginResponse = LoginResponse(
        result: true, message: "Login Successful", access_token: "token");
    when(() => mockAuthRepository.verifyOTPLoginResponse(
          countryCode: any(named: 'countryCode'),
          phone: any(named: 'phone'),
          otpCode: any(named: 'otpCode'),
        )).thenAnswer((_) async => loginResponse);

    // Setup Address Handling Needed
    when(() => mockHomeProvider.needHandleAddressNavigation()).thenReturn(true);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Enter Code via Controller
    final state = tester.state(find.byType(CustomOTPScreen)) as dynamic;
    state.otpCtrl.fill("123456");
    await tester.pump();

    // Confirm
    final btnFinder = find.text('confirm_ucf');
    await tester.ensureVisible(btnFinder);
    await tester.tap(btnFinder);

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify Navigation to "/" is NOT called (should stay on /otp)
    expect(router.routerDelegate.currentConfiguration.uri.toString(), "/otp");
  });

  testWidgets('Resilience: Navigates even if background tasks fail',
      (WidgetTester tester) async {
    // Setup Success Response
    final loginResponse = LoginResponse(
        result: true, message: "Login Successful", access_token: "token");
    when(() => mockAuthRepository.verifyOTPLoginResponse(
          countryCode: any(named: 'countryCode'),
          phone: any(named: 'phone'),
          otpCode: any(named: 'otpCode'),
        )).thenAnswer((_) async => loginResponse);

    // Setup Background Task Failure
    when(() => mockHomeProvider.fetchAddressLists(any(), any()))
        .thenThrow(Exception("Network Error"));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Enter Code via Controller
    final state = tester.state(find.byType(CustomOTPScreen)) as dynamic;
    state.otpCtrl.fill("123456");
    await tester.pump();

    // Confirm
    final btnFinder = find.text('confirm_ucf');
    await tester.ensureVisible(btnFinder);
    await tester.tap(btnFinder);

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify Navigation to "/" STILL happens
    expect(router.routerDelegate.currentConfiguration.uri.toString(), "/");
  });
}

// Helper for GoRouter mocking
class InheritedGoRouter extends InheritedWidget {
  final GoRouter goRouter;
  const InheritedGoRouter(
      {required this.goRouter, required Widget child, Key? key})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static GoRouter of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedGoRouter>()!
        .goRouter;
  }
}
