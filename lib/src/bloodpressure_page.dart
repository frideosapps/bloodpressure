import 'package:flutter/material.dart';

import 'package:frideos/frideos_flutter.dart';

import 'bloodpressure_history.dart';
import 'models/bloodpressure_model.dart';
import 'blocs/bloodpressure_bloc.dart';
import 'blocs/bloc_provider.dart';

class BloodPressurePage extends StatefulWidget {
  @override
  _BloodPressurePageState createState() {
    return new _BloodPressurePageState();
  }
}

class _BloodPressurePageState extends State<BloodPressurePage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> boxAnimation;
  Animation<double> classificationAnimation;
  Animation<Offset> pulseAnimation;
  Animation<Offset> meanAnimation;
  bool isExamineClicked = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);

    boxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0,
          0.5,
          curve: Curves.decelerate,
        ),
      ),
    );

    classificationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.5,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    );

    pulseAnimation = Tween<Offset>(
      begin: Offset(6.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.5,
          0.7,
          curve: Curves.ease,
        ),
      ),
    );

    meanAnimation = Tween<Offset>(
      begin: Offset(6.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.7,
          0.9,
          curve: Curves.ease,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BloodPressureBloc bloc = BlocProvider.of(context);

    Widget _buildResultRow(String text, String value) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Text(text,
                style: TextStyle(
                  fontSize: 16.0,
                )),
            Container(
              width: 12.0,
            ),
            Text(
              value + ' mmHg',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
              key: Key(text),
            ),
          ],
        ),
      );
    }

    Widget _buildClassificationRow(Classification c) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              resultsMap[c]['text'],
              style: TextStyle(
                  color: resultsMap[c]['color'],
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700),
              key: Key('Classification'),
            ),
          ),
        ],
      );
    }

    Widget resultWidget() {
      _checkAnimation() {
        //
        // If the isExamineClicked is true (set to true on the onPressed handler of the button)
        // then reset the animation and play it. Set the isExamineClicked to false to avoid
        // play it again when the widget refreshes
        //
        if (isExamineClicked) {
          controller.reset();
          controller.forward();
          isExamineClicked = false;
        }
      }

      return StreamedWidget<BloodPressure>(
        key: Key('Result'),
        stream: bloc.result.outStream,
        noDataChild: Padding(
            padding: EdgeInsets.all(18.0),
            child: Text('Fill the form and click on examine',
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 18.0))),
        builder: (context, AsyncSnapshot<BloodPressure> snapshot) {
          //
          // Need to play the animation?
          //
          _checkAnimation();

          var container = Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              border:
                  Border.all(color: Theme.of(context).primaryColor, width: 4.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              key: Key('ResultColumn'),
              children: <Widget>[
                SizeTransition(
                  sizeFactor: classificationAnimation,
                  child: _buildClassificationRow(snapshot.data.classification),
                ),
                FadeTransition(
                  opacity: classificationAnimation,
                  child: _buildResultRow(
                      'Systolic:', snapshot.data.systolic.toStringAsFixed(0)),
                ),
                FadeTransition(
                  opacity: classificationAnimation,
                  child: _buildResultRow(
                      'Diastolic:', snapshot.data.diastolic.toStringAsFixed(0)),
                ),
                SlideTransition(
                  position: pulseAnimation,
                  child: _buildResultRow(
                      'Pulse:', snapshot.data.pulse.toStringAsFixed(0)),
                ),
                SlideTransition(
                  position: meanAnimation,
                  child: _buildResultRow(
                      'Mean:', snapshot.data.map.toStringAsFixed(2)),
                ),
              ],
            ),
          );

          return ScaleTransition(
            scale: boxAnimation,
            child: container,
          );
        },
      );
    }

    Widget systolicInput() {
      return StreamBuilder(
        stream: bloc.systolic.outTransformed,
        builder: (context, AsyncSnapshot snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 20.0,
            ),
            child: TextField(
              key: Key('systolic'),
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Systolic',
                hintText: 'Insert the systolic pressure',
                errorText: snapshot.error,
              ),
              keyboardType: TextInputType.number,
              onChanged: bloc.systolic.inStream,
            ),
          );
        },
      );
    }

    Widget diastolicInput() {
      return StreamBuilder(
        stream: bloc.diastolic.outTransformed,
        builder: (context, AsyncSnapshot snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 20.0,
            ),
            child: TextField(
              key: Key('diastolic'),
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Diastolic',
                hintText: 'Insert the diastolic pressure',
                errorText: snapshot.error,
              ),
              keyboardType: TextInputType.number,
              onChanged: bloc.diastolic.inStream,
            ),
          );
        },
      );
    }

    Widget examineButton() {
      void _examine() {
        bloc.examine();
        //
        // Set the isExamineClicked to tell the widget to play the animation
        //
        isExamineClicked = true;
      }

      return StreamBuilder(
        stream: bloc.isComplete,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Container(
            height: 44.0,
            margin: EdgeInsets.only(top: 24.0),
            width: MediaQuery.of(context).size.width / 2,
            child: RaisedButton(
              key: Key('examine'),
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Text(
                'Examine',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              onPressed: (snapshot.hasData) ? _examine : null,
            ),
          );
        },
      );
    }

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('BloodPressureBloc Page'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BloodPressureHistoryPage(bloc: bloc),
                    ));
              },
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          child: ListView(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  resultWidget(),
                  systolicInput(),
                  diastolicInput(),
                  examineButton(),
                ],
              ),
            ],
          ),
        ));
  }
}
