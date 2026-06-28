class MockUser {
  const MockUser({
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.level = 1,
    this.isVerified = false,
  });

  final String name;
  final String username;
  final String avatarUrl;
  final int level;
  final bool isVerified;
}

class MockPlace {
  const MockPlace({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.district,
    required this.category,
    this.latitude = 10.7769,
    this.longitude = 106.7009,
  });

  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String distance;
  final String district;
  final String category;
  final double latitude;
  final double longitude;
}

class MockReview {
  const MockReview({
    required this.user,
    required this.placeName,
    required this.rating,
    required this.content,
    required this.imageUrls,
    required this.timeAgo,
    required this.likes,
    required this.comments,
  });

  final MockUser user;
  final String placeName;
  final double rating;
  final String content;
  final List<String> imageUrls;
  final String timeAgo;
  final int likes;
  final int comments;
}

class MockData {
  MockData._();

  static const currentUser = MockUser(
    name: 'Nguyễn Minh Anh',
    username: '@minhanh_foodie',
    avatarUrl: 'https://i.pravatar.cc/300?img=47',
    level: 12,
    isVerified: true,
  );

  static const trendingPlaces = [
    MockPlace(
      name: 'The Workshop Coffee',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      rating: 4.8,
      reviewCount: 324,
      distance: '0.8 km',
      district: 'Quận 1',
      category: 'Cà phê',
      latitude: 10.7720,
      longitude: 106.6983,
    ),
    MockPlace(
      name: 'Bánh Mì Huỳnh Hoa',
      imageUrl: 'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=400',
      rating: 4.9,
      reviewCount: 892,
      distance: '1.2 km',
      district: 'Quận 1',
      category: 'Ăn uống',
      latitude: 10.7690,
      longitude: 106.6910,
    ),
    MockPlace(
      name: 'Landmark 81',
      imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a3bc80845e1?w=400',
      rating: 4.7,
      reviewCount: 567,
      distance: '3.5 km',
      district: 'Bình Thạnh',
      category: 'Vui chơi',
      latitude: 10.7950,
      longitude: 106.7220,
    ),
    MockPlace(
      name: 'Pizza 4P\'s',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
      rating: 4.6,
      reviewCount: 445,
      distance: '2.1 km',
      district: 'Quận 2',
      category: 'Ăn uống',
      latitude: 10.8030,
      longitude: 106.7300,
    ),
    MockPlace(
      name: 'Chợ Bến Thành',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
      rating: 4.5,
      reviewCount: 1203,
      distance: '0.5 km',
      district: 'Quận 1',
      category: 'Mua sắm',
      latitude: 10.7725,
      longitude: 106.6980,
    ),
    MockPlace(
      name: 'Saigon Rooftop Bar',
      imageUrl: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=400',
      rating: 4.4,
      reviewCount: 278,
      distance: '1.8 km',
      district: 'Quận 1',
      category: 'Vui chơi',
      latitude: 10.7780,
      longitude: 106.7050,
    ),
  ];

  static final reviews = [
    MockReview(
      user: const MockUser(
        name: 'Trần Thảo Vy',
        username: '@thaovy_eats',
        avatarUrl: 'https://i.pravatar.cc/300?img=32',
        level: 8,
        isVerified: true,
      ),
      placeName: 'The Workshop Coffee',
      rating: 4.8,
      content:
          'Không gian cực chill, cà phê specialty ngon xuất sắc! Đặc biệt là ly cold brew với hương vị trái cây tự nhiên. View nhìn ra phố đi bộ Nguyễn Huệ rất đẹp, phù hợp làm việc hoặc hẹn hò cuối tuần ☕✨',
      imageUrls: [
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600',
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600',
        'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=600',
      ],
      timeAgo: '2 giờ trước',
      likes: 234,
      comments: 45,
    ),
    MockReview(
      user: const MockUser(
        name: 'Lê Hoàng Nam',
        username: '@namfoodie',
        avatarUrl: 'https://i.pravatar.cc/300?img=12',
        level: 15,
        isVerified: true,
      ),
      placeName: 'Bánh Mì Huỳnh Hoa',
      rating: 5.0,
      content:
          'Hàng đầu Sài Gòn không phải đùa! Bánh mì thịt nguội đầy ú ụ, pate thơm béo, đồ chua giòn tan. Xếp hàng 15 phút nhưng xứng đáng 100%. Ai đến Sài Gòn mà chưa ăn thì phí cả chuyến đi 🥖🔥',
      imageUrls: [
        'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=600',
        'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=600',
      ],
      timeAgo: '5 giờ trước',
      likes: 567,
      comments: 89,
    ),
    MockReview(
      user: const MockUser(
        name: 'Phạm Linh Chi',
        username: '@linhchi_travel',
        avatarUrl: 'https://i.pravatar.cc/300?img=5',
        level: 6,
      ),
      placeName: 'Landmark 81 Skydeck',
      rating: 4.7,
      content:
          'View toàn thành phố từ tầng 81 cực đẹp, nhất là lúc hoàng hôn! Giá vé hơi cao nhưng trải nghiệm đáng tiền. Nên đi vào buổi chiều để ngắm cả ban ngày lẫn đêm 🌆',
      imageUrls: [
        'https://images.unsplash.com/photo-1583417319070-4a3bc80845e1?w=600',
        'https://images.unsplash.com/photo-1514565131-ff177080c9d2e?w=600',
      ],
      timeAgo: '1 ngày trước',
      likes: 412,
      comments: 67,
    ),
  ];

  static const feedTabs = [
    'Dành cho bạn',
    'Đang theo dõi',
    'Gần bạn',
    'Mới nhất',
  ];

  static const mapCategories = [
    'Tất cả',
    'Ăn uống',
    'Cà phê',
    'Vui chơi',
    'Mua sắm',
  ];

  static const profileTabs = ['Bài viết', 'Đánh giá', 'Check-in', 'Nháp'];

  static const galleryImages = [
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
    'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=400',
    'https://images.unsplash.com/photo-1583417319070-4a3bc80845e1?w=400',
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
    'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=400',
    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
    'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
    'https://images.unsplash.com/photo-1565958011703-44f9824ba187?w=400',
    'https://images.unsplash.com/photo-1482049016688-a7be0e436279?w=400',
  ];
}
