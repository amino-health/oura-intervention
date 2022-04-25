import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ouraintervention/DetailedInterventions.dart';
import 'package:ouraintervention/InterventionsList.dart';
import 'package:ouraintervention/widgets/groupedBarChart.dart';

class InterventionsScreen extends StatefulWidget {
  InterventionsScreen({
    Key? key,
    required this.interventions,
  }) : super(key: key);

  final List<Intervention> interventions;

  @override
  State<InterventionsScreen> createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends State<InterventionsScreen> {
  int Function(Intervention) get sort => (item) => 0;

  final List<Instance> chosenInterventions = [];
  Intervention? selectedIntervention;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: InterventionList<Intervention>(
                onPressed: () => _logItem,
                interventions: widget.interventions,
                sort: sort,
                builder: (context, child, data) => InterventionListItem(
                    onPressed: () => _handleClickGeneral(data), item: data))),
        Expanded(
            child: DetailedIntervention(
          data: selectedIntervention,
        )),
        Expanded(
          child: InterventionList<Instance>(
            interventions: chosenInterventions,
            sort: (a) => 0,
            builder: (context, child, instance) => ElevatedButton(
              onPressed: () => print("instance"),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  void _handleClickGeneral(Intervention data) {
    setState(() => selectedIntervention = data);
  }

  void _logItem(Intervention data) {
    setState(
      () {
        chosenInterventions.add(Instance(data, DateTime.now()));
      },
    );
  }
}
