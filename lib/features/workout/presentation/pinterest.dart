import 'package:flutter/material.dart';

class PinterestFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            //pinterest logo
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/0/08/Pinterest-logo.png',
              height: 30,
            ),
            SizedBox(width: 8),
            const Text(
              "Pinterest",
              style: TextStyle(color: Colors.black),
            ),

            //spacer widget
            Spacer(),
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://th.bing.com/th?id=OIP.jryuUgIHWL-1FVD2ww8oWgHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2'),
              radius: 15,
            ),
          ],
        ),
      ),
      //column for images
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              padding: EdgeInsets.all(8),
              children: [
                _buildPinItem(
                    'Nintendo Switch',
                    'https://th.bing.com/th?id=OIP.Rd-SdOXMvOttn65NnG9H3wHaGr&w=263&h=237&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                    'https://th.bing.com/th?id=OIP.jryuUgIHWL-1FVD2ww8oWgHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2'),
                _buildPinItem(
                    'Awesome Gaming Setup',
                    'https://th.bing.com/th?id=OIP.SLBpmgn3qetXGyORRwq5mwHaFj&w=288&h=216&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                    'https://th.bing.com/th?id=OIP.jryuUgIHWL-1FVD2ww8oWgHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2'),
                _buildPinItem(
                    'Cozy Bedroom',
                    'https://th.bing.com/th?id=OIP.nZpi1VHatIOCBZpY381UWgHaJ4&w=216&h=288&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                    'https://th.bing.com/th?id=OIP.jryuUgIHWL-1FVD2ww8oWgHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2'),
                _buildPinItem(
                    'Green Sweater',
                    'https://th.bing.com/th/id/OIP.zP929QewwVOdrChAuBGtQgHaLH?w=139&h=208&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                    'https://th.bing.com/th?id=OIP.jryuUgIHWL-1FVD2ww8oWgHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2'),
                _buildPinItem(
                    'Style',
                    'https://th.bing.com/th/id/OIP.XudM4QKm2YrK5WOYlpJxjgHaHa?w=195&h=196&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                    'https://th.bing.com/th?id=OIP.jryuUgIHWL-1FVD2ww8oWgHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2'),
                _buildPinItem(
                    'Brown Bag',
                    'https://th.bing.com/th/id/OIP.QULQM_oLmi3-ZcK6aso7TwHaHK?w=204&h=197&c=7&r=0&o=5&dpr=1.3&pid=1.7',
                    'https://th.bing.com/th?id=OIP.jryuUgIHWL-1FVD2ww8oWgHaHa&w=250&h=250&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2'),
              ],
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

//method for feedimages
  Widget _buildPinItem(String title, String imageUrl, String profileImageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                  radius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//bottom navigation
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'For You', isSelected: true),
          _buildNavItem(Icons.search, 'Search'),
          _buildNavItem(Icons.notifications, 'Notifications'),
          _buildNavItem(Icons.person, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? Colors.red : Colors.grey),
        Text(label,
            style: TextStyle(
                color: isSelected ? Colors.red : Colors.grey, fontSize: 12)),
      ],
    );
  }
}
