// import 'package:your_project/features/equipment/domain/equipment_filter_model.dart';

// class EquipmentFilter {
//   FilterModel? filterModel;

//   EquipmentFilter() {
//     filterModel = FilterModel();
//   }

//   void handleType([String? type]) {
//     filterModel = FilterModel(
//       type: type,
//       minWeight: filterModel?.minWeight,
//       maxWeight: filterModel?.maxWeight,
//     );
//   }

//   void handleWeight({double? minimum, double? maximum}) {
//     filterModel = FilterModel(
//       minWeight: minimum,
//       maxWeight: maximum,
//       type: filterModel?.type,
//     );
//   }

//   // Function to change filters
//   void updateFilter({FilterModel? model}) {
//     // Change some filters and keep the rest same
//     filterModel = model ?? filterModel;
//   }

//   void handleSearch(String value) {
//     // Search functionality can be implemented here
//   }
// }