// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/widgets.dart';
import 'package:model/css/reader_theme_repository.dart';
import 'package:model/model.dart';
import 'package:ui_commons/document_opener/document_opener.dart';
import 'package:navigator/epub.dart';

class EpubDocumentOpener extends DocumentOpener {
  final ReaderThemeRepository readerThemeRepository;

  EpubDocumentOpener(this.readerThemeRepository);

  @override
  Widget buildDocumentScreen(
    FileDocument document, {
    bool simplifiedMode = false,
    OnCloseDocument onCloseDocument,
  }) =>
      EpubBookScreen(
        readerThemeRepository,
        book: document as Book,
        simplifiedMode: simplifiedMode,
        onCloseDocument:
            onCloseDocument ?? DocumentOpener.defaultOnCloseDocument,
      );
}
