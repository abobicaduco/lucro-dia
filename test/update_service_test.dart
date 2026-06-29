import 'package:flutter_test/flutter_test.dart';
import 'package:lucro_dia/services/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('normalizeVersion', () {
    test('remove o prefixo v e mantém só números/pontos', () {
      expect(UpdateService.normalizeVersion('v1.0.0'), '1.0.0');
      expect(UpdateService.normalizeVersion('1.2.3'), '1.2.3');
      expect(UpdateService.normalizeVersion('release-2.0'), '2.0');
    });
  });

  group('compareVersions', () {
    test('detecta versão mais nova (deve oferecer atualização)', () {
      // remoto > instalado  => > 0  => mostra diálogo
      expect(UpdateService.compareVersions('1.0.1', '1.0.0') > 0, isTrue);
      expect(UpdateService.compareVersions('1.1.0', '1.0.9') > 0, isTrue);
      expect(UpdateService.compareVersions('2.0.0', '1.9.9') > 0, isTrue);
    });

    test('mesma versão não oferece atualização', () {
      expect(UpdateService.compareVersions('1.0.0', '1.0.0'), 0);
    });

    test('versão instalada mais nova não oferece atualização', () {
      expect(UpdateService.compareVersions('1.0.0', '1.0.1') < 0, isTrue);
    });

    test('compara por número, não por texto (1.10 > 1.9)', () {
      expect(UpdateService.compareVersions('1.10.0', '1.9.0') > 0, isTrue);
    });

    test('tamanhos diferentes de versão', () {
      expect(UpdateService.compareVersions('1.0', '1.0.0'), 0);
      expect(UpdateService.compareVersions('1.0.1', '1.0') > 0, isTrue);
    });
  });

  group('lembrete diário (avisa 1x/dia até atualizar)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('não repete no mesmo dia para a mesma versão', () async {
      final s = UpdateService.instance;
      expect(await s.alreadyPromptedToday('1.0.1'), isFalse);
      await s.markPromptedToday('1.0.1');
      expect(await s.alreadyPromptedToday('1.0.1'), isTrue);
    });

    test('uma versão mais nova volta a avisar no mesmo dia', () async {
      final s = UpdateService.instance;
      await s.markPromptedToday('1.0.1');
      expect(await s.alreadyPromptedToday('1.0.2'), isFalse);
    });

    test('aviso de um dia anterior não conta para hoje', () async {
      SharedPreferences.setMockInitialValues({
        'update_prompt_date': '2000-1-1',
        'update_prompt_version': '1.0.1',
      });
      final s = UpdateService.instance;
      expect(await s.alreadyPromptedToday('1.0.1'), isFalse);
    });
  });
}
