import 'package:flutter/material.dart';

class SavedDimensions extends StatelessWidget {
  const SavedDimensions({Key? key, required this.lList, required this.wList, required this.hList}) : super(key: key);
  final List<String> lList;
  final List<String> wList;
  final List<String> hList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Dimensions'),
        backgroundColor: Colors.green,
      ),
      body: lList.isEmpty
          ? Center(
              child: Text('No dimensions found!', style: TextStyle(fontSize: 18.0),),
            )
          : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15.0),
              Text(
                'Save Dimensions',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
              const SizedBox(height: 10.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: lList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
                    child: SizedBox(
                      height: 150.0,
                      child: Card(
                        elevation: 10.0,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                            children: [
                              Text(
                                'Length: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              Text(
                                '${lList[index]} cm',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Width: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              Text(
                                '${wList[index]} cm',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Height: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              Text(
                                '${hList[index]} cm',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }
}
