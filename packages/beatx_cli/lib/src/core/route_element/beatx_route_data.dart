import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import '../../constants/type_checker.dart';
import '../../models/route_element.dart';
import '../../utils/types.dart';

class BeatxRotueData {
  BeatxRotueData(this.routeElement);
  final RouteElement routeElement;

  /// Refined path
  String get path => routeElement.route.path;

  /// Annotation element
  AnnotatedElement get annotatedElement => routeElement.element;

  /// Widget class
  ClassElement get classElement => routeElement.element.element as ClassElement;

  /// Default constructor
  ConstructorElement get constructor =>
      classElement.constructors.cast<ConstructorElement>().firstWhere(
            (constructor) =>
                xconstructorChecker.annotationsOf(constructor).isNotEmpty,
            orElse: () => classElement.constructors.first,
          );

  /// Constructor's parameters
  Iterable<ParameterElement> get _parameters => constructor.parameters.where(
        (element) => !ignoreChecker.hasAnnotationOf(element),
      );

  /// Required positional parameters. e.g. `int a, String b`
  Iterable<ParameterElement> get requiredPositionals =>
      _parameters.where((param) => param.isRequiredPositional);

  /// Optional positional parameters. e.g. `[int a, String b]`
  Iterable<ParameterElement> get optionalPositionals =>
      _parameters.where((param) => param.isOptional && !param.isNamed);

  /// Required named parameters. e.g. `{required int a, required String b}`
  Iterable<ParameterElement> get requiredNamed =>
      _parameters.where((param) => param.isRequiredNamed);

  /// Optional named parameters. e.g. `{int a, String b}`
  Iterable<ParameterElement> get optionalNamed =>
      _parameters.where((param) => param.isOptionalNamed);

  /// All the parameters
  String get fields => _parameters
      .map(
        (param) => 'final ${param.type} ${param.name};',
      )
      .join('');

  /// All the parameters required for the constructor
  String buildRouteConstructorParams() {
    final requiredPositionalParams =
        requiredPositionals.map((param) => 'this.${param.name}').join(', ');
    final optionalPositionalParams =
        '[${optionalPositionals.map((param) => 'this.${param.name} ${param.hasDefaultValue ? '= ${param.defaultValueCode}' : ''}').join(', ')}]';
    final requiredNamedParams =
        requiredNamed.map((param) => 'required this.${param.name}').join(', ');
    final optionalNamedParams = optionalNamed
        .map(
          (param) =>
              'this.${param.name} ${param.hasDefaultValue ? '= ${param.defaultValueCode}' : ''}',
        )
        .join(', ');

    final positionalParams = [
      if (requiredPositionalParams.isNotEmpty) requiredPositionalParams,
      if (optionalPositionalParams.length > 2) optionalPositionalParams,
    ].join(', ');

    final namedParams = '{${[
      if (requiredNamedParams.isNotEmpty) requiredNamedParams,
      if (optionalNamedParams.isNotEmpty) optionalNamedParams,
    ].join(', ')}}';

    final params = [
      if (positionalParams.isNotEmpty) positionalParams,
      if (namedParams.length > 2) namedParams,
    ].join(', ');
    return params;
  }

  String buildWidgetConstructorArgs() {
    final requiredPositionalParams =
        requiredPositionals.map((param) => param.name).join(', ');
    final optionalPositionalParams =
        optionalPositionals.map((e) => e.name).join(',');
    final requiredNamedParams =
        requiredNamed.map((e) => '${e.name}: ${e.name}').join(',');
    final optionalNamedParams =
        optionalNamed.map((e) => '${e.name}: ${e.name}').join(',');

    final positionalParams = [
      if (requiredPositionalParams.isNotEmpty) requiredPositionalParams,
      if (optionalPositionalParams.isNotEmpty) optionalPositionalParams,
    ].join(', ');

    final namedParams = [
      if (requiredNamedParams.isNotEmpty) requiredNamedParams,
      if (optionalNamedParams.isNotEmpty) optionalNamedParams,
    ].join(', ');

    final params = [
      if (positionalParams.isNotEmpty) positionalParams,
      if (namedParams.isNotEmpty) namedParams,
    ].join(', ');
    return params;
  }

  String buildQueryParams() {
    final map = _parameters
        .where((e) => e.name != r'$extra')
        .map(
          (e) =>
              "if (${e.name} != null) '${e.name}': ${e.isString ? e.name : '${e.name}.toString()'}",
        )
        .join(',');
    return map;
  }

  String get routeName => '${classElement.displayName}Route';

  String buildRouteArgsFromState() {
    final paramVariables = _parameters.map((param) {
      if (param.name == r'$extra') {
        return '''
final \$extra = state.extra as ${param.type};
''';
      }
      final type = param.type;
      final isOptional = type.nullabilitySuffix == NullabilitySuffix.question;
      var queryParams = "state.queryParams['${param.name}']";
      if (type.isDartCoreString) {
        return '''
final ${param.name} = $queryParams${isOptional ? '' : '!'};
''';
      }

      var body =
          '${param.type.getDisplayString(withNullability: false)}.parse($queryParams!)';
      if (isOptional) {
        body = '$queryParams == null ? null : $body';
      }

      return '''
final ${param.name} = $body;
''';
    }).join();

    return paramVariables;
  }

  String get libraryPath =>
      classElement.library.source.uri.path.split('/').last;

  bool get isNewPage => true;

  String? get _pageBuilder => annotatedElement.annotation
      .revive()
      .namedArguments['buildPage']
      ?.toFunctionValue()
      ?.name;

  String get buildPage => _pageBuilder == null
      ? ''
      : '''
  @override
  Page<void> buildPageWithState(BuildContext context, GoRouterState state) {
    final child = build(context);
    return ${isNewPage ? '$_pageBuilder(context, child, state)' : '''
      NoTransitionPage<void>(
        name: state.name,
        arguments: state.extra,
        restorationId: state.restorationId,
        child: child,
      )
'''};
  }
''';

  @override
  String toString() {
    final formatter = DartFormatter();
    return formatter.format('''
/// AUTO GENERATED BY BEATX
/// DO NOT MODIFY THIS BY YOURSELF

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import r'$libraryPath';

GoRoute get \$${routeName.substring(0, 1).toLowerCase() + routeName.substring(1)} => GoRouteData.\$route(
      path: '$path',
      factory: $routeName.fromState,
    );

class $routeName extends GoRouteData {
  const $routeName( 
    ${buildRouteConstructorParams()}
  );

  factory $routeName.fromState(GoRouterState state) {
    ${buildRouteArgsFromState()}
    return $routeName(
      ${buildWidgetConstructorArgs()}
    );
  }

  $fields

  @override
  Widget build(BuildContext context) => ${constructor.displayName}(
    ${buildWidgetConstructorArgs()}
  );

  $buildPage

  String get location => GoRouteData.\$location(
      '$path',
      queryParams: {
        ${buildQueryParams()}
      },
    );

  void go(BuildContext context) => context.go(location, extra: this);

  void push(BuildContext context) => context.push(location, extra: this);

  void replace(BuildContext context) => context.replace(location, extra: this);
}
''');
  }
}

final notransitionPage = '''
      NoTransitionPage<void>(
        name: name,
        arguments: arguments,
        key: key,
        restorationId: restorationId,
        child: child,
      );
''';
