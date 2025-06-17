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

## Problem

Khi lưu thêm ảnh trong rss có link ảnh vào trong firebase sẽ làm việc với thuộc tính này. Vấn đề là làm sao lấy được thẻ này từ RSS (Cách lấy từ HTML sẽ khác với cách lấy thông thường): <enclosure type="image/jpeg" length="1200" url="<https://i1-vnexpress.vnecdn.net/2025/06/13/55631871781372687471c-iran-174-3608-9354-1749777600.jpg?w=1200&h=0&q=100&dpr=1>
