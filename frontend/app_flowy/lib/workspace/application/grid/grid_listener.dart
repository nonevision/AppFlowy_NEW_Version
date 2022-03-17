import 'package:flowy_sdk/protobuf/dart-notify/subject.pb.dart';
import 'package:flowy_sdk/protobuf/flowy-error/errors.pb.dart';
import 'package:flowy_sdk/protobuf/flowy-grid-data-model/grid.pb.dart';
import 'package:flowy_sdk/protobuf/flowy-grid/dart_notification.pb.dart';
import 'package:flowy_sdk/rust_stream.dart';
import 'package:flowy_infra/notifier.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:app_flowy/core/notification_helper.dart';
import 'package:dartz/dartz.dart';

typedef GridBlockUpdateNotifiedValue = Either<GridBlockId, FlowyError>;

class GridListener {
  final String gridId;
  PublishNotifier<GridBlockUpdateNotifiedValue> blockUpdateNotifier = PublishNotifier<GridBlockUpdateNotifiedValue>();
  StreamSubscription<SubscribeObject>? _subscription;
  late GridNotificationParser _parser;

  GridListener({required this.gridId});

  void start() {
    _parser = GridNotificationParser(
      id: gridId,
      callback: (ty, result) {
        _handleObservableType(ty, result);
      },
    );

    _subscription = RustStreamReceiver.listen((observable) => _parser.parse(observable));
  }

  void _handleObservableType(GridNotification ty, Either<Uint8List, FlowyError> result) {
    switch (ty) {
      case GridNotification.GridDidUpdateBlock:
        result.fold(
          (payload) => blockUpdateNotifier.value = left(GridBlockId.fromBuffer(payload)),
          (error) => blockUpdateNotifier.value = right(error),
        );
        break;

      default:
        break;
    }
  }

  Future<void> close() async {
    await _subscription?.cancel();
    blockUpdateNotifier.dispose();
  }
}
