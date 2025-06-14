# Assignment 3: Mobile application Safe News

## Overview: Riverpod

Riverpod là thư viện quản lý state trong Flutter, cung cấp các loại provider để chia sẻ và quản lý dữ liệu. Dưới đây là ví dụ minh họa từng loại provider và chức năng liên quan.

---

### 1. **Provider**

- **Mục đích**: Cung cấp giá trị cố định hoặc đối tượng không thay đổi (như service/repository).
- **Ví dụ**:

  ```dart
  final apiServiceProvider = Provider((ref) => ApiService());
  class ApiService {
    String getBaseUrl() => "https://api.example.com";
  }
  ```

- **Cách dùng**:

  ```dart
  class MyWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final apiService = ref.watch(apiServiceProvider);
      return Text(apiService.getBaseUrl()); // Hiển thị: https://api.example.com
    }
  }
  ```

- **Chức năng**: Không có state, chỉ cung cấp giá trị. Dùng cho service, config, hoặc repository.

---

### 2. **ChangeNotifierProvider**

- **Mục đích**: Quản lý state và thông báo thay đổi qua `notifyListeners()`.
- **Ví dụ**:

  ```dart
  class CounterViewModel extends ChangeNotifier {
    int _count = 0;
    int get count => _count;
    void increment() {
      _count++;
      notifyListeners();
    }
  }

  final counterProvider = ChangeNotifierProvider((ref) => CounterViewModel());
  ```

- **Cách dùng**:

  ```dart
  class CounterWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final counter = ref.watch(counterProvider);
      return Column(
        children: [
          Text('Count: ${counter.count}'),
          ElevatedButton(
            onPressed: () => ref.read(counterProvider).increment(),
            child: Text('Increment'),
          ),
        ],
      );
    }
  }
  ```

- **Chức năng**: Quản lý state (như đếm số), rebuild UI khi state thay đổi. Phù hợp cho ViewModel.

---

### 3. **StateProvider**

- **Mục đích**: Quản lý state đơn giản (như int, String, bool).
- **Ví dụ**:

  ```dart
  final themeProvider = StateProvider<bool>((ref) => false); // false: light, true: dark
  ```

- **Cách dùng**:

  ```dart
  class ThemeWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final isDark = ref.watch(themeProvider);
      return Switch(
        value: isDark,
        onChanged: (value) => ref.read(themeProvider.notifier).state = value,
      );
    }
  }
  ```

- **Chức năng**: Thay thế `ChangeNotifierProvider` cho state đơn giản, dễ dùng, ít code.

---

### 4. **FutureProvider**

- **Mục đích**: Cung cấp dữ liệu async (như API call), chỉ fetch một lần.
- **Ví dụ**:

  ```dart
  final userProvider = FutureProvider<User>((ref) async {
    final response = await http.get(Uri.parse('https://api.example.com/user'));
    return User.fromJson(jsonDecode(response.body));
  });

  class User {
    final String name;
    User({required this.name});
    factory User.fromJson(Map<String, dynamic> json) => User(name: json['name']);
  }
  ```

- **Cách dùng**:

  ```dart
  class UserWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final user = ref.watch(userProvider);
      return user.when(
        data: (user) => Text('Name: ${user.name}'),
        loading: () => CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      );
    }
  }
  ```

- **Chức năng**: Quản lý dữ liệu async, cache kết quả, phù hợp cho dữ liệu tĩnh.

---

### 5. **StreamProvider**

- **Mục đích**: Cung cấp stream dữ liệu, cập nhật realtime (như Firestore).
- **Ví dụ**:

  ```dart
  final articlesProvider = StreamProvider<List<String>>((ref) {
    return FirebaseFirestore.instance
        .collection('positive_news')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['title'] as String).toList());
  });
  ```

- **Cách dùng**:

  ```dart
  class ArticlesWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final articles = ref.watch(articlesProvider);
      return articles.when(
        data: (articles) => ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) => ListTile(title: Text(articles[index])),
        ),
        loading: () => CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      );
    }
  }
  ```

- **Chức năng**: Cập nhật UI khi dữ liệu thay đổi, phù hợp cho Firestore hoặc WebSocket.

---

### 6. **Chức năng liên quan khác**

- **ref.watch**: Lắng nghe provider, rebuild UI khi giá trị thay đổi.

  ```dart
  final value = ref.watch(myProvider); // UI rebuild khi myProvider đổi
  ```

- **ref.read**: Đọc giá trị provider một lần, không lắng nghe.

  ```dart
  ref.read(myProvider).doSomething(); // Gọi hàm, không rebuild
  ```

- **ConsumerWidget**: Widget dùng để watch/read provider.

  ```dart
  class MyWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {...}
  }
  ```

- **ProviderScope**: Bao bọc app để sử dụng Riverpod.

  ```dart
  void main() {
    runApp(ProviderScope(child: MyApp()));
  }
  ```

- **autoDispose**: Tự động hủy provider khi không còn dùng, tiết kiệm tài nguyên.

  ```dart
  final tempProvider = Provider.autoDispose((ref) => 'Temporary');
  ```

