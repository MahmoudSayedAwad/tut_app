import 'dart:async';
import 'dart:ffi';

import '../../../../../domain/model/models.dart';
import '../../../../../domain/usecase/home_usecase.dart';
import '../../../../base/base_view_model.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../common/state_renderer/state_render_impl.dart';
import '../../../../common/state_renderer/state_renderer.dart';

class HomeViewModel extends BaseViewModel
    with HomeViewModelInput, HomeViewModelOutput {
  final _dataStreamController = BehaviorSubject<HomeViewObject>();
  final HomeUseCase _homeUseCase;

  HomeViewModel(this._homeUseCase);

  @override
  void start() {
    _getHomeData();
  }

  @override
  void dispose() {
    _dataStreamController.close();
    super.dispose();
  }
  //inputs----------------------------------------------------------------------

  @override
  Sink get inputHomeData => _dataStreamController.sink;
  //outputs---------------------------------------------------------------------
  @override
  Stream<HomeViewObject> get outputHomeData =>
      _dataStreamController.stream.map((data) => data);

  _getHomeData() async {
    inputState.add(LoadingState(
        stateRendererType: StateRendererType.fullScreenLoadingState));
    (await _homeUseCase.execute(Void)).fold(
        (failure) => {
              // left -> failure
              inputState.add(ErrorState(
                  StateRendererType.fullScreenErrorState, failure.message))
            }, (homeObject) {
      // right -> data (success)
      // content
      inputState.add(ContentState());
      inputHomeData.add(HomeViewObject(homeObject.data.stores,
          homeObject.data.services, homeObject.data.banners));

      // navigate to main screen
    });
  }
}

abstract class HomeViewModelInput {
  Sink get inputHomeData;
}

abstract class HomeViewModelOutput {
  Stream<HomeViewObject> get outputHomeData;
}

class HomeViewObject {
  List<Store> stores;
  List<Service> services;
  List<BannerAd> banners;
  HomeViewObject(this.stores, this.services, this.banners);
}
