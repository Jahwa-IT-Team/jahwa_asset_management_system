import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jahwa_asset_management_system/provider/facility_trade_common_repository.dart';
import 'package:provider/provider.dart';

class PointerThisPlease<T> {
  T value;
  PointerThisPlease(this.value);
}

class NotGiven {
  const NotGiven();
}

Widget prepareWidget(dynamic object,
    {dynamic parameter = const NotGiven(),
    BuildContext context,
    Function stringToWidgetFunction}) {
  if (object == null) {
    return (null);
  }
  if (object is Widget) {
    return (object);
  }
  if (object is String) {
    if (stringToWidgetFunction == null) {
      return (Text(object));
    } else {
      return (stringToWidgetFunction(object));
    }
  }
  if (object is Function) {
    if (parameter is NotGiven) {
      if (context == null) {
        return (prepareWidget(object(),
            stringToWidgetFunction: stringToWidgetFunction));
      } else {
        return (prepareWidget(object(context),
            stringToWidgetFunction: stringToWidgetFunction));
      }
    }
    if (context == null) {
      return (prepareWidget(object(parameter),
          stringToWidgetFunction: stringToWidgetFunction));
    }
    return (prepareWidget(object(parameter, context),
        stringToWidgetFunction: stringToWidgetFunction));
  }
  return (Text("Unknown type: ${object.runtimeType.toString()}"));
}

class UserDropdownDialog<T> extends StatefulWidget {
  final Widget hint;
  final dynamic closeButton;
  final TextInputType keyboardType;
  final bool multipleSelection;
  final List<int> selectedItems;
  final Function displayItem;
  final dynamic doneButton;
  final Function validator;
  final bool dialogBox;
  final PointerThisPlease<bool> displayMenu;
  final BoxConstraints menuConstraints;
  final Function callOnPop;
  final Color menuBackgroundColor;

  UserDropdownDialog({
    Key key,
    this.hint,
    this.closeButton,
    this.keyboardType,
    this.multipleSelection,
    this.selectedItems,
    this.displayItem,
    this.doneButton,
    this.validator,
    this.dialogBox,
    this.displayMenu,
    this.menuConstraints,
    this.callOnPop,
    this.menuBackgroundColor,
  }) : super(key: key);

  _UserDropdownDialogState<T> createState() =>
      new _UserDropdownDialogState<T>();
}

class _UserDropdownDialogState<T> extends State<UserDropdownDialog> {
  TextEditingController txtSearch = new TextEditingController();
  TextStyle defaultButtonStyle =
      new TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  FacilityTradeCommonRepository $facilityTradeCommonRepository;

  _UserDropdownDialogState();

  dynamic get selectedResult {
    return (widget.multipleSelection
        ? widget.selectedItems
        : widget.selectedItems?.isNotEmpty ?? false
            ? $facilityTradeCommonRepository
                .searchManagerDropdownMenuItem[widget.selectedItems.first]
                ?.value
            : null);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if ($facilityTradeCommonRepository == null) {
      $facilityTradeCommonRepository =
          Provider.of<FacilityTradeCommonRepository>(context, listen: true);
    }

    return AnimatedContainer(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 300),
      child: new Card(
        color: widget.menuBackgroundColor,
        margin: EdgeInsets.symmetric(
            vertical: widget.dialogBox ? 10 : 5,
            horizontal: widget.dialogBox ? 10 : 4),
        child: new Container(
          constraints: widget.menuConstraints,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              titleBar(),
              searchBar(),
              list(),
              closeButtonWrapper(),
            ],
          ),
        ),
      ),
    );
  }

  bool get valid {
    if (widget.validator == null) {
      return (true);
    }
    return (widget.validator(selectedResult) == null);
  }

  Widget titleBar() {
    var validatorOutput;
    if (widget.validator != null) {
      validatorOutput = widget.validator(selectedResult);
    }

    Widget validatorOutputWidget = valid
        ? SizedBox.shrink()
        : validatorOutput is String
            ? Text(
                validatorOutput,
                style: TextStyle(color: Colors.red, fontSize: 13),
              )
            : validatorOutput;

    Widget doneButtonWidget =
        widget.multipleSelection || widget.doneButton != null
            ? prepareWidget(widget.doneButton,
                parameter: selectedResult,
                context: context, stringToWidgetFunction: (string) {
                return (TextButton.icon(
                    onPressed: !valid
                        ? null
                        : () {
                            pop();
                            setState(() {});
                          },
                    icon: Icon(Icons.close),
                    label: Text(string)));
              })
            : SizedBox.shrink();
    return widget.hint != null
        ? new Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  prepareWidget(widget.hint),
                  Column(
                    children: <Widget>[doneButtonWidget, validatorOutputWidget],
                  ),
                ]),
          )
        : new Container(
            child: Column(
              children: <Widget>[doneButtonWidget, validatorOutputWidget],
            ),
          );
  }

  Widget searchBar() {
    return new Container(
      child: new Stack(
        children: <Widget>[
          new TextField(
            controller: txtSearch,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            autofocus: true,
            onChanged: (value) {
              $facilityTradeCommonRepository.getSearchUserList(value);
              //setState(() {});
            },
            keyboardType: widget.keyboardType,
          ),
          new Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: new Center(
              child: new Icon(
                Icons.search,
                size: 24,
              ),
            ),
          ),
          txtSearch.text.isNotEmpty
              ? new Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: new Center(
                    child: new InkWell(
                      onTap: () {
                        setState(() {
                          txtSearch.text = '';
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: new Container(
                        width: 32,
                        height: 32,
                        child: new Center(
                          child: new Icon(
                            Icons.close,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : new Container(),
        ],
      ),
    );
  }

  pop() {
    if (widget.dialogBox) {
      //$facilityTradeCommonRepository.clearSearchManagerList(false);
      Navigator.pop(context);
    } else {
      widget.displayMenu.value = false;
      if (widget.callOnPop != null) {
        widget.callOnPop();
      }
    }
  }

  Widget list() {
    return new Expanded(
      child: Scrollbar(
        child: new ListView.builder(
          itemCount: $facilityTradeCommonRepository
              .searchManagerDropdownMenuItem.length,
          itemBuilder: (context, index) {
            DropdownMenuItem item = $facilityTradeCommonRepository
                .searchManagerDropdownMenuItem[index];
            return new InkWell(
              onTap: () {
                if (widget.multipleSelection) {
                  setState(() {
                    if (widget.selectedItems.contains(index)) {
                      widget.selectedItems.remove(index);
                    } else {
                      widget.selectedItems.add(index);
                    }
                  });
                } else {
                  widget.selectedItems.clear();
                  widget.selectedItems.add(index);
                  if (widget.doneButton == null) {
                    pop();
                  } else {
                    setState(() {});
                  }
                }
              },
              child: widget.multipleSelection
                  ? widget.displayItem == null
                      ? (Row(children: [
                          Icon(
                            widget.selectedItems.contains(index)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Flexible(child: item),
                        ]))
                      : widget.displayItem(
                          item, widget.selectedItems.contains(index))
                  : widget.displayItem == null
                      ? item
                      : widget.displayItem(item, item.value == selectedResult),
            );
          },
        ),
      ),
    );
  }

  Widget closeButtonWrapper() {
    return (prepareWidget(widget.closeButton, parameter: selectedResult,
            stringToWidgetFunction: (string) {
          return (Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    pop();
                  },
                  child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 2),
                      child: Text(
                        string,
                        style: defaultButtonStyle,
                        overflow: TextOverflow.ellipsis,
                      )),
                )
              ],
            ),
          ));
        }) ??
        SizedBox.shrink());
  }
}
