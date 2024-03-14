import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verona_app/pages/error.dart';

import '../helpers/helpers.dart';
import '../models/MyResponse.dart';
import '../services/http_service.dart';
import '../widgets/custom_widgets.dart';
import 'noticia_view.dart';

class NoticiasPage extends StatelessWidget {
  const NoticiasPage({Key? key}) : super(key: key);
  static final routeName = 'NoticiasPage';
  @override
  Widget build(BuildContext context) {
    final _wixService = Provider.of<WixService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Noticias'),
        backgroundColor: Helper.brandColors[2],
      ),
      backgroundColor: Helper.brandColors[1],
      body: FutureBuilder(
          future: _wixService.obtenerPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Loading(
                mensaje: 'Cargando noticias...',
              );
            }
            if (snapshot.hasError) {
              return ErrorPage(
                errorMsg: snapshot.error.toString(),
              );
            } else {
              MyResponse response = snapshot.data as MyResponse;
              if (response.fallo) {
                return ErrorPage(
                  errorMsg: response.error,
                  page: false,
                );
              }
              // return Container(color: Colors.red,);
              return ListView.builder(
                  itemCount: response.data['posts'].length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return NoticiaCard(
                      post: response.data['posts'][index],
                      esPar: index % 2 == 0,
                    );
                  });
            }
          }),
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }
}

class NoticiaCard extends StatelessWidget {
  NoticiaCard({Key? key, required this.post, required this.esPar})
      : super(key: key);

  Map<String, dynamic> post;
  bool esPar;

  @override
  Widget build(BuildContext context) {
    print(this.post['title']);
    final widgets = [
      Hero(
          tag: post['coverMedia']['image'] == null ? '' : post['coverMedia']['image']['id'],
          child: Container(
            width: 150,
            height: 150,
            child: CachedNetworkImage(
              imageUrl: post['coverMedia']['image'] == null ? '' : post['coverMedia']['image']['url'],
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Helper.brandColors[4],
                alignment: Alignment.center,
                child: Image(image: AssetImage('assets/image.png')),
              ),
            ),
          )),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                post['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Helper.brandColors[8]),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
                child: Divider(
                  color: Helper.brandColors[8],
                  thickness: 1,
                ),
              ),
              Text(
                post['excerpt'],
                maxLines: 3,
                style: TextStyle(color: Helper.brandColors[4]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      )
    ];
    return ZoomIn(
        child: GestureDetector(
      onTap: () => Navigator.pushNamed(context, NoticiaView.routeName,
          arguments: {"post": post}),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Helper.brandColors[2],
        child: Row(
          children: esPar ? widgets : widgets.reversed.toList(),
        ),
      ),
    ));
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class WixService extends ChangeNotifier {
  HttpService _http = new HttpService();
  final _endpoint = 'api/wix';

  Future<MyResponse> obtenerPosts() async {
    final datos = await this._http.get('$_endpoint');
    final resp = MyResponse.fromJson(datos);

    return resp;
  }
}
