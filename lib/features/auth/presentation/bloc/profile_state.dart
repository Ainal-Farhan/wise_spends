import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/models/stored_file.dart';
import 'package:wise_spends/domain/models/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  /// The managed [StoredFile] record for the current profile image, if any.
  final StoredFile? profileImageFile;

  const ProfileLoaded(this.profile, {this.profileImageFile});

  @override
  List<Object?> get props => [profile, profileImageFile];
}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileImageUploading extends ProfileState {
  final UserProfile profile;

  const ProfileImageUploading(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileImageUpdated extends ProfileState {
  final UserProfile profile;
  final StoredFile imageFile;

  const ProfileImageUpdated(this.profile, this.imageFile);

  @override
  List<Object> get props => [profile, imageFile];
}

class ProfileBackupInProgress extends ProfileState {}

class ProfileBackupSuccess extends ProfileState {
  final String archivePath;

  const ProfileBackupSuccess(this.archivePath);

  @override
  List<Object> get props => [archivePath];
}

class ProfileRestoreSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}
