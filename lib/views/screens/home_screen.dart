import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app_flutter_riverpod/providers/headline_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/Headlines.dart';
import '../../model/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {


  // var headlineController = Get.put(HeadLinesController());
  // var categoryController = Get.put(CategoryController());

  final listCategories = [
    Categorys('assets/images/news_logo.jpg','General'),
    Categorys('assets/images/business.jpg','Business'),
    Categorys('assets/images/entertainment.jpg','Entertainment'),
    Categorys('assets/images/health.jpg','Health'),
    Categorys('assets/images/science.jpg','Science'),
    Categorys('assets/images/sports.jpg','Sports'),
    Categorys('assets/images/technology.png','Technology'),
  ];


  Map<String, dynamic> countries ={
    "US": "United States",
    "CA": "Canada",
    "GB": "United Kingdom",
    "DE": "Germany",
    "FR": "France",
    "JP": "Japan",
    "IN": "India",
    "BD": "Bangladesh",
    "BR": "Brazil",
    "CN": "China",
    "AU": "Australia",
    "IT": "Italy",
    // Add more country code and name pairs as needed

  };

  String country = "us";




  @override
  Widget build(BuildContext context) {

    final List<DropdownMenuItem> countryMenuItemList = countries.entries
        .map((entry) => DropdownMenuItem(
        value: entry.key.toString(),
        child: Text(entry.value.toString())
    ),
    ).toList();


    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.menu,
                    color: Colors.black54,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('assets/images/news_logo.jpg'),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    return DropdownButtonFormField(
                      decoration: InputDecoration(
                          hintText: "Country",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      items: countryMenuItemList,
                      onChanged: (value) {
                        country = value.toLowerCase();
                        ref.read(countryProvider.notifier).state = value.toLowerCase();
                      },
                    );
                  }
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                  height: 75,
                   child: Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      return ListView.builder(
                          itemCount: listCategories.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: false,
                          itemBuilder: (context, index) {
                            Categorys category = listCategories[index];
                            return Padding(
                              padding: EdgeInsets.only(left: 16,
                                  right: index == listCategories.length - 1
                                      ? 16
                                      : 0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(categoryProvider.notifier).state = listCategories[index].title.toLowerCase();
                                    },
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black12,
                                          border: Border.all(
                                              color: Colors.black12,
                                              width: 1
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(category.image),
                                          )
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    category.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                      );

                    }
                   ),

                ),
              const SizedBox(
                height: 12,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Top Headlines',
                  style: TextStyle(fontSize: 18,color: Colors.black54)
                  ,
                ),
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {

                  final headlinesdata = ref.watch(topHeadlinesNewsProvider);

                  return headlinesdata.when(
                      data: (data){
                        return Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            // physics: const BouncingScrollPhysics(),
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context,index){
                              Article article = data[index];
                              if (index == 0) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                      child: CachedNetworkImage(
                                        imageUrl: (article.urlToImage == null)
                                            ? 'https://img.freepik.com/premium-vector/no-photo-available-vector-icon-default-image-symbol-picture-coming-soon-web-site-mobile-app_87543-14040.jp'
                                            : article.urlToImage!,
                                        height: 190,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              decoration: const BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/images/no_news_found.jpg'),
                                                  )
                                              ),
                                            ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (!await launchUrl(Uri.parse(article.url))) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text(
                                                  'Could now launch news url.'))
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        height: 190,
                                        decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(8)),
                                            gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.black.withOpacity(0.8),
                                                  Colors.black.withOpacity(0.0),
                                                ],
                                                stops: const [
                                                  0.0,
                                                  0.7,
                                                ]
                                            )
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 12,
                                              top: 12,
                                              right: 12,
                                            ),
                                            child: Text(
                                              article.title,
                                              style: const TextStyle(
                                                  color: Colors.white
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 12,
                                              top: 4,
                                              right: 12,
                                            ),
                                            child: Wrap(
                                                crossAxisAlignment: WrapCrossAlignment
                                                    .center,
                                                children: [
                                                  Icon(
                                                    Icons.launch,
                                                    color: Colors.white.withOpacity(
                                                        0.8),
                                                    size: 12,
                                                  ),
                                                  SizedBox(width: 4,),
                                                  Text(
                                                    "${article.source.name}",
                                                    style: TextStyle(
                                                        color: Colors.white.withOpacity(
                                                            0.8),
                                                        fontSize: 12
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ]
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return InkWell(
                                  onTap: () async {
                                    if (!await launchUrl(Uri.parse(article.url))) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text(
                                              'Could now launch news url.'))
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    height: 100,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(6)),
                                            child: CachedNetworkImage(
                                              imageUrl: (article.urlToImage == null)
                                                  ? 'https://img.freepik.com/premium-vector/no-photo-available-vector-icon-default-image-symbol-picture-coming-soon-web-site-mobile-app_87543-14040.jpg'
                                                  : article.urlToImage!,
                                              height: 85,
                                              width: 85,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url, error) =>
                                                  Container(
                                                    width: 85,
                                                    height: 85,
                                                    decoration: const BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                              'assets/images/no_news_found.jpg'),
                                                        )
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            child: SizedBox(
                                              height: 90,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    article.title,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .start,
                                                    children: [
                                                      const Icon(
                                                        Icons.launch,
                                                        color: Colors.black54,
                                                        size: 12,
                                                      ),
                                                      const SizedBox(width: 4,),
                                                      Expanded(
                                                        child: Text(
                                                          article.source.name,
                                                          style: const TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: 12
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          softWrap: false,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                      error: ((error,stacktrace){
                        return Center(
                          child: Text(error.toString()),
                        );
                      }) ,
                      loading: ((){
                        return  Center(
                          child: CircularProgressIndicator(),
                        );
                      })
                  );

                },
              ),

            ],
          ),
        ),
      ),

    );
  }
}
