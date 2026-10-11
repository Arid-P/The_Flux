import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../focus/data/focus_session_repository.dart';
import '../../presets/presentation/presets_provider.dart';
import '../services/fd_integration_service.dart';

final fdIntegrationServiceProvider = Provider<FdIntegrationService>((ref) {
  final sessionRepo = ref.watch(focusSessionRepositoryProvider);
  final presetsRepo = ref.watch(presetsRepositoryProvider);

  final service = FdIntegrationService(
    sessionRepository: sessionRepo,
    presetsRepository: presetsRepo,
  );
  service.setupIntegration();
  return service;
});
