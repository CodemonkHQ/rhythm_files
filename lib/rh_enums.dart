// ignore_for_file: constant_identifier_names

enum Source {
  file,
  camera,
  gallery,
  url,
}

enum Target {
  cloudinary,
  multipart,
}

enum RhFileCall {
  pick,
  picker,
  uploader,
  compressFiles,
}

enum PickerType {
  single,
  multiple,
}

enum RhVideoQuality {
  DefaultQuality,
  LowQuality,
  MediumQuality,
  HighestQuality,
  Res640x480Quality,
  Res960x540Quality,
  Res1280x720Quality,
  Res1920x1080Quality
}
