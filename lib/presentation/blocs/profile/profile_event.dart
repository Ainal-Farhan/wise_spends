import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/models/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final UserProfile profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object> get props => [profile];
}