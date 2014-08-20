import "dart:html";
import "package:jqgrid_wrapper/jqgrid_wrapper.dart";

void main() {
  JQGrid grid = new JQGrid(querySelector("#test-grid"))
    ..addColumn("ID", "oid", width: 30, isKey: true, hidden: true)
    ..addColumn("Item Index", "index", width: 40, columnType: JQGridColumnType.INT, align: "right")
    ..addColumn("Item Name", "name", width: 60)
    ..addColumn("Date", "date", width: 60, columnType: JQGridColumnType.DATE, align: "right")
    ..addColumn("Price", "price", width: 60, columnType: JQGridColumnType.FLOAT_2, align: "right")
    ..addColumn("Price", "price", width: 60, columnType: JQGridColumnType.FLOAT_6, align: "right")
    ..addColumn("Other Name", "name", width: 60, sortable: false, align: "center")
    ..gridCaption = "Test grid with data"
    ..setSort("name", false)
    ..onRowSelected = (String id, bool isChecked) {
      print("Selected: ${id} - ${isChecked}");
    };
  
  querySelector("#createGrid").onClick.listen((e){
    grid.render();
  });
  
  querySelector("#loadData").onClick.listen((e){
    List<Map> data = [];
    for (int i =0 ; i < 1000; i++) {
      Map item = {
        "oid": "i${i}",
        "index": i,
        "name": "Name ${i + 1}",
        "date": new DateTime.now().subtract(new Duration(days: i)),
        "price": 1000 * i
      };
      data.add(item);
    }
    grid.setData(data);
  });
  
  querySelector("#changeCaption").onClick.listen((e){
    grid.gridCaption = "Another grid caption";
  });
  querySelector("#widenGrid").onClick.listen((e){
     grid.setWidth(200);
   });
  
}