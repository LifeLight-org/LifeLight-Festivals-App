import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      buildBackground(),
      buildScaffold(context),
    ]);
  }

  Container buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Removes shadow
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Add your onPressed code here
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "SEE YOU NEXT YEAR!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                Image.asset("assets/images/HA-Logo-B.png",
                    height: 120), // Adjust the height as needed
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: AutoSizeText(
                    'BRINGING LIGHT INTO DARKNESS',
                    style: TextStyle(
                      fontFamily: 'HelveticaNeueLT',
                      fontSize: 20,
                      letterSpacing: -2.0,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 0.5
                        ..color = Colors.white,
                      shadows: const [
                        Shadow(
                          offset: Offset(0.5, 0.5),
                          color: Colors.black,
                        ),
                      ],
                    ),
                    minFontSize: 10, // Minimum text size
                    stepGranularity: 1, // The step size for scaling the font
                    maxLines: 1, // Ensures the text does not wrap
                    overflow: TextOverflow
                        .ellipsis, // Adds an ellipsis if the text still overflows
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 8.0), // Adjust padding to avoid overlap
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width -
                        15, // Set the container's width
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your onPressed code here
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity,
                            60), // Use double.infinity for width inside the button
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Space between items
                        children: [
                          Text('Button 1'), // Text aligned to the left
                          Icon(
                              Icons.arrow_forward), // Icon aligned to the right
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: MediaQuery.of(context).size.width -
                        15, // Set the container's width
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your onPressed code here
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity,
                            60), // Use double.infinity for width inside the button
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Space between items
                        children: [
                          Text('Button 2'), // Text aligned to the left
                          Icon(
                              Icons.arrow_forward), // Icon aligned to the right
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: MediaQuery.of(context).size.width -
                        15, // Set the container's width
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your onPressed code here
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity,
                            60), // Use double.infinity for width inside the button
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Space between items
                        children: [
                          Text('Button 2'), // Text aligned to the left
                          Icon(
                              Icons.arrow_forward), // Icon aligned to the right
                        ],
                      ),
                    ),
                  ),
                                    SizedBox(height: 15),
                  Container(
                    width: MediaQuery.of(context).size.width -
                        15, // Set the container's width
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your onPressed code here
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity,
                            60), // Use double.infinity for width inside the button
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Space between items
                        children: [
                          Text('Button 2'), // Text aligned to the left
                          Icon(
                              Icons.arrow_forward), // Icon aligned to the right
                        ],
                      ),
                    ),
                  ),
                                    SizedBox(height: 15),
                  Container(
                    width: MediaQuery.of(context).size.width -
                        15, // Set the container's width
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your onPressed code here
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity,
                            60), // Use double.infinity for width inside the button
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Space between items
                        children: [
                          Text('Button 2'), // Text aligned to the left
                          Icon(
                              Icons.arrow_forward), // Icon aligned to the right
                        ],
                      ),
                    ),
                  ),
                                    SizedBox(height: 15),
                  Container(
                    width: MediaQuery.of(context).size.width -
                        15, // Set the container's width
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your onPressed code here
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity,
                            60), // Use double.infinity for width inside the button
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Space between items
                        children: [
                          Text('Button 2'), // Text aligned to the left
                          Icon(
                              Icons.arrow_forward), // Icon aligned to the right
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
