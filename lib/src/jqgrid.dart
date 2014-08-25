part of jqgrid_wrapper;

class JQGridColumnType {
  static final NumberFormat FORMAT_FLOAT_2 = new NumberFormat("#,##0.00", "hr_HR");
  static final NumberFormat FORMAT_FLOAT_6 = new NumberFormat("#,##0.000000", "hr_HR");
  String gridFormatter = "string";
  static String _utfChars(String value) {
    return value
        .replaceAll("š", "sz")
        .replaceAll("ž", "zz")
        .replaceAll("đ", "dzzz")
        .replaceAll("ž", "zz")
        .replaceAll("č", "cy")
        .replaceAll("ć", "cz");
  }
  Function sortFunction = (Object value, Object other) {
    String a = value == null ? "" : _utfChars(value.toString().toLowerCase());
    String b = other == null ? "" : _utfChars(other.toString().toLowerCase());
    return a == b ? 0 : (a.toString().compareTo(b.toString())); 
  };
  /**
   * (Object value) {return value == null ? "" : "JUHU: " + value.toString();}
   */
  Function formatFunction = (Object value) {
    if (value == null) {
      return "";
    }
    return value.toString();
  };
  
  static final JQGridColumnType STRING = new JQGridColumnType();
  static final JQGridColumnType INT = new JQGridColumnType()
    ..gridFormatter = "integer"
    ..sortFunction = (Object value, Object other) {
      int a = value == null ? 0 : value as int;
      int b = other == null ? 0 : other as int;
      return a == b ? 0 : (a > b ? 1 : -1);  
    };
  static final JQGridColumnType DATE = new JQGridColumnType()
    ..gridFormatter = "date"
    ..sortFunction = (Object value, Object other) {
      int a = value == null ? 0 : (value as DateTime).millisecondsSinceEpoch;
      int b = other == null ? 0 : (other as DateTime).millisecondsSinceEpoch;
      return a == b ? 0 : (a > b ? 1 : -1);
    };
  static final JQGridColumnType FLOAT_2 = new JQGridColumnType()
    ..sortFunction = (Object value, Object other) {
      num a = value == null ? 0 : value as num;
      num b = other == null ? 0 : other as num;
      return a == b ? 0 : (a > b ? 1 : -1);  
    }
    ..formatFunction = (Object value) {
      if (value == null) {
        return "";
      }
      return FORMAT_FLOAT_2.format(value as num);
    };
  static final JQGridColumnType FLOAT_6 = new JQGridColumnType()
    ..sortFunction = (Object value, Object other) {
          num a = value == null ? 0 : value as num;
          num b = other == null ? 0 : other as num;
          return a == b ? 0 : (a > b ? 1 : -1);  
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
  Object _container;
  Object _pager;
  JsObject _grid;
  List<JQGridColumn> _columns = [];
  String _gridCaption = "";
  Function _onRowSelected = null;
  Function _onRowRightClick = null;
  String _sortOrder;
  bool _sortAsc = true;
  int _width = 640;
  int _height = 480;
  Map columnMappings = {};
  
  JQGrid(Object container) {
    _container = container;
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
  
  void set onRowRightClick(Function value) {
    _onRowRightClick = value;
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
  
  JQGridColumn addColumnItem(JQGridColumn column) {
    _columns.add(column);
        return column;
  }
  
  void render() {
    List columnNames = [];
    List columnDefinitions = [];
    int i = 0;
    _columns.forEach((JQGridColumn column){
      columnNames.add(column.caption);
      columnMappings[column.fieldName] = i.toString();
      Map columnDefinition = {
        "name" : columnMappings[column.fieldName],
        "width" : column.width,
        "hidden" : column.hidden,
        "key" : column.isKey,
        "resizable": column.resizable,
        "sortable": column.sortable,
        "align": column.align
      };
      i++;
      if (column.type.sortFunction != null) {
        columnDefinition["sortfunc"] = (a, b, direction) {
          return direction * column.type.sortFunction(a, b);
        };
      }
      if (column.type.formatFunction != null) {
        columnDefinition["formatter"] = (cellvalue, options, JsObject rowObject, operation) {
          return column.type.formatFunction(cellvalue);
        };
      }
      else {
        columnDefinition["formatter"] = column.type.gridFormatter;
      }
      columnDefinitions.add(columnDefinition);
    });
    if (_container is String) {
      _grid = context.callMethod(r"$", ['#' + _container]);
    }
    else {
      _grid = context.callMethod(r"$", [_container]);
    }
    _grid.callMethod("jqGrid", [new JsObject.jsify({
          "datatype" : "local",
          "autowidth": false,
          "height" : _height,
          "minWidth": 600,
          "width": _width, 
          "minHeight": 300,
          "loadui" : "disable",
          "colNames" : columnNames,
          "colModel" : columnDefinitions,
          "forceFit": true,
          "caption" : _gridCaption,
          "viewrecords" : true,
          "rowNum":100000,
//          "rowList": [50,100, 200, 500, 1000],
          //"pager" : context.callMethod(r"$", ['#grid-pager']),
          "altRows": true,
          "multiselect": true,
          "multiboxonly": true,
          "shrinkToFit": true,
          "grouping": true,
          "sortname": _sortOrder,
          "scrollrows": true,
          "sortorder": _sortAsc ? "asc" : "desc",
          "onSelectRow" : (rowid, isChecked, b) {
            if (_onRowSelected != null) {
              _onRowSelected(rowid, isChecked);
            }
          },
          "onRightClickRow": (rowid, iRow, iCol, e){
            if (_onRowRightClick != null) {
              e.callMethod("preventDefault", []);
              _onRowRightClick(rowid, iRow, iCol, e);
            }
          }
        })]);
    
    context["testGrid"] = _grid;
  }
  
  Object _mapItem(Map newData) {
    Map result = {};
    List keys = newData.keys.toList();
    columnMappings.forEach((key, value){
      result[value] = readProperty(newData, key);
    });
    return result;
  }
  
  Object _mapItems(List newData) {
      List result = [];
      newData.forEach((item) => result.add(_mapItem(item)));
      return result;
    }
  
  void setData(List newData) {
    _grid.callMethod("jqGrid", ['setGridParam', new JsObject.jsify({"datatype": 'local', "data": _mapItems(newData)})])
      .callMethod("trigger", ["reloadGrid"]);
  }
  void clearData() {
    _grid.callMethod("jqGrid", ['clearGridData', true])
          .callMethod("trigger", ["reloadGrid"]);
  }
  static Object readProperty(Object object, String property) {
      if (object == null) {
        return null;
      }
      if (property == null) {
        return object;
      }
      if (object is! Map) {
        throw "Object is not a Map!";
      }
      Map map = object as Map;
      var i = property.indexOf(".");
      if (i < 0) {
        return map[property];
      }
      var immediateProperty = property.substring(0, i);
      var immediateObject = map[immediateProperty];
      return readProperty(immediateObject, property.substring(i + 1));
    }
  
  void addItem(Object rowId, Map newData) {
    _grid.callMethod("jqGrid", ['addRowData', rowId, new JsObject.jsify(_mapItem(newData)), "last", null]);
  }
  void updateItem(Object rowId, Map newData) {
    _grid.callMethod("jqGrid", ['setRowData', rowId, new JsObject.jsify(_mapItem(newData)), null]);
  }
  
  void removeItem(Object rowId) {
    _grid.callMethod("jqGrid", ['delRowData', rowId]);
  }
  void clearSelection() {
    _grid.callMethod("jqGrid", ['resetSelection']);
  }
  void setSelection(List rowIds) {
    clearSelection();
    rowIds.forEach((rowId){
      _grid.callMethod("jqGrid", ['setSelection', rowId]);
    });
  }
  Object getSelectedRow() {
    return _grid.callMethod("jqGrid", ['getGridParam', "selrow"]);
  }
  void setWidth(int value) {
    _width = value;
    if (_grid != null) {
      _grid.callMethod("jqGrid", ['setGridWidth', _width, true]);
    }
  }
  
  void setHeight(int value) {
    _height = value;
    if (_grid != null) {
      _grid.callMethod("jqGrid", ['setGridHeight', _height, true]);
    }
    
  }
}
