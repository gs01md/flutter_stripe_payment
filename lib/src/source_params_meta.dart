class SourceParamsMeta {

  String orderNo;
  String sourceId;
  String clientSecret;

  SourceParamsMeta({ this.orderNo = "", this.sourceId = "", this.clientSecret = ""});

  factory SourceParamsMeta.fromJson(Map<dynamic, dynamic> json) {
    return SourceParamsMeta(
      orderNo: json['orderNo'],
      sourceId: json['sourceId'],
      clientSecret: json['clientSecret'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orderNo != null) data['orderNo'] = this.orderNo;
    if (this.sourceId != null) data['sourceId'] = this.sourceId;
    if (this.clientSecret != null) data['clientSecret'] = this.clientSecret;

    return data;
  }
}