// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prompter_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrompterState {

 double get speed;// 滚动速度（行/秒）
 bool get mirroredX;// X轴镜像（水平翻转）
 bool get mirroredY;// Y轴镜像（垂直翻转）
 double get fontSize;// 字体大小（点）
 bool get isPlaying;// 是否正在播放
 double get sideMargin;// 侧边距（百分比）
 String get fontFamily;// 字体系列
 TextAlign get alignment;// 文本对齐方式
 bool get displayReadingIndicatorBoxes;// 是否显示助读区
 double get readingIndicatorBoxesHeight;// 助读区高度（百分比）
 bool get displayVerticalMarginBoxes;// 是否显示垂直遮罩
 double get verticalMarginBoxesHeight;// 遮罩高度（百分比）
 double get countdownDuration;// 倒计时时长（秒）
 bool get displayCountdown;// 是否显示倒计时
 bool get verticalMarginBoxesFadeEnabled;// 是否启用遮罩渐变
 double get verticalMarginBoxesFadeLength;
/// Create a copy of PrompterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrompterStateCopyWith<PrompterState> get copyWith => _$PrompterStateCopyWithImpl<PrompterState>(this as PrompterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrompterState&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.mirroredX, mirroredX) || other.mirroredX == mirroredX)&&(identical(other.mirroredY, mirroredY) || other.mirroredY == mirroredY)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.sideMargin, sideMargin) || other.sideMargin == sideMargin)&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.displayReadingIndicatorBoxes, displayReadingIndicatorBoxes) || other.displayReadingIndicatorBoxes == displayReadingIndicatorBoxes)&&(identical(other.readingIndicatorBoxesHeight, readingIndicatorBoxesHeight) || other.readingIndicatorBoxesHeight == readingIndicatorBoxesHeight)&&(identical(other.displayVerticalMarginBoxes, displayVerticalMarginBoxes) || other.displayVerticalMarginBoxes == displayVerticalMarginBoxes)&&(identical(other.verticalMarginBoxesHeight, verticalMarginBoxesHeight) || other.verticalMarginBoxesHeight == verticalMarginBoxesHeight)&&(identical(other.countdownDuration, countdownDuration) || other.countdownDuration == countdownDuration)&&(identical(other.displayCountdown, displayCountdown) || other.displayCountdown == displayCountdown)&&(identical(other.verticalMarginBoxesFadeEnabled, verticalMarginBoxesFadeEnabled) || other.verticalMarginBoxesFadeEnabled == verticalMarginBoxesFadeEnabled)&&(identical(other.verticalMarginBoxesFadeLength, verticalMarginBoxesFadeLength) || other.verticalMarginBoxesFadeLength == verticalMarginBoxesFadeLength));
}


@override
int get hashCode => Object.hash(runtimeType,speed,mirroredX,mirroredY,fontSize,isPlaying,sideMargin,fontFamily,alignment,displayReadingIndicatorBoxes,readingIndicatorBoxesHeight,displayVerticalMarginBoxes,verticalMarginBoxesHeight,countdownDuration,displayCountdown,verticalMarginBoxesFadeEnabled,verticalMarginBoxesFadeLength);

@override
String toString() {
  return 'PrompterState(speed: $speed, mirroredX: $mirroredX, mirroredY: $mirroredY, fontSize: $fontSize, isPlaying: $isPlaying, sideMargin: $sideMargin, fontFamily: $fontFamily, alignment: $alignment, displayReadingIndicatorBoxes: $displayReadingIndicatorBoxes, readingIndicatorBoxesHeight: $readingIndicatorBoxesHeight, displayVerticalMarginBoxes: $displayVerticalMarginBoxes, verticalMarginBoxesHeight: $verticalMarginBoxesHeight, countdownDuration: $countdownDuration, displayCountdown: $displayCountdown, verticalMarginBoxesFadeEnabled: $verticalMarginBoxesFadeEnabled, verticalMarginBoxesFadeLength: $verticalMarginBoxesFadeLength)';
}


}

