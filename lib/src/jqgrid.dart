part of jqgrid_wrapper;

class JQGridColumnType {
  static final NumberFormat FORMAT_FLOAT_2 = new NumberFormat("#,##0.00", "hr_HR");
  static final NumberFormat FORMAT_FLOAT_6 = new NumberFormat("#,##0.000000", "hr_HR");
  String gridFormatter = "string";
  Function sortFunction = (Object value) {
    return value;
  };
  /**
   * (Object value) {return value == null ? "" : "JUHU: " + value.toString();}
   */
  Function formatFunction = null;
  
  static final JQGridColumnType STRING = new JQGridColumnType();
  static final JQGridColumnType INT = new JQGridColumnType()
    ..gridFormatter = "integer"
    ..sortFunction = (Object value) {
      return value as int; 
    };
  static final JQGridColumnType DATE = new JQGridColumnType()
    ..gridFormatter = "date"
    ..sortFunction = (Object value) {
      return (value as DateTime).millisecondsSinceEpoch; 
    };
  static final JQGridColumnType FLOAT_2 = new JQGridColumnType()
    ..sortFunction = (Object value) {
       return (value as num); 
    }
    ..formatFunction = (Object value) {
      if (value == null) {
        return "";
      }
      return FORMAT_FLOAT_2.format(value as num);
    };
  static final JQGridColumnType FLOAT_6 = new JQGridColumnType()
    ..sortFunction = (Object value) {
       return (value as num); 
    }
    ..formatFunction = (Object value) {
      if (value == null) {
        return "";
      }
      return FORMAT_FLOAT_6.format(value as num);
    };
}

class JQGridColumn {
  String caption;
  String fieldName;
  String align = "left";
  int width = 40;
  bool isKey = false;
  bool resizable = true;
  bool hidden = false;
  bool sortable = true;
  JQGridColumnType type = JQGridColumnType.STRING;
}

class JQGrid {
  String _containerId;
  JsObject _grid;
  List<JQGridColumn> _columns = [];
  String _gridCaption = "";
  Function _onRowSelected = null;
  String _sortOrder;
  bool _sortAsc = true;
  
  JQGrid(String id) {
    _containerId = id;
  }
  
  void _setGridParam(String property, Object value) {
    if (_grid != null) {
      _grid.callMethod("jqGrid", ['setGridParam', new JsObject.jsify({property: value})])
        .callMethod("trigger", ["reloadGrid"]);
    }
  }
  void set onRowSelected(Function value) {
    _onRowSelected = value;
  }
  void setSort(String field, bool ascending) {
    _sortOrder = field;
    _sortAsc = ascending;
  }
  void set gridCaption(String value) {
    _gridCaption = value;
    if (_grid != null) {
      _grid.callMethod("jqGrid", ['setCaption', _gridCaption]);
    }
  }
  
  JQGridColumn addColumn(String caption, String fieldName, {
      int width: 40, 
      bool isKey: false, 
      bool resizable: true, 
      bool hidden: false, 
      bool sortable: true, 
      String align: "left",
      JQGridColumnType columnType: null}) 
  {
    JQGridColumn column = new JQGridColumn();
    column.caption = caption;
    column.fieldName = fieldName;
    column.width = width;
    column.isKey = isKey;
    column.resizable = resizable;
    column.hidden = hidden;
    column.sortable = sortable;
    column.align = align;
    column.type = columnType == null ? JQGridColumnType.STRING : columnType;
    _columns.add(column);
    return column;
  }
  
  void render() {
    List columnNames = [];
    List columnDefinitions = [];
    _columns.forEach((JQGridColumn column){
      columnNames.add(column.caption);
      Map columnDefinition = {
        "name" : column.fieldName,
        "width" : column.width,
        "hidden" : column.hidden,
        "key" : column.isKey,
        "resizable": column.resizable,
        "sortable": column.sortable,
        "align": column.align
      };
      if (column.type.sortFunction != null) {
        columnDefinition["sorttype"] = (cell, JsObject obj) {
          if (obj == null) {
            return null;
          }
          return column.type.sortFunction(obj[column.fieldName]);
        };
      }
      if (column.type.formatFunction != null) {
        columnDefinition["formatter"] = (cellvalue, options, rowObject, operation) {
          return column.type.formatFunction(cellvalue);
        };
      }
      else {
        columnDefinition["formatter"] = column.type.gridFormatter;
      }
      columnDefinitions.add(columnDefinition);
    });
    
    _grid = context.callMethod(r"$", ['#' + _containerId]);
    _grid.callMethod("jqGrid", [new JsObject.jsify({
          "datatype" : "local",
          "autowidth": true,
          "height" : 250,
          "minWidth": 600, 
          "minHeight": 300,
          "loadui" : "disable",
          "colNames" : columnNames,
          "colModel" : columnDefinitions,
          "forceFit": true,
          "caption" : _gridCaption,
          "viewrecords" : true,
          "rowNum":200,
          "rowList": [50,100, 200, 500, 1000],
          "pager" : context.callMethod(r"$", ['#grid-pager']),
          "altRows": true,
          "multiselect": true,
          "multiboxonly": true,
          "shrinkToFit": true,
          "grouping": true,
          "sortname": _sortOrder,
          "sortorder": _sortAsc ? "asc" : "desc",
          "onSelectRow" : (rowid, isChecked, b) {
            if (_onRowSelected != null) {
              _onRowSelected(rowid, isChecked);
            }
          }
        })]);
    
    context["testGrid"] = _grid;
  }
  
  void setData(List newData) {
    _grid.callMethod("jqGrid", ['setGridParam', new JsObject.jsify({"datatype": 'local', "data": newData})])
      .callMethod("trigger", ["reloadGrid"]);
  }
  
}
