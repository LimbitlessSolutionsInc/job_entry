import 'package:flutter/material.dart';
import '../data/cardData.dart';
import 'taskWidgets.dart';
import '../../../styles/savedWidgets.dart';

/// Creates task cards with given information
class TaskCard extends StatelessWidget {
  const TaskCard({
    Key? key,
    required this.cardData,
    this.rotate = false,
    required this.height,
    required this.width,
    required this.context,
    //required this.users
  }):super(key: key);

  /// Object that contains data to be used to create card
  final CardData cardData;

  /// Used to determine card rotation when being dragged (default to 0.174533)
  final bool rotate;

  /// Height of card
  final double height;

  /// Width of card
  final double width;

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (cardData.dueDate != null) {
        DateTime now = DateTime.now();
        DateTime due = DateTime.parse(cardData.dueDate!.replaceAll('T', ' '));

        if (now.isAfter(due)) {
          return Colors.red;
        } else {
          return Colors.orange;
        }
      } else {
        return Colors.grey;
      }
    }

    int getPri(String? color) {
      switch (color) {
        case 'Low':
          return 1;
        case 'Medium':
          return 2;
        case 'High':
          return 3;
        default:
          return 0;
      }
    }

    Widget cardLabels() {
      List<Widget> label = [];
      if (cardData.labels != null) {
        for (String key in cardData.labels!.keys) {
          label.add(Container(
            width:
                20, //(cardData.labels![key]['name'].length*6.0 < 120)?cardData.labels![key]['name'].length*6.0:120,
            height: 7,
            margin: const EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(2.5)),
              color: Color(cardData.labels![key]['color']),
            ),
            // child: Text(
            //   cardData.labels![key]['name'],
            //   style: TextStyle(
            //     fontFamily: 'Klavika',
            //     package: 'css',
            //     fontSize: 12,
            //     color: Theme.of(context).primaryTextTheme.subtitle2!.color
            //   )
            // )
          ));
        }
      } else {
        label.add(Container(
          height: 0,
          margin: const EdgeInsets.all(5),
        ));
      }
      return Wrap(children: label);
    }

    Widget cardNotifications() {
        List<Widget> toReturn = [];
        int complete = 0;
        if (cardData.checkList != null) {
          for (int i = 0; i < cardData.checkList!.length; i++) {
            String st = 'st_${i.toString()}';
            if (cardData.checkList![st]['checked']) {
              complete++;
            }
          }
        }
        String date = '';
        if (cardData.dueDate != null) {
          List<String> split = cardData.dueDate!.split('T')[0].split('-');
          date = '${split[1]}/${split[2]}';
        }

        List<String> str = [
          date,
          '',
          (cardData.comments != null) ? cardData.comments!.length.toString() : '',
          '${complete.toString()}/' +
              ((cardData.checkList != null)
                  ? cardData.checkList!.length.toString()
                  : '')
        ];
        List<IconData> ico = [
          Icons.access_time,
          Icons.grading_rounded,
          Icons.chat_bubble_outline,
          Icons.check_box
        ];
        bool checkCase(int i) {
          switch (i) {
            case 0:
              if (cardData.dueDate != null) {
                return true;
              } else {
                return false;
              }
            case 1:
              if (cardData.description != '') {
                return true;
              } else {
                return false;
              }
            case 2:
              if (cardData.comments != null) {
                return true;
              } else {
                return false;
              }
            case 3:
              if (cardData.checkList != null) {
                return true;
              } else {
                return false;
              }
            default:
              return false;
          }
        }

        for (int i = 0; i < 4; i++) {
          if (checkCase(i)) {
            toReturn.add(TaskWidgets.iconNote(
                ico[i],
                str[i],
                TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).secondaryHeaderColor,//Theme.of(context).primaryTextTheme.subtitle1.color,
                    decoration: TextDecoration.none),
                15));
            toReturn.add(const SizedBox(width: 5));
          }
        }
        List<Widget> priority = [];

        for (int i = 0; i < getPri(cardData.level); i++) {
          priority.add(Container(
              margin: EdgeInsets.only(left: i * 5.0),
              child:
                  const Icon(Icons.priority_high, color: Colors.red, size: 13)));
        }

        if (priority.isEmpty) {
          priority.add(Container());
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Row(children: toReturn), Stack(children: priority)],
        );
    }

    Widget cardNames() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LSIUserIcon(
            uids: cardData.assigned!,
            colors: [Colors.teal[200]!, Colors.teal[600]!],
            iconSize: 25,
            viewidth: width - 30,
            //usersProfile: users,
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 2.5, color: getColor())),
          )
        ],
      );
    }

    Widget routerDates() {
      Widget dateText(String introText, String date) {
        return Row(
          children: [
            Text(introText, 
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 12,
                fontFamily: 'Klavika Bold',
                package: 'css',
                decoration: TextDecoration.none
              )
            ),
            Text(date,
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 12,
                fontFamily: 'MuseoSans',
                package: 'css',
                decoration: TextDecoration.none
              )
            )
          ]
        );
      }
        
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cardData.dateCreated != null ? dateText('Start Date: ', cardData.dateCreated!) : dateText('Start Date: ', '--/--/----'),
          cardData.dueDate != null ? dateText('Required Date: ', cardData.dueDate!) : dateText('Required Date: ', '--/--/----'),
          cardData.completedDate != null ? dateText('End Date: ', cardData.completedDate!) : dateText('End Date: ', '--/--/----')
        ],
      );
    }

    Widget routerNumbers() {
      Widget colorText(Color color, String text) {
        return Text(text,
          style: TextStyle(
            color: color,
            fontFamily: 'MuseoSans',
            package: 'css',
            fontSize: 10,
          )
        );
      }

      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    cardData.good != null ? colorText(Colors.green, cardData.good.toString()) : colorText(Colors.green, '---'),
                    colorText(Theme.of(context).secondaryHeaderColor, '/'),
                    cardData.bad != null ? colorText(Colors.red, cardData.bad.toString()) : colorText(Colors.red, '---')
                  ]
                ),
                colorText(Theme.of(context).secondaryHeaderColor, cardData.good.toString())
              ]
            ),
            LSIUserIcon(
              uids: cardData.assigned!,
              colors: [Colors.teal[200]!, Colors.teal[600]!],
              iconSize: 25,
              viewidth: width - 30,
              //usersProfile: users,
            ),
        ],
      );
    }

    return Transform.rotate(
        angle: (rotate) ? 0.174533 : 0,
        child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            margin: const EdgeInsets.only(bottom: 10),
            //height: height,
            width: width,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: cardLabels(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: SizedBox(
                          width: width - 70,
                          child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: cardData.title,
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 12,
                                    fontFamily: 'Klavika Bold',
                                    package: 'css',
                                    decoration: TextDecoration.none),
                              )))),
                  Text(
                    (cardData.points == 0) ? '' : cardData.points.toString(),
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 12,
                        fontFamily: 'Klavika Bold',
                        package: 'css',
                        decoration: TextDecoration.none),
                  )
                ],
              ),
              cardData.isRouter ? routerDates() : cardNames(),
              cardData.isRouter ? routerNumbers() : cardNotifications(),
            ])));
  }
}
