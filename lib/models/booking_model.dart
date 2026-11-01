class BookingModel {
  String? date;
  String? time;
  String? carType;
  String? registration;
  String? comment;
  double totalPrice;

  BookingModel({
    this.date,
    this.time,
    this.carType,
    this.registration,
    this.comment,
    this.totalPrice = 0.0,
  });
}