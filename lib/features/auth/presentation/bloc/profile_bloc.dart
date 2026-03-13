import 'package:bloc/bloc.dart';
import 'package:wise_spends/core/services/document_service.dart';
import 'package:wise_spends/data/repositories/common/i_user.repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IUserRepository _repository;
  final DocumentService _documentService;

  ProfileBloc(this._repository, {DocumentService? documentService})
    : _documentService = documentService ?? DocumentService.instance,
      super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<PickProfileImageEvent>(_onPickProfileImage);
    on<RemoveProfileImageEvent>(_onRemoveProfileImage);
    on<CreateBackupEvent>(_onCreateBackup);
    on<RestoreBackupEvent>(_onRestoreBackup);
  }

  // ─── Load ──────────────────────────────────────────────────────────────────

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await _repository.getCurrentUser();
      if (user == null) {
        emit(const ProfileError('User not found'));
        return;
      }
      final profile = UserProfile.fromCmmnUser(user);
      final imageFile = await _documentService.getProfileImage(profile.id);
      emit(ProfileLoaded(profile, profileImageFile: imageFile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final success = await _repository.updateProfile(event.profile);
      if (success) {
        emit(ProfileUpdated(event.profile));
      } else {
        emit(const ProfileError('Failed to update profile'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // ─── Pick profile image ────────────────────────────────────────────────────

  Future<void> _onPickProfileImage(
    PickProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    UserProfile? profile;
    if (currentState is ProfileLoaded) profile = currentState.profile;
    if (profile == null) return;

    emit(ProfileImageUploading(profile));

    try {
      final result = await _documentService.pickAndStoreProfileImage(
        source: event.source,
        userId: profile.id,
      );

      if (result.isSuccess) {
        // Update profileImageUrl in DB
        final updated = profile.copyWith(
          profileImageUrl: result.data!.localPath,
          dateUpdated: DateTime.now(),
        );
        await _repository.updateProfile(updated);

        emit(ProfileImageUpdated(updated, result.data!));
        // Reload so the screen rebuilds cleanly
        add(LoadProfileEvent());
      } else {
        emit(ProfileError(result.error ?? 'Image upload failed'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // ─── Remove profile image ──────────────────────────────────────────────────

  Future<void> _onRemoveProfileImage(
    RemoveProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    final profile = currentState.profile;
    if (currentState.profileImageFile != null) {
      await _documentService.deleteFile(currentState.profileImageFile!.id);
    }
    final updated = profile.copyWith(
      profileImageUrl: null,
      dateUpdated: DateTime.now(),
    );
    await _repository.updateProfile(updated);
    add(LoadProfileEvent());
  }

  // ─── Backup ────────────────────────────────────────────────────────────────

  Future<void> _onCreateBackup(
    CreateBackupEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileBackupInProgress());
    try {
      final result = event.share
          ? await _documentService.createAndShareBackup()
          : await _documentService.createBackup();

      if (result.isSuccess) {
        emit(ProfileBackupSuccess(result.data!));
      } else {
        emit(ProfileError(result.error ?? 'Backup failed'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // ─── Restore ───────────────────────────────────────────────────────────────

  Future<void> _onRestoreBackup(
    RestoreBackupEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileBackupInProgress());
    try {
      final result = await _documentService.restoreFromBackup(
        event.archivePath,
      );
      if (result.isSuccess) {
        emit(ProfileRestoreSuccess());
        add(LoadProfileEvent());
      } else {
        emit(ProfileError(result.error ?? 'Restore failed'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
