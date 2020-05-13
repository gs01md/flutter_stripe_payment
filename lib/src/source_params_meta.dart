class SourceParamsMeta {

  String orderNo;

  SourceParamsMeta({ this.orderNo});

  factory SourceParamsMeta.fromJson(Map<dynamic, dynamic> json) {
    return SourceParamsMeta(
      orderNo: json['orderNo'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orderNo != null) data['orderNo'] = this.orderNo;

    return data;
  }
}