/*
  @author     : karthick.d  07/10/2025
  @desc       : DraggableHolder widget is that wraps the dragged formcontrol
                inside a stack widget and a label container , you can use this 
                widget to stack any widget u need above or below the dragged
                form control
*/
import 'package:dashboard/bloc/bpinbox/model/bpwiddgetinboxprops.dart';
import 'package:dashboard/widgets/lead_tile_card.dart';
import 'package:flutter/material.dart';

class DraggedInboxHolder extends StatefulWidget {
  final String labelText;
  final VoidCallback? onTapDraggedControl;
  final BPWidgetInboxProps? inboxProps;
  const DraggedInboxHolder({
    super.key,
    required this.labelText,
    this.onTapDraggedControl,
    this.inboxProps
  });

  @override
  State<DraggedInboxHolder> createState() => _DraggedInboxHolderState();
}

class _DraggedInboxHolderState extends State<DraggedInboxHolder> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapDraggedControl,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade200,
              borderRadius: BorderRadius.circular(15),
            ),
            constraints: BoxConstraints(minWidth: 100, maxHeight: 15),
            child: Center(
              child: Text(
                widget.labelText,
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.end,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return LeadTileCard(
                      title: widget.inboxProps!.title != '' ? widget.inboxProps!.title : 'title',
                      subtitle: widget.inboxProps!.subtitle != '' ? widget.inboxProps!.subtitle : 'subtitle',
                      icon: Icons.person,
                      color: Colors.teal,
                      phone: widget.inboxProps!.key1 != '' ? widget.inboxProps!.key1 : 'key1',
                      createdon: widget.inboxProps!.key2 != '' ? widget.inboxProps!.key2 : 'key2',
                      location: widget.inboxProps!.key3 != '' ? widget.inboxProps!.key3 : 'key3',
                      loanamount: '12345',
                    );
                  },
                )
            ),
          ),
        ],
      ),
    );
  }
}
