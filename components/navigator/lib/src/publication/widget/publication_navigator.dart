// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:awesome_loader/awesome_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_commons/utils/functions.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';

typedef WidgetErrorBuilder = void Function(BuildContext, UserException);

typedef WrapperWidgetBuilder = Widget Function(
    BuildContext, Widget, List<Link>, ServerStarted);

abstract class PublicationNavigator extends StatefulWidget {
  final WidgetBuilder waitingScreenBuilder;
  final WidgetErrorBuilder displayErrorBuilder;
  final Consumer<ReaderContext> onReaderContextCreated;
  final WrapperWidgetBuilder? wrapper;
  final PublicationController publicationController;

  const PublicationNavigator({
    Key? key,
    required this.waitingScreenBuilder,
    required this.displayErrorBuilder,
    required this.onReaderContextCreated,
    required this.wrapper,
    required this.publicationController,
  }) : super(key: key);
}

abstract class PublicationNavigatorState<T extends PublicationNavigator>
    extends State<T> {
  ReaderContext? readerContext;

  PublicationController get publicationController =>
      widget.publicationController;

  @override
  void initState() {
    publicationController.init();
    super.initState();
  }

  @override
  void dispose() {
    readerContext?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<CurrentSpineItemBloc>(
        create: (BuildContext context) =>
            publicationController.currentSpineItemBloc,
        child: FutureBuilder<ReaderContext>(
            future: publicationController.createReaderContext(context),
            builder:
                (BuildContext context, AsyncSnapshot<ReaderContext> snapshot) {
              if (!snapshot.hasData) {
                return widget.waitingScreenBuilder(context);
              }
              readerContext = snapshot.data;
              return buildUiForReaderContext(context, readerContext!);
            }),
      );

  Widget buildUiForReaderContext(
      BuildContext context, ReaderContext readerContext) {
    widget.onReaderContextCreated(readerContext);
    if (readerContext.hasError) {
      widget.displayErrorBuilder(context, readerContext.userException!);
      return widget.waitingScreenBuilder(context);
    }
    publicationController.initReaderContext(readerContext);
    List<Link> spine = readerContext.publication!.pageLinks;
    publicationController.startServer();
    return ReaderContextWidget(
      readerContext: readerContext,
      child: BlocBuilder(
          bloc: publicationController.serverBloc,
          builder: (BuildContext context, ServerState state) =>
              (state is ServerStarted)
                  ? wrapReaderView(spine, state)
                  : widget.waitingScreenBuilder(context)),
    );
  }

  Widget wrapReaderView(List<Link> spine, ServerStarted serverState) {
    if (widget.wrapper != null) {
      return widget.wrapper!(
          context, buildReaderView(spine, serverState), spine, serverState);
    }
    return buildReaderView(spine, serverState);
  }

  Widget buildReaderView(List<Link> spine, ServerStarted serverState);

  Widget buildProgressIndicatorOld(BuildContext context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary),
        ),
      );

  Widget buildProgressIndicator(BuildContext context) => Center(
      child: AwesomeLoader(
          color: Theme.of(context).colorScheme.secondary,
          loaderType: AwesomeLoader.AwesomeLoader3));
}
