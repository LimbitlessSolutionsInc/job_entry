import 'package:flutter/material.dart';
import '../../../../styles/globals.dart';
import '../../../../src/database/database.dart';
import '../example/jobCard.dart';
import '../data/routerData.dart';
import '../data/jobData.dart';

class RouterArchiveManager extends StatefulWidget {
  const RouterArchiveManager({
    Key? key,
    this.width = 320,
    this.height = 360,
  }) : super(key: key);

  final double? height;
  final double? width;


  @override
  _RouterArchiveManagerState createState() => _RouterArchiveManagerState();
}

class _RouterArchiveManagerState extends State<RouterArchiveManager> {
  dynamic archives = {};

  @override
  void initState() {
    start();
    super.initState();
  }

  void start() async {
    try{
      await Database.once('router/archive', 'team').then((value) {
        setState(() {
          archives = value;
        });
      });
    }
    catch(e){
      print('start -> exception: $e');
    }
  }

  List<RouterData> routerData() {
    List<RouterData> data = [];
    if (archives != null && archives.isNotEmpty) {
      for (String key in archives.keys) {
        data.add(RouterData(
          color: archives[key]['details']['color'],
          title: archives[key]['details']['title'],
          id: key,
          createdBy: usersProfile[archives[key]['details']['createdBy']]
              ['displayName'],
          dateCreated: archives[key]['details']['dateCreated'],
          dateArchived: archives[key]['details']['dateArchived'] ?? DateTime.now().toString(),
          archivedBy: usersProfile[archives[key]['details']['archivedBy'] ?? currentUser.uid]
              ['displayName'],
        ));
      }
    }
    return data;
  }

  Widget archiveDetails(RouterData router){
    List<JobData> jobs = [];
    if(archives[router.id]['jobs'] != null){
      for(String key in archives[router.id]['jobs'].keys){
        final j = archives[router.id]['jobs'][key];
        jobs.add(JobData(
          id: key,
          title: j['title'],
          description: j['description'],
          dateCreated: j['dateCreated'],
          createdBy: j['createdBy'],
          priority: j['priority'] ?? 0,
          processId: j['processId'], 
          dueDate: j['dueDate'],
          completeDate: j['completedDate'],
          workers: List<String>.from(j['workers']),
          approvers: List<String>.from(j['approvers'] ?? []),
          numApprovals: List<String>.from(j['approvers'] ?? []).length,
          status: JobStatus.values.firstWhere((e) => e.toString().split('.').last == j['status']),
          good: j['good'],
          bad: j['bad'],
          isApproved: List<String>.from(j['isApproved'] ?? []),
          isArchive: j['isArchive'],
          notes: (j['notes'] != null)
              ? Map<String, dynamic>.from(j['notes'])
              : null,
          prevJobs: (j['prevJobs'] != null)
              ? Map<String, dynamic>.from(j['prevJobs'])
              : null,
        ));
      }
    }

    String process = '';
    int processCount = archives[router.id]['processes'].keys.length;
    for(int i = 0; i < processCount; i++){
      String key = archives[router.id]['processes'].keys.elementAt(i);
      print('Process Key: $key');

      process += '${archives[router.id]['processes'][key]['title']} ${i != processCount - 1 ? ' --> ' : ''}';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: deviceWidth * 0.4,
        height: deviceHeight * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              router.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryTextTheme.labelSmall!.color,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Processes: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryTextTheme.labelSmall!.color,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: deviceWidth * 0.4 - 40,
              child: Flex(
                direction: Axis.horizontal, 
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: Text(
                      process,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                      ),
                    )
                  ),
                ]
              )
            ),
            const SizedBox(height: 20),
            Text(
              'Jobs: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryTextTheme.labelSmall!.color,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: deviceHeight * 0.7 - 205,
              width: deviceWidth * 0.4 - 40,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  return JobCard(
                    context: context,
                    jobData: jobs[index],
                    fontSize: 15,
                    isArchive: true,
                    width: deviceWidth * 0.4 - 80
                  );
                }
              )
            )
          ],
        ),
      ),
    );
  }

  Widget archiveCards(){
    List<Widget> cards = [];
    for(RouterData router in routerData()){
      cards.add(
        InkWell(
          onTap: (){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return archiveDetails(router);
              }
            );
          },
          child: Container(
            width: 265,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  router.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Created by: ${router.createdBy} on ${router.dateCreated.split('T')[0]}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Archived by: ${router.archivedBy} on ${router.dateArchived.split('T')[0]}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                  ),
                ),
              ],
            ),
          )
        )
      );
    }
    return Wrap(
      children: cards,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: archiveCards(),
      ),
    );
  }
}