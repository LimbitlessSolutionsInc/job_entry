import 'package:flutter/material.dart';
import '../data/jobData.dart';
import 'taskWidgets.dart';
import '../../../styles/savedWidgets.dart';

// Creates job card with given information
class JobCard extends StatelessWidget {
  const JobCard({
    Key? key,
    required this.jobData,
    this.rotate = false,
    required this.height,
    required this.width,
    required this.context,
  }):super(key: key);

  // Object that contains data to be used to create card
  final JobData jobData;

  // Used to determine card rotation when being dragged (default to 0.174533)
  final bool rotate;

  // Height of card
  final double height;

  // Width of card
  final double width;

  final BuildContext context;

  @override
  Widget build(BuildContext context) {

    // Widget jobTitle() {

    // }

    // Widget jobWorkers() {

    // }

    // created date, due date, complete date
    Widget jobDates() {
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
          jobData.dateCreated != null ? dateText('Start Date: ', jobData.dateCreated!) : dateText('Start Date: ', '--/--/----'),
          jobData.dueDate != null ? dateText('Required Date: ', jobData.dueDate!) : dateText('Required Date: ', '--/--/----'),
          jobData.completeDate != null ? dateText('End Date: ', jobData.completeDate!) : dateText('End Date: ', '--/--/----')
        ],
      );
    }

    // good and bad count
    Widget jobNumbers() {
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
                    jobData.good != null ? colorText(Colors.green, jobData.good.toString()) : colorText(Colors.green, '---'),
                    colorText(Theme.of(context).secondaryHeaderColor, '/'),
                    jobData.bad != null ? colorText(Colors.red, jobData.bad.toString()) : colorText(Colors.red, '---')
                  ]
                ),
                colorText(Theme.of(context).secondaryHeaderColor, jobData.good.toString())
              ]
            ),
            LSIUserIcon(
              uids: jobData.workers,
              colors: [Colors.teal[200]!, Colors.teal[600]!],
              iconSize: 25,
              viewidth: width - 55,
              //usersProfile: users,
            ),
        ],
      );

    }

    // bool to change border color and activate dragging
    // bool isApproved() {

    // }

    return Transform.rotate(
        angle: (rotate) ? 0.174533 : 0,
        child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            margin: const EdgeInsets.only(bottom: 10),
            height: height,
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
                                text: jobData.title,
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 15,
                                    fontFamily: 'Klavika Bold',
                                    package: 'css',
                                    decoration: TextDecoration.none),
                              )))),
                ],
              ),
              jobDates(),
              jobNumbers(),
            ])));
  }
}