/// @nodoc
abstract mixin class $PrompterStateCopyWith<$Res>  {
  factory $PrompterStateCopyWith(PrompterState value, $Res Function(PrompterState) _then) = _$PrompterStateCopyWithImpl;
@useResult
$Res call({
 double speed, bool mirroredX, bool mirroredY, double fontSize, bool isPlaying, double sideMargin, String fontFamily, TextAlign alignment, bool displayReadingIndicatorBoxes, double readingIndicatorBoxesHeight, bool displayVerticalMarginBoxes, double verticalMarginBoxesHeight, double countdownDuration, bool displayCountdown, bool verticalMarginBoxesFadeEnabled, double verticalMarginBoxesFadeLength
});




}
/// @nodoc
class _$PrompterStateCopyWithImpl<$Res>
    implements $PrompterStateCopyWith<$Res> {
  _$PrompterStateCopyWithImpl(this._self, this._then);

  final PrompterState _self;
  final $Res Function(PrompterState) _then;

/// Create a copy of PrompterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? speed = null,Object? mirroredX = null,Object? mirroredY = null,Object? fontSize = null,Object? isPlaying = null,Object? sideMargin = null,Object? fontFamily = null,Object? alignment = null,Object? displayReadingIndicatorBoxes = null,Object? readingIndicatorBoxesHeight = null,Object? displayVerticalMarginBoxes = null,Object? verticalMarginBoxesHeight = null,Object? countdownDuration = null,Object? displayCountdown = null,Object? verticalMarginBoxesFadeEnabled = null,Object? verticalMarginBoxesFadeLength = null,}) {
  return _then(_self.copyWith(
speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,mirroredX: null == mirroredX ? _self.mirroredX : mirroredX // ignore: cast_nullable_to_non_nullable
as bool,mirroredY: null == mirroredY ? _self.mirroredY : mirroredY // ignore: cast_nullable_to_non_nullable
as bool,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,sideMargin: null == sideMargin ? _self.sideMargin : sideMargin // ignore: cast_nullable_to_non_nullable
as double,fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as TextAlign,displayReadingIndicatorBoxes: null == displayReadingIndicatorBoxes ? _self.displayReadingIndicatorBoxes : displayReadingIndicatorBoxes // ignore: cast_nullable_to_non_nullable
as bool,readingIndicatorBoxesHeight: null == readingIndicatorBoxesHeight ? _self.readingIndicatorBoxesHeight : readingIndicatorBoxesHeight // ignore: cast_nullable_to_non_nullable
as double,displayVerticalMarginBoxes: null == displayVerticalMarginBoxes ? _self.displayVerticalMarginBoxes : displayVerticalMarginBoxes // ignore: cast_nullable_to_non_nullable
as bool,verticalMarginBoxesHeight: null == verticalMarginBoxesHeight ? _self.verticalMarginBoxesHeight : verticalMarginBoxesHeight // ignore: cast_nullable_to_non_nullable
as double,countdownDuration: null == countdownDuration ? _self.countdownDuration : countdownDuration // ignore: cast_nullable_to_non_nullable
as double,displayCountdown: null == displayCountdown ? _self.displayCountdown : displayCountdown // ignore: cast_nullable_to_non_nullable
as bool,verticalMarginBoxesFadeEnabled: null == verticalMarginBoxesFadeEnabled ? _self.verticalMarginBoxesFadeEnabled : verticalMarginBoxesFadeEnabled // ignore: cast_nullable_to_non_nullable
as bool,verticalMarginBoxesFadeLength: null == verticalMarginBoxesFadeLength ? _self.verticalMarginBoxesFadeLength : verticalMarginBoxesFadeLength // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PrompterState].
extension PrompterStatePatterns on PrompterState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrompterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrompterState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrompterState value)  $default,){
final _that = this;
switch (_that) {
case _PrompterState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrompterState value)?  $default,){
final _that = this;
switch (_that) {
case _PrompterState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double speed,  bool mirroredX,  bool mirroredY,  double fontSize,  bool isPlaying,  double sideMargin,  String fontFamily,  TextAlign alignment,  bool displayReadingIndicatorBoxes,  double readingIndicatorBoxesHeight,  bool displayVerticalMarginBoxes,  double verticalMarginBoxesHeight,  double countdownDuration,  bool displayCountdown,  bool verticalMarginBoxesFadeEnabled,  double verticalMarginBoxesFadeLength)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrompterState() when $default != null:
return $default(_that.speed,_that.mirroredX,_that.mirroredY,_that.fontSize,_that.isPlaying,_that.sideMargin,_that.fontFamily,_that.alignment,_that.displayReadingIndicatorBoxes,_that.readingIndicatorBoxesHeight,_that.displayVerticalMarginBoxes,_that.verticalMarginBoxesHeight,_that.countdownDuration,_that.displayCountdown,_that.verticalMarginBoxesFadeEnabled,_that.verticalMarginBoxesFadeLength);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double speed,  bool mirroredX,  bool mirroredY,  double fontSize,  bool isPlaying,  double sideMargin,  String fontFamily,  TextAlign alignment,  bool displayReadingIndicatorBoxes,  double readingIndicatorBoxesHeight,  bool displayVerticalMarginBoxes,  double verticalMarginBoxesHeight,  double countdownDuration,  bool displayCountdown,  bool verticalMarginBoxesFadeEnabled,  double verticalMarginBoxesFadeLength)  $default,) {final _that = this;
switch (_that) {
case _PrompterState():
return $default(_that.speed,_that.mirroredX,_that.mirroredY,_that.fontSize,_that.isPlaying,_that.sideMargin,_that.fontFamily,_that.alignment,_that.displayReadingIndicatorBoxes,_that.readingIndicatorBoxesHeight,_that.displayVerticalMarginBoxes,_that.verticalMarginBoxesHeight,_that.countdownDuration,_that.displayCountdown,_that.verticalMarginBoxesFadeEnabled,_that.verticalMarginBoxesFadeLength);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double speed,  bool mirroredX,  bool mirroredY,  double fontSize,  bool isPlaying,  double sideMargin,  String fontFamily,  TextAlign alignment,  bool displayReadingIndicatorBoxes,  double readingIndicatorBoxesHeight,  bool displayVerticalMarginBoxes,  double verticalMarginBoxesHeight,  double countdownDuration,  bool displayCountdown,  bool verticalMarginBoxesFadeEnabled,  double verticalMarginBoxesFadeLength)?  $default,) {final _that = this;
switch (_that) {
case _PrompterState() when $default != null:
return $default(_that.speed,_that.mirroredX,_that.mirroredY,_that.fontSize,_that.isPlaying,_that.sideMargin,_that.fontFamily,_that.alignment,_that.displayReadingIndicatorBoxes,_that.readingIndicatorBoxesHeight,_that.displayVerticalMarginBoxes,_that.verticalMarginBoxesHeight,_that.countdownDuration,_that.displayCountdown,_that.verticalMarginBoxesFadeEnabled,_that.verticalMarginBoxesFadeLength);case _:
  return null;

}
}

}

/// @nodoc


class _PrompterState implements PrompterState {
   _PrompterState({this.speed = 1.0, this.mirroredX = false, this.mirroredY = false, this.fontSize = 48.0, this.isPlaying = false, this.sideMargin = 0.0, this.fontFamily = 'Roboto', this.alignment = TextAlign.left, this.displayReadingIndicatorBoxes = false, this.readingIndicatorBoxesHeight = 25.0, this.displayVerticalMarginBoxes = false, this.verticalMarginBoxesHeight = 25.0, this.countdownDuration = 5.0, this.displayCountdown = false, this.verticalMarginBoxesFadeEnabled = false, this.verticalMarginBoxesFadeLength = 0.0});
  

@override@JsonKey() final  double speed;
// 滚动速度（行/秒）
@override@JsonKey() final  bool mirroredX;
// X轴镜像（水平翻转）
@override@JsonKey() final  bool mirroredY;
// Y轴镜像（垂直翻转）
@override@JsonKey() final  double fontSize;
// 字体大小（点）
@override@JsonKey() final  bool isPlaying;
// 是否正在播放
@override@JsonKey() final  double sideMargin;
// 侧边距（百分比）
@override@JsonKey() final  String fontFamily;
// 字体系列
@override@JsonKey() final  TextAlign alignment;
// 文本对齐方式
@override@JsonKey() final  bool displayReadingIndicatorBoxes;
// 是否显示助读区
@override@JsonKey() final  double readingIndicatorBoxesHeight;
// 助读区高度（百分比）
@override@JsonKey() final  bool displayVerticalMarginBoxes;
// 是否显示垂直遮罩
@override@JsonKey() final  double verticalMarginBoxesHeight;
// 遮罩高度（百分比）
@override@JsonKey() final  double countdownDuration;
// 倒计时时长（秒）
@override@JsonKey() final  bool displayCountdown;
// 是否显示倒计时
@override@JsonKey() final  bool verticalMarginBoxesFadeEnabled;
// 是否启用遮罩渐变
@override@JsonKey() final  double verticalMarginBoxesFadeLength;

/// Create a copy of PrompterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrompterStateCopyWith<_PrompterState> get copyWith => __$PrompterStateCopyWithImpl<_PrompterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrompterState&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.mirroredX, mirroredX) || other.mirroredX == mirroredX)&&(identical(other.mirroredY, mirroredY) || other.mirroredY == mirroredY)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.sideMargin, sideMargin) || other.sideMargin == sideMargin)&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.displayReadingIndicatorBoxes, displayReadingIndicatorBoxes) || other.displayReadingIndicatorBoxes == displayReadingIndicatorBoxes)&&(identical(other.readingIndicatorBoxesHeight, readingIndicatorBoxesHeight) || other.readingIndicatorBoxesHeight == readingIndicatorBoxesHeight)&&(identical(other.displayVerticalMarginBoxes, displayVerticalMarginBoxes) || other.displayVerticalMarginBoxes == displayVerticalMarginBoxes)&&(identical(other.verticalMarginBoxesHeight, verticalMarginBoxesHeight) || other.verticalMarginBoxesHeight == verticalMarginBoxesHeight)&&(identical(other.countdownDuration, countdownDuration) || other.countdownDuration == countdownDuration)&&(identical(other.displayCountdown, displayCountdown) || other.displayCountdown == displayCountdown)&&(identical(other.verticalMarginBoxesFadeEnabled, verticalMarginBoxesFadeEnabled) || other.verticalMarginBoxesFadeEnabled == verticalMarginBoxesFadeEnabled)&&(identical(other.verticalMarginBoxesFadeLength, verticalMarginBoxesFadeLength) || other.verticalMarginBoxesFadeLength == verticalMarginBoxesFadeLength));
}


