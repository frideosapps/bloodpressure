import 'package:flutter/material.dart';

import 'package:frideos/frideos_flutter.dart';

import 'blocs/bloodpressure_bloc.dart';
import 'models/bloodpressure_model.dart';

class BloodPressureHistoryPage extends StatelessWidget {
  BloodPressureHistoryPage({Key key, @required this.bloc}) : super(key: key);

  final BloodPressureBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('History page'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
        child: StreamedWidget<List<BloodPressure>>(
            stream: bloc.result.historyStream,
            builder: (BuildContext context, AsyncSnapshot<List<BloodPressure>> snapshot) {

              if (snapshot.data.length == 0) {
                return Text('In this page will appear all the results.');
              }

              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {

                        var c = snapshot.data[index].classification;

                        return Card(
                          margin: EdgeInsets.all(4.0),
                          elevation: 2.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('${index + 1}'),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    resultsMap[c]['text'],
                                    style: TextStyle(
                                        color: resultsMap[c]['color'],
                                        fontSize: 20.0),
                                  ),
                                ),
                                Text('${snapshot.data[index].systolic}'),
                                Text('${snapshot.data[index].diastolic}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
