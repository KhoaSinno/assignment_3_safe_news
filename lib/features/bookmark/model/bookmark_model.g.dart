// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkModelAdapter extends TypeAdapter<BookmarkModel> {
  @override
  final int typeId = 0;

  @override
  BookmarkModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkModel(
      id: fields[0] as String,
      title: fields[1] as String,
      imageUrl: fields[2] as String,
      link: fields[3] as String,
      published: fields[4] as DateTime,
      summary: fields[5] as String,
      htmlContent: fields[6] as String,
      plainTextContent: fields[7] as String,
      bookmarkedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.link)
      ..writeByte(4)
      ..write(obj.published)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.htmlContent)
      ..writeByte(7)
      ..write(obj.plainTextContent)
      ..writeByte(8)
      ..write(obj.bookmarkedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
