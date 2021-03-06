import 'package:flutter/material.dart';
import 'package:flutter_app/app/dao/home_dao.dart';
import 'package:flutter_app/app/global/Global.dart';
import 'package:flutter_app/app/model/banner_model.dart';
import 'package:flutter_app/app/model/common_model.dart';
import 'package:flutter_app/app/model/grid_nav_model.dart';
import 'package:flutter_app/app/model/home_model.dart';
import 'package:flutter_app/app/model/sales_box_model.dart';
import 'package:flutter_app/app/utils/statusbar_utils.dart';
import 'package:flutter_app/app/utils/toast_utils.dart';
import 'package:flutter_app/app/widget/grid_item.dart';
import 'package:flutter_app/app/widget/grid_nav.dart';
import 'package:flutter_app/app/widget/loading.dart';
import 'package:flutter_app/app/widget/sales_box.dart';
import 'package:flutter_app/app/widget/search_bar.dart';
import 'package:flutter_app/app/widget/sub_nav.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

const APPBAR_SCROLL_OFFSET = 200;
const SEARCH_BOX_HINT = '网红打卡地 景点 酒店 美食';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _appBarAlpha = 0;
  bool _fetchHomeDataSuccess = false;
  List<BannerModel> _bannerList = [];
  List<CommonModel> _localNavList = [];
  GridNavModel _gridNavModel;
  NavModel _hotel;
  NavModel _flight;
  NavModel _travel;
  List<CommonModel> _subNavList;
  SalesBoxModel _salesBoxModel;
  String _searchUrl;

  @override
  void initState() {
    super.initState();
    fetchHomeData();
  }

  void fetchHomeData() async {
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        _fetchHomeDataSuccess = true;
        _bannerList = model.bannerList;
        _localNavList = model.localNavList;
        _gridNavModel = model.gridNav;
        _hotel = _gridNavModel.hotel;
        _flight = _gridNavModel.flight;
        _travel = _gridNavModel.travel;
        _subNavList = model.subNavList;
        _salesBoxModel = model.salesBox;
        _searchUrl = model.config.searchUrl;
        Global.HOME_MODEL = model;
      });
    } catch (err) {
      ToastUtils.toast(context, err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      // MediaQuery.removePadding可以让布局向状态栏延伸
      body: _fetchHomeDataSuccess
          ? MediaQuery.removePadding(
              context: context,
              removeTop: true,
              // NotificationListener用于监听子列表滚动
              child: Stack(
                children: <Widget>[
                  NotificationListener(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification &&
                          // notification.depth == 0表示只监听ListView的第0个子Widget
                          notification.depth == 0) {
                        _onScroll(notification.metrics.pixels);
                      }
                      return true;
                    },
                    child: Stack(
                      children: <Widget>[
                        ListView(
                          children: <Widget>[
                            _swiper(),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 4),
                              child: GridNavItem(_localNavList),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                children: <Widget>[
                                  HomeGridItem(
                                    model: _hotel,
                                    topRadius: true,
                                  ),
                                  HomeGridItem(
                                    model: _flight,
                                  ),
                                  HomeGridItem(
                                    model: _travel,
                                    bottomRadius: true,
                                  ),
                                ],
                              ),
                            ),
                            SubNavList(
                              subNavList: _subNavList,
                            ),
                            SalesBox(_salesBoxModel),
                          ],
                        ),
                        _appBar(),
                      ],
                    ),
                  ),
                ],
              ))
          : LoadingWidget(),
    );
  }

  _swiper() {
    return Container(
      height: 160,
      child: Swiper(
        itemCount: _bannerList.length,
        itemBuilder: (context, index) {
          return Image.network(
            _bannerList[index].icon,
            fit: BoxFit.fill,
          );
        },
        pagination: SwiperPagination(),
        loop: true,
        duration: 300,
        autoplay: true,
      ),
    );
  }

  _appBar() {
    double statusBarHeight = StatusBarUtils.getStatusBarHeight(context);
    return Container(
      height: APP_BAR_HEIGHT + statusBarHeight,
      child: Column(
        children: <Widget>[
          Opacity(
            opacity: _appBarAlpha,
            child: Container(
              height: statusBarHeight,
              decoration: BoxDecoration(color: Color(int.parse('0xffEDEDED'))),
            ),
          ),
          SearchBar(
            hint: SEARCH_BOX_HINT,
            alpha: _appBarAlpha,
            height: APP_BAR_HEIGHT,
            searchUrl: _searchUrl,
          )
        ],
      ),
    );
  }

  _onScroll(offset) {
    double alpha = offset / APPBAR_SCROLL_OFFSET;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      _appBarAlpha = alpha;
      print(_appBarAlpha);
    });
  }
}
