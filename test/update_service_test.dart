import 'package:flutter_test/flutter_test.dart';
import 'package:lucro_dia/services/update_service.dart';

void main() {
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
}
