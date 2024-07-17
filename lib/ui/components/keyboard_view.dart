import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class KeyboardView extends StatefulWidget {
  const KeyboardView({
    super.key,
    required this.child,
    required this.inputAmount,
    required this.onClickSend,
    required this.isFiatInputMode,
    required this.buttonText,
    this.enable,
    this.disabledText,
    this.disabledColor,
    this.initialValue,
  });

  final Widget child;
  final RxString inputAmount;
  final Function onClickSend;
  final bool isFiatInputMode;
  final String buttonText;
  final bool? enable;
  final String? disabledText;
  final Color? disabledColor;
  final double? initialValue;

  @override
  State<StatefulWidget> createState() {
    return _KeyboardViewState();
  }
}

class _KeyboardViewState extends State<KeyboardView> {
  final _touchedItem = "".obs;

  _onClickKeyboard(String item) {
    _touchedItem.value = item;
    switch (item) {
      case "<":
        if (widget.inputAmount.value.length == 1) {
          widget.inputAmount.value = "0";
        } else {
          widget.inputAmount.value = widget.inputAmount.value.substring(0, widget.inputAmount.value.length - 1);
        }
        break;
      case ".":
        if (widget.inputAmount.value.endsWith(".")) {
          break;
        }

        widget.inputAmount.value += item;
        break;
      default:
        if (widget.inputAmount.value.length == 7) {
          return;
        }
        if (widget.inputAmount.value.contains(".")) {
          final v = widget.inputAmount.value.split(".")[1].length;
          if (!widget.isFiatInputMode && v == 5) {
            return;
          }
          if (widget.isFiatInputMode && v == 5) {
            return;
          }
        }

        if (widget.inputAmount.value == "0") {
          widget.inputAmount.value = item;
        } else {
          widget.inputAmount.value += item;
        }
    }
    _touchedItem.value = "";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.child,
          Expanded(
              child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Divider(color: Theme.of(context).dividerColor),
                                  Expanded(
                                      child: Row(
                                        children: [
                                          ...["1", "2", "3"].map((item) => Expanded(
                                            child: TextButton(
                                              onPressed: () {
                                                _onClickKeyboard(item);
                                              },
                                              child: Center(
                                                child: Text(item, style: Theme.of(context).textTheme.displayMedium)
                                              )
                                            )
                                          )).toList(),
                                        ],
                                      )
                                  ),
                                  Divider(color: Theme.of(context).dividerColor),
                                  Expanded(
                                      child: Row(
                                        children: [
                                          ...["4", "5", "6"].map((item) => Expanded(
                                              child: TextButton(
                                                  onPressed: () {
                                                    _onClickKeyboard(item);
                                                  },
                                                  child: Center(
                                                      child: Text(item, style: Theme.of(context).textTheme.displayMedium)
                                                  )
                                              )
                                          )).toList(),
                                        ],
                                      )
                                  ),
                                  Divider(color: Theme.of(context).dividerColor),
                                  Expanded(
                                      child: Row(
                                        children: [
                                          ...["7", "8", "9"].map((item) => Expanded(
                                              child: TextButton(
                                                  onPressed: () {
                                                    _onClickKeyboard(item);
                                                  },
                                                  child: Center(
                                                      child: Text(item, style: Theme.of(context).textTheme.displayMedium)
                                                  )
                                              )
                                          )).toList(),
                                        ],
                                      )
                                  ),
                                  Divider(color: Theme.of(context).dividerColor),
                                  Expanded(
                                      child: Row(
                                        children: [
                                          ...[".", "0", "<"].map((item) => Expanded(
                                              child: TextButton(
                                                  onPressed: () {
                                                    _onClickKeyboard(item);
                                                  },
                                                   child: Center(
                                                      child: Text(item, style: Theme.of(context).textTheme.displayMedium)
                                                  )
                                              )
                                          )).toList(),
                                        ],
                                      )
                                  ),
                                ],
                              )
                          )
                      ),
                      SizedBox(
                          height: 60,
                          child: widget.enable == true ? Material(
                              color: SurfyColor.blue,
                              child: InkWell(
                                  onTap: () {
                                    widget.onClickSend.call();
                                  },
                                  child: Center(
                                      child: Text(widget.buttonText, style: Theme.of(context).textTheme.titleLarge?.apply(color: Theme.of(context).primaryColorLight))
                                  )
                              )
                          ) : Container(
                            width: double.infinity,
                            height: 60,
                            color: widget.disabledColor,
                            child: Center(
                              child: Text(widget.disabledText ?? "", style: Theme.of(context).textTheme.titleLarge)
                            )
                          )
                      )
                    ],
                  )
              )
          )
        ],
      )
    );
  }
}