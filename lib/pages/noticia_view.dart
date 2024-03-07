
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../helpers/helpers.dart';
import '../services/wix_service.dart';
import '../widgets/custom_widgets.dart';

class NoticiaView extends StatelessWidget {
  const NoticiaView({Key? key}) : super(key: key);
  static final routeName = 'NoticiaView';
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final post = args['post'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Noticias'),
        backgroundColor: Helper.brandColors[2],
      ),
      body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
        child:Column(children: [
           Hero(
            tag: post['coverMedia']['image']['id'],
            child:Container(
          // width: 150,
          height: 300,
          child:  CachedNetworkImage(
              imageUrl: post['coverMedia']['image']['url'],
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                color: Helper.brandColors[8],
              )),
              errorWidget: (context, url, error) => Container(
                color: Helper.brandColors[8],
                alignment: Alignment.center,
                child: Image(image: AssetImage('assets/image.png')),
              ),
            ),
          )),
                    SizedBox(height: 15,),
          FadeInLeft(child: Text(post['title'] ?? '', style: TextStyle(fontSize: 20, color: Helper.brandColors[8], fontWeight: FontWeight.bold), textAlign: TextAlign.start,)),
          // SizedBox(height: 25,),
          Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                child: Divider(
                  color: Helper.brandColors[8],
                  thickness: 1,
                ),
              ),
          FadeInRight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Publicado el ${Helper.formatIsoDateString(post['firstPublishedDate'])}', style: TextStyle(fontSize: 10, color: Helper.brandColors[4], fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          FadeInRight(child: Text(post['contentText']?? '', style: TextStyle(fontSize: 15, color: Helper.brandColors[5], height: 1.5),)),
        ]
          )
        ,)
        ),
      backgroundColor: Helper.brandColors[1],
      bottomNavigationBar: CustomNavigatorFooter(),
    );
  }



}
