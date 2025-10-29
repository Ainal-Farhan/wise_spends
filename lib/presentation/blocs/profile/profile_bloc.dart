import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/repositories/common/i_user.repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IUserRepository _repository;

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getCurrentUser();
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

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
        emit(ProfileError('Failed to update profile'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
