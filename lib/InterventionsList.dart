import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Intervention {
  final String name;
  final String description;
  final IconData icon;

  Intervention({
    required this.name,
    required this.description,
    required this.icon,
  });

  String toFullDescription() => description;
}

class SupplementIntervention extends Intervention {
  final String dose;

  SupplementIntervention(
    this.dose, {
    required String name,
    required String description,
    required IconData icon,
  }) : super(
          name: name,
          description: description,
          icon: icon,
        );

  @override
  String toFullDescription() => "$description Dosage: $dose";
}

class Instance<T extends Intervention> {
  final T intervention;
  final DateTime time;

  Instance(this.intervention, this.time);
}

class InterventionListItem extends StatelessWidget {
  final Intervention item;
  final void Function()? onPressed;

  final void Function()? onPressedTrailing;

  const InterventionListItem(
      {Key? key, required this.item, this.onPressed, this.onPressedTrailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onTap: onPressed,
        child: ListTile(
          leading: Icon(item.icon),
          title: Text(item.name),
          trailing: IconButton(
            onPressed: onPressedTrailing,
            icon: const Icon(Icons.add_circle_outlined, size: 16.0),
          ),
        ),
      ),
    );
  }
}

class InterventionList<T> extends StatefulWidget {
  final void Function()? onPressed;

  const InterventionList(
      {Key? key,
      required this.interventions,
      required this.sort,
      required this.builder,
      this.onPressed})
      : super(key: key);
  final List<T> interventions;
  final int Function(T) sort;
  final Widget Function(BuildContext, Widget, T) builder;

  @override
  State<InterventionList<T>> createState() => _InterventionListState();
}

class _InterventionListState<T> extends State<InterventionList<T>> {
  @override
  void didUpdateWidget(covariant InterventionList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.interventions
        .sort((a, b) => widget.sort(a).compareTo(widget.sort(b)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        var item = widget.interventions[index];
        if (item is Intervention) {
          return widget.builder(
            context,
            InterventionListItem(item: item, onPressed: widget.onPressed),
            item,
          );
        } else if (item is Instance) {
          return widget.builder(
              context,
              InterventionListItem(
                  item: (item).intervention, onPressed: widget.onPressed),
              item);
        } else
          throw UnimplementedError("default list methed item stuff");
      },
      itemCount: widget.interventions.length,
    );
  }
}
