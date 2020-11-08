
class Book {

  String title;
  String subtitle;
  String isbn;
  String price;
  String image;
  String url;

  Book({this.title, this.subtitle, this.isbn, this.price, this.image, this.url});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title : json['title'] ,
      subtitle : json['subtitle'] ,
      isbn : json['isbn13'] ,
      price : json['price'] ,
      image : json['image'] ,
      url : json['url'] ,
    );
  }

  String getTitle() {
    return image;
  }
}