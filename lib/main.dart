import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'YOUR_APP_ID_HERE';
  final keyClientKey = 'YOUR_CLIENT_KEY_HERE';

  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    title: 'Flutter - GeoPoint',
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ParseObject> results = <ParseObject>[];
  double selectedDistance = 3000;

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void doQueryNear() async {
    // Create your query
    final QueryBuilder<ParseObject> parseQuery =
    QueryBuilder<ParseObject>(ParseObject('City'));

    // Get current position from device
    final position = await getCurrentPosition();

    final currentGeoPoint = ParseGeoPoint(
        latitude: position.latitude, longitude: position.longitude);

    // `whereNear` will order results based on distance between the GeoPoint
    // type field from the class and the GeoPoint argument
    parseQuery.whereNear('location', currentGeoPoint);

    // The query will resolve only after calling this method, retrieving
    // an array of `ParseObjects`, if success
    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      // Let's show the results
      for (var o in apiResponse.results! as List<ParseObject>) {
        print(
            'City: ${o.get<String>('name')} - Location: ${o.get<ParseGeoPoint>('location')!.latitude}, ${o.get<ParseGeoPoint>('location')!.longitude}');
      }

      setState(() {
        results = apiResponse.results as List<ParseObject>;
      });
    } else {
      setState(() {
        results.clear();
      });
    }
  }

  void doQueryInKilometers() async {
    // Create your query
    final QueryBuilder<ParseObject> parseQuery =
    QueryBuilder<ParseObject>(ParseObject('City'));

    // Get current position from device
    final position = await getCurrentPosition();

    final currentGeoPoint = ParseGeoPoint(
        latitude: position.latitude, longitude: position.longitude);

    // You can also use `whereWithinMiles` and `whereWithinRadians` the same way,
    // but with different measuring unities
    parseQuery.whereWithinKilometers(
        'location', currentGeoPoint, selectedDistance);

    // The query will resolve only after calling this method, retrieving
    // an array of `ParseObjects`, if success
    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      // Let's show the results
      for (var o in apiResponse.results! as List<ParseObject>) {
        print(
            'City: ${o.get<String>('name')} - Location: ${o.get<ParseGeoPoint>('location')!.latitude}, ${o.get<ParseGeoPoint>('location')!.longitude}');
      }

      setState(() {
        results = apiResponse.results as List<ParseObject>;
      });
    } else {
      setState(() {
        results.clear();
      });
    }
  }

  void doQueryInMiles() async {
    // Create your query
    final QueryBuilder<ParseObject> parseQuery =
    QueryBuilder<ParseObject>(ParseObject('City'));

    // Get current position from device
    final position = await getCurrentPosition();

    final currentGeoPoint = ParseGeoPoint(
        latitude: position.latitude, longitude: position.longitude);

    // You can also use `whereWithinKilometers` and `whereWithinRadians` the same way,
    parseQuery.whereWithinMiles('location', currentGeoPoint, selectedDistance);

    // The query will resolve only after calling this method, retrieving
    // an array of `ParseObjects`, if success
    final ParseResponse apiResponse = await parseQuery.query();

    if (apiResponse.success && apiResponse.results != null) {
      // Let's show the results
      for (var o in apiResponse.results! as List<ParseObject>) {
        print(
            'City: ${o.get<String>('name')} - Location: ${o.get<ParseGeoPoint>('location')!.latitude}, ${o.get<ParseGeoPoint>('location')!.longitude}');
      }

      setState(() {
        results = apiResponse.results as List<ParseObject>;
      });
    } else {
      setState(() {
        results.clear();
      });
    }
  }

  void doClearResults() async {
    setState(() {
      results = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                child: Image.network(
                    'https://blog.back4app.com/wp-content/uploads/2017/11/logo-b4a-1-768x175-1.png'),
              ),
              Center(
                child: const Text('Flutter on Back4app - GeoPoint',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 50,
                child: ElevatedButton(
                    onPressed: doQueryNear,
                    child: Text('Query Near'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue)),
              ),
              SizedBox(
                height: 16,
              ),
              Center(child: Text('Distance')),
              Slider(
                value: selectedDistance,
                min: 0,
                max: 10000,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    selectedDistance = value;
                  });
                },
                label: selectedDistance.toStringAsFixed(0),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 50,
                child: ElevatedButton(
                    onPressed: doQueryInKilometers,
                    child: Text('Query in Kilometers'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue)),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 50,
                child: ElevatedButton(
                    onPressed: doQueryInMiles,
                    child: Text('Query Miles'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue)),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 50,
                child: ElevatedButton(
                    onPressed: doClearResults,
                    child: Text('Clear results'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue)),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Result List: ${results.length}',
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final o = results[index];
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                        child: Text(
                            '${o.get<String>('name')} \nLocation: ${o.get<ParseGeoPoint>('location')!.latitude}, ${o.get<ParseGeoPoint>('location')!.longitude}'),
                      );
                    }),
              )
            ],
          ),
        ));
  }
}