Scenario 1: User mở app lần đầu

1. NotificationService.initialize()
   → Xin permissions
   → Setup Firebase
   → Tạo notification channels

2. NoticeSettingsProvider._loadSettings()
   → Load saved preferences
   → Check subscription status
   → Update UI state

3. NewsNotificationScheduler.startPeriodicCheck()
   → Bắt đầu timer 2 giờ
   → Sẵn sàng kiểm tra tin mới

   Scenario 2: User thay đổi settings
User tap switch "Thể thao" → ON
         ↓
NoticeSettingsProvider.toggleCategorySubscription('sports', true)
         ↓
NotificationService.subscribeToCategoryNotifications('sports', true)
         ↓
Firebase.subscribeToTopic('news_sports')
         ↓
SharedPreferences.setBool('notification_sports', true)
         ↓
State updated → UI rebuilds → Switch shows ON

Scenario 3: Có tin mới
Timer 2 giờ trigger
         ↓
NewsNotificationScheduler._checkForNewArticles()
         ↓
Fetch articles từ API
         ↓
Filter articles trong 2 giờ qua
         ↓
For each new article:

- Check đã notify chưa?
- User có subscribe category này?
- Nếu YES → NotificationService.showLocalNotification()
         ↓
User thấy thông báo trên điện thoại
         ↓
User tap → App mở → Navigate đến article
