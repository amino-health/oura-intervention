import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Future<Widget>? future;
  final WidgetBuilder loadingBuilder;

  const LoadingWidget({
    Key? key,
    this.future,
    this.loadingBuilder = _defaultLoadingBuilder,
  }) : super(key: key);

  static Widget _defaultLoadingBuilder(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: const [
      CircularProgressIndicator(),
      SizedBox(height: 16),
      Text("Loading...", style: TextStyle(fontSize: 10, color: Colors.black)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          } else if (snapshot.hasError) {
            throw snapshot.error!;
          } else {
            return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border.fromBorderSide(BorderSide()),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Builder(builder: (context) => loadingBuilder(context)),
            );
          }
        });
  }
}
