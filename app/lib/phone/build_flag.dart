/// Whether this build includes the native phone-control module and its UI.
///
/// The default keeps the full app. A phone-control-free build compiles this to
/// false, allowing unreachable phone UI and channel calls to be tree-shaken.
const bool phoneControlBuildEnabled = bool.fromEnvironment(
  'DSH_PHONE_CONTROL',
  defaultValue: true,
);