- **family**: Tạo provider với tham số động.

  ```dart
  final userProvider = FutureProvider.family<User, String>((ref, userId) async {
    return fetchUser(userId);
  });
  // Dùng: ref.watch(userProvider('123'));
  ```

## Dummy data

 SizedBox(height: 8),
                      Text(
                        'Từ quê Lai Châu đi học nghề rồi không xin được việc, Trung Đức vừa bán hàng vừa học tiếng Trung, bôn ba chục năm trời trước khi tốt nghiệp xuất sắc thạc sĩ Đại học Ngôn ngữ Bắc Kinh.\nTrần Trung Đức, 32 tuổi, tốt nghiệp thạc sĩ ngành Giáo dục Hán ngữ quốc tế, Đại học Ngôn ngữ Bắc Kinh, hồi tháng 7/2024, với điểm trung bình học tập (GPA) 3.94/4 - top 4% sinh viên xuất sắc của trường. Ngôi trường này là cơ sở đào tạo Hán ngữ và văn hóa Trung Quốc lâu đời và quy mô nhất.\n"Tôi chưa từng nghĩ đến được ngày hôm nay", anh Đức, hiện là giáo viên tiếng Trung online, nói. "9 năm trước, tôi vẫn loay hoay tìm hướng đi".\nNăm 2011, sau khi tốt nghiệp THPT, Đức xuống Hà Nội học sửa chữa điện thoại vì thấy nghề này đang "thịnh", dễ kiếm tiền. Nhưng học xong không xin được việc, anh đăng ký Cao đẳng Y tế Phú Thọ, ngành Y đa khoa, theo định hướng của mẹ.\nTốt nghiệp với tấm bằng giỏi, Đức vẫn thất nghiệp nên về quê, xin làm nhân viên siêu thị ở cửa khẩu Ma Lù Thàng. Tại đây, anh học tiếng Trung vì tiếp xúc hàng ngày với khách Trung Quốc.\nMuốn có cơ hội xin học bổng du học nên năm 2016, Đức quyết định sang trường Cao cấp nghề Hà Khẩu ở Trung Quốc học một năm tiếng. Anh học bằng cách chép bài khóa vào vở, sau đó nghe audio từng câu rồi dừng lại để đọc, nói theo, viết ra và đối chiếu bản gốc. Cứ như vậy, Đức viết tới không còn lỗi mới thôi.\n"Cách này luyện được cả 4 kỹ năng", anh Đức nhớ lại. Là người gốc Hoa, anh Đức nhìn nhận có lợi thế hơn so với các bạn ở khả năng nghe, nói.\nKhi đã đọc hiểu tốt hơn, anh luyện đề HSK (chứng chỉ năng lực tiếng Trung), đọc các tác phẩm văn học và nhiều tài liệu bên ngoài để nâng cao kiến thức. Nhờ chăm chỉ, ngoài đạt kết quả học tập xuất sắc, anh Đức còn giành giải nhất cuộc thi khẩu ngữ của trường.\nTham gia các diễn đàn, hội nhóm học tiếng Trung, anh Đức nhận thấy nhiều người gặp khó ở phát âm. Đó là lý do anh nộp đơn xin học bổng miễn học phí của Đại học Sư phạm Vân Nam, theo đuổi ngành Giáo dục Hán ngữ Quốc tế. Ở tuổi 26, anh bắt đầu học đại học và được học thẳng lên năm thứ hai vì đạt điểm tốt bài kiểm tra vượt cấp.\nNăm 2021, anh lọt top 27 cuộc thi diễn thuyết COP 15 về bảo vệ tính đa dạng sinh học toàn cầu tổ chức ở Côn Minh. Ngoài ra, anh cũng đạt giải nhất toàn tỉnh Vân Nam và giải khuyến khích toàn quốc khối du học sinh về ngâm thơ.\nTốt nghiệp với GPA 3.99/4, anh Đức tiếp tục giành học bổng để học thạc sĩ tại Đại học Ngôn ngữ Bắc Kinh. Đề tài luận văn thạc sĩ của anh tập trung tìm hiểu các lỗi phát âm cơ bản của người Việt và cách chỉnh sửa.\nTheo anh Đức, các âm /p/, / h/, /z, c/, /j, q, x/, /zh, ch, sh, r/ trong tiếng Trung không có âm tương tự trong tiếng Việt. Nên khi phát âm, người nói thường lấy âm gần giống nhất trong hệ ngữ âm của mình để phát âm, dẫn đến sai.\n"Cách chỉnh là dựa trên những điểm tương đồng hoặc tiệm cận giữa hai hệ ngữ âm", anh giải thích.',
                        style: TextStyle(
                          color: const Color(0xFF231F20),
                          fontSize: 16,
                          fontFamily: 'Merriweather',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
        SizedBox(height: 8),
                      Text(
                        'Anh Đức dành một góc trong nhà để trưng bày giấy khen, giấy chứng nhận từ các cuộc thi. Ảnh: Nhân vật cung cấp',
                        style: TextStyle(
                          color: const Color(0xFF6D6265),
                          fontSize: 14,
                          fontFamily: 'Merriweather',
                          fontWeight: FontWeight.w400,
                        ),
                      ),