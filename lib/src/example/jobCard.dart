import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../styles/globals.dart';
import '../data/jobData.dart';
import '../../../../styles/savedWidgets.dart';

// Creates job card with given information
class JobCard extends StatelessWidget {
  const JobCard({
    Key? key,
    required this.jobData,
    this.rotate = false,
    this.isArchive = false,
    this.fontSize = 12,
    this.height,
    required this.width,
    required this.context,
    this.processIndex = 0,
  }):super(key: key);

  // Object that contains data to be used to create card
  final JobData jobData;

  // Used to determine card rotation when being dragged (default to 0.174533)
  final bool rotate;

  // Height of card
  final double? height;

  // Width of card
  final double width;

  final BuildContext context;

  final int processIndex;

  final bool isArchive;

  final double fontSize;

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
                fontSize: fontSize,
                fontFamily: 'NotoSans Bold',
                package: 'css',
                decoration: TextDecoration.none
              )
            ),
            Text(
              date,
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: fontSize,
                fontFamily: 'OpenSans',
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
          jobData.startDate != null ? dateText('Start Date: ', jobData.startDate!) : dateText('Start Date: ', 'N/A'),
          jobData.dueDate != null ? dateText('Required Date: ', jobData.dueDate!) : dateText('Required Date: ', 'N/A'),
          jobData.completeDate != null ? dateText('End Date: ', jobData.completeDate!) : dateText('End Date: ', 'N/A')
        ],
      );
    }

    // good and bad count
    Widget jobNumbers() {
      Widget colorText(Color color, String text) {
        return Text(
          text,
          style: TextStyle(
            color: color,
            fontFamily: 'OpenSans',
            package: 'css',
            fontSize: fontSize,
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
              jobData.good != null ? colorText(Theme.of(context).secondaryHeaderColor, jobData.good.toString()) : colorText(Theme.of(context).secondaryHeaderColor, '---')
            ]
          ),
          if(!isArchive) LSIUserIcon(
            uids: jobData.workers,
            colors: [Colors.teal[200]!, Colors.teal[600]!],
            iconSize: 25,
            viewidth: width - 60,
            //usersProfile: users,
          ),
        ],
      );
    }

    Widget archiveInfo() {
      List<Widget> approvedByWidgets = [];
      List<Widget> notes = [];

      for(var date in jobData.isApproved) {
        print('date: $date');

        approvedByWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 2),
            child: Text(
              '- $date by ${usersProfile[jobData.approvers[0]]['displayName']}',
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: fontSize,
                fontFamily: 'OpenSans',
                package: 'css',
                decoration: TextDecoration.none
              )
            )
          )
        );
      }

      if(jobData.notes != null) {
        for(var noteKey in jobData.notes!.keys) {
          print('noteKey: $noteKey ${jobData.notes![noteKey]}');
          notes.add(
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1.0,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Theme.of(context).canvasColor,
              ),
              padding: const EdgeInsets.only(left: 10, top: 2, bottom: 5),
              margin: const EdgeInsets.only(left: 10, top: 5),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          "Posted By:  ",
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodyMedium!
                              .copyWith(fontSize: fontSize)
                        )
                      ),
                      Text(
                        usersProfile[jobData.notes![noteKey]['createdBy']]!['displayName'],
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyMedium!
                            .copyWith(fontSize: fontSize)
                      )
                    ]
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 230,
                    child: Flex(
                      direction: Axis.horizontal, 
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            jobData.notes![noteKey]['comment'],
                            style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(fontSize: fontSize)
                          )
                        ),
                      ]
                    )
                  ),
                  const SizedBox(height: 10),
                  if (jobData.notes![noteKey]['dateCreated'] != null) Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 15,
                        color: Theme.of(context).primaryTextTheme.bodySmall!.color
                      ),
                      Text(
                        jobData.notes![noteKey]['dateCreated'],
                        style: Theme.of(context).primaryTextTheme.bodySmall
                      )
                    ]
                  )
                ],
              )
            )
          );
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'Approval History: ',
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontSize: fontSize,
              fontFamily: 'NotoSans Bold',
              package: 'css',
              decoration: TextDecoration.none
            )
          ),
          ...approvedByWidgets,
          const SizedBox(height: 10),
          Text(
            'Workers: ',
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontSize: fontSize,
              fontFamily: 'NotoSans Bold',
              package: 'css',
              decoration: TextDecoration.none
            )
          ),
          for(var worker in jobData.workers)
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 2),
              child: Text(
                '- ${usersProfile[worker]!['displayName']}',
                style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontSize: fontSize,
                  fontFamily: 'OpenSans',
                  package: 'css',
                  decoration: TextDecoration.none
                )
              ),
            ),
          const SizedBox(height: 10),
          if(notes.isNotEmpty)Text(
            'Notes: ',
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontSize: fontSize,
              fontFamily: 'NotoSans Bold',
              package: 'css',
              decoration: TextDecoration.none
            )
          ),
          ...notes
        ]
      );
    }

    return Transform.rotate(
      angle: (rotate) ? -0.174533 : 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
        margin: const EdgeInsets.only(bottom: 10),
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(
            color: isArchive ? Theme.of(context).dividerColor : processIndex >= jobData.isApproved.length ? Colors.red : Colors.green,
            width: 2.0,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            SizedBox(
              width: width - 70,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: jobData.title,
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: fontSize + 3,
                    fontFamily: 'NotoSans Bold',
                    fontWeight: FontWeight.bold,
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                )
              )
            ),
            jobDates(),
            jobNumbers(),
            if(isArchive)archiveInfo()
          ]
        ),
      )
    );
  }
}