@override
int get hashCode => Object.hash(runtimeType,speed,mirroredX,mirroredY,fontSize,isPlaying,sideMargin,fontFamily,alignment,displayReadingIndicatorBoxes,readingIndicatorBoxesHeight,displayVerticalMarginBoxes,verticalMarginBoxesHeight,countdownDuration,displayCountdown,verticalMarginBoxesFadeEnabled,verticalMarginBoxesFadeLength);

@override
String toString() {
  return 'PrompterState(speed: $speed, mirroredX: $mirroredX, mirroredY: $mirroredY, fontSize: $fontSize, isPlaying: $isPlaying, sideMargin: $sideMargin, fontFamily: $fontFamily, alignment: $alignment, displayReadingIndicatorBoxes: $displayReadingIndicatorBoxes, readingIndicatorBoxesHeight: $readingIndicatorBoxesHeight, displayVerticalMarginBoxes: $displayVerticalMarginBoxes, verticalMarginBoxesHeight: $verticalMarginBoxesHeight, countdownDuration: $countdownDuration, displayCountdown: $displayCountdown, verticalMarginBoxesFadeEnabled: $verticalMarginBoxesFadeEnabled, verticalMarginBoxesFadeLength: $verticalMarginBoxesFadeLength)';
}


}

/// @nodoc
abstract mixin class _$PrompterStateCopyWith<$Res> implements $PrompterStateCopyWith<$Res> {
  factory _$PrompterStateCopyWith(_PrompterState value, $Res Function(_PrompterState) _then) = __$PrompterStateCopyWithImpl;
@override @useResult
$Res call({
 double speed, bool mirroredX, bool mirroredY, double fontSize, bool isPlaying, double sideMargin, String fontFamily, TextAlign alignment, bool displayReadingIndicatorBoxes, double readingIndicatorBoxesHeight, bool displayVerticalMarginBoxes, double verticalMarginBoxesHeight, double countdownDuration, bool displayCountdown, bool verticalMarginBoxesFadeEnabled, double verticalMarginBoxesFadeLength
});




}
/// @nodoc
class __$PrompterStateCopyWithImpl<$Res>
    implements _$PrompterStateCopyWith<$Res> {
  __$PrompterStateCopyWithImpl(this._self, this._then);

  final _PrompterState _self;
  final $Res Function(_PrompterState) _then;

/// Create a copy of PrompterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? speed = null,Object? mirroredX = null,Object? mirroredY = null,Object? fontSize = null,Object? isPlaying = null,Object? sideMargin = null,Object? fontFamily = null,Object? alignment = null,Object? displayReadingIndicatorBoxes = null,Object? readingIndicatorBoxesHeight = null,Object? displayVerticalMarginBoxes = null,Object? verticalMarginBoxesHeight = null,Object? countdownDuration = null,Object? displayCountdown = null,Object? verticalMarginBoxesFadeEnabled = null,Object? verticalMarginBoxesFadeLength = null,}) {
  return _then(_PrompterState(
speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,mirroredX: null == mirroredX ? _self.mirroredX : mirroredX // ignore: cast_nullable_to_non_nullable
as bool,mirroredY: null == mirroredY ? _self.mirroredY : mirroredY // ignore: cast_nullable_to_non_nullable
as bool,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,sideMargin: null == sideMargin ? _self.sideMargin : sideMargin // ignore: cast_nullable_to_non_nullable
as double,fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as TextAlign,displayReadingIndicatorBoxes: null == displayReadingIndicatorBoxes ? _self.displayReadingIndicatorBoxes : displayReadingIndicatorBoxes // ignore: cast_nullable_to_non_nullable
as bool,readingIndicatorBoxesHeight: null == readingIndicatorBoxesHeight ? _self.readingIndicatorBoxesHeight : readingIndicatorBoxesHeight // ignore: cast_nullable_to_non_nullable
as double,displayVerticalMarginBoxes: null == displayVerticalMarginBoxes ? _self.displayVerticalMarginBoxes : displayVerticalMarginBoxes // ignore: cast_nullable_to_non_nullable
as bool,verticalMarginBoxesHeight: null == verticalMarginBoxesHeight ? _self.verticalMarginBoxesHeight : verticalMarginBoxesHeight // ignore: cast_nullable_to_non_nullable
as double,countdownDuration: null == countdownDuration ? _self.countdownDuration : countdownDuration // ignore: cast_nullable_to_non_nullable
as double,displayCountdown: null == displayCountdown ? _self.displayCountdown : displayCountdown // ignore: cast_nullable_to_non_nullable
as bool,verticalMarginBoxesFadeEnabled: null == verticalMarginBoxesFadeEnabled ? _self.verticalMarginBoxesFadeEnabled : verticalMarginBoxesFadeEnabled // ignore: cast_nullable_to_non_nullable
as bool,verticalMarginBoxesFadeLength: null == verticalMarginBoxesFadeLength ? _self.verticalMarginBoxesFadeLength : verticalMarginBoxesFadeLength // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
