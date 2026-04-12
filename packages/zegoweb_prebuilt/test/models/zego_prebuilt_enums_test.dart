import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_prebuilt/src/zego_prebuilt_config.dart';

void main() {
  group('ZegoPrebuiltScenario', () {
    test('has all three values in order', () {
      expect(ZegoPrebuiltScenario.values, [
        ZegoPrebuiltScenario.oneOnOneCall,
        ZegoPrebuiltScenario.groupCall,
        ZegoPrebuiltScenario.videoConference,
      ]);
    });
  });

  group('ZegoPrebuiltLayout', () {
    test('has auto, sidebar, grid', () {
      expect(ZegoPrebuiltLayout.values, [
        ZegoPrebuiltLayout.auto,
        ZegoPrebuiltLayout.sidebar,
        ZegoPrebuiltLayout.grid,
      ]);
    });
  });

  group('ZegoPrebuiltVideoResolution', () {
    test('has sd180, sd360, sd480, hd720', () {
      expect(ZegoPrebuiltVideoResolution.values, [
        ZegoPrebuiltVideoResolution.sd180,
        ZegoPrebuiltVideoResolution.sd360,
        ZegoPrebuiltVideoResolution.sd480,
        ZegoPrebuiltVideoResolution.hd720,
      ]);
    });
  });

  group('ZegoPrebuiltLanguage', () {
    test('has english and chinese', () {
      expect(ZegoPrebuiltLanguage.values, [
        ZegoPrebuiltLanguage.english,
        ZegoPrebuiltLanguage.chinese,
      ]);
    });
  });
}
