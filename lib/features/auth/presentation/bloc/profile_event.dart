import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wise_spends/domain/models/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final UserProfile profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object> get props => [profile];
}

/// Pick and upload a profile image from [source].
class PickProfileImageEvent extends ProfileEvent {
  final ImageSource source;

  const PickProfileImageEvent(this.source);

  @override
  List<Object> get props => [source];
}

/// Remove the current profile image.
class RemoveProfileImageEvent extends ProfileEvent {}

/// Trigger a backup and (optionally) share it.
class CreateBackupEvent extends ProfileEvent {
  final bool share;

  const CreateBackupEvent({this.share = false});

  @override
  List<Object> get props => [share];
}

/// Restore from a ZIP archive at [archivePath].
class RestoreBackupEvent extends ProfileEvent {
  final String archivePath;

  const RestoreBackupEvent(this.archivePath);

  @override
  List<Object> get props => [archivePath];
}
