import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '家教笔记',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// 启动画面
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2秒后跳转到主页面
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TeachMate 标题
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'TeachMate',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 4),
                      blurRadius: 8,
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 中文副标题
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                '教学助手',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 3),
                      blurRadius: 6,
                      color: Color.fromRGBO(0, 0, 0, 0.15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 主屏幕 - 包含底部导航
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const StudentsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '学员',
          ),
        ],
      ),
    );
  }
}

// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedWeekday = DateTime.now().weekday; // 1=周一, 7=周日
  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });
    final students = await DatabaseHelper.instance.getAllStudents();
    setState(() {
      _allStudents = students;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _todayCourses {
    return _allStudents.where((student) {
      return student['weekday'] == _selectedWeekday;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekdayStr = weekdayNames[now.weekday - 1];
    final dateStr = '${now.year}年${now.month}月${now.day}日 $weekdayStr';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部问候
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '老师，你好！',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // 星期导航栏
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final weekday = index + 1; // 1=周一, 7=周日
                  final isSelected = weekday == _selectedWeekday;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWeekday = weekday;
                      });
                    },
                    child: Container(
                      width: 56,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekdayNames[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // 今日课程标题
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '今日课程',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 课程列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _todayCourses.isEmpty
                      ? Center(
                          child: Text(
                            '今日暂无课程',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _todayCourses.length,
                          itemBuilder: (context, index) {
                            final student = _todayCourses[index];
                            final colors = [
                              Colors.green,
                              Colors.orange,
                              Colors.blue,
                              Colors.purple,
                              Colors.red,
                            ];
                            final color = colors[index % colors.length];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CourseCard(
                                studentName: student['name'],
                                time: student['time'] ?? '未设置时间',
                                status: '待上课',
                                statusColor: color,
                                onStudentTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentDetailPage(
                                        studentName: student['name'],
                                      ),
                                    ),
                                  );
                                },
                                onClassTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClassRecordPage(
                                        studentName: student['name'],
                                        studentId: student['id'],
                                      ),
                                    ),
                                  ).then((_) => _loadStudents()); // 返回后刷新数据
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// 课程卡片组件
class CourseCard extends StatelessWidget {
  final String studentName;
  final String time;
  final String status;
  final Color statusColor;
  final VoidCallback onStudentTap;
  final VoidCallback onClassTap;

  const CourseCard({
    super.key,
    required this.studentName,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.onStudentTap,
    required this.onClassTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 左侧图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: statusColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // 中间信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onStudentTap,
                    child: Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 右侧按钮
            ElevatedButton(
              onPressed: onClassTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text('上课'),
            ),
          ],
        ),
      ),
    );
  }
}

// 学员页面
class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = true;

  // 卡片颜色列表
  final List<Color> _cardColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.black,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });
    final students = await DatabaseHelper.instance.getAllStudents();
    setState(() {
      _allStudents = students;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredStudents {
    if (_searchQuery.isEmpty) {
      return _allStudents;
    }
    return _allStudents.where((student) {
      final name = student['name'].toString().toLowerCase();
      final course = student['course'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || course.contains(query);
    }).toList();
  }

  void _showAddStudentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStudentSheet(
        onStudentAdded: () {
          _loadStudents();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // 搜索框
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '搜索学员或课程...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            // 学员列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? '暂无学员\n点击右下角按钮添加学员'
                                : '没有找到匹配的学员',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            final color = _cardColors[index % _cardColors.length];
                            return StudentCard(
                              name: student['name'].toString(),
                              course: student['course'].toString(),
                              color: color,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentDetailPage(
                                      studentName: student['name'].toString(),
                                    ),
                                  ),
                                ).then((_) => _loadStudents());
                              },
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('删除学员'),
                                    content: const Text('确定要删除该学员吗？所有上课记录也将被删除。'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await DatabaseHelper.instance
                                              .deleteStudent(student['id']);
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            _loadStudents();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text('删除学员成功')),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          '删除',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      // 添加按钮
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentSheet,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

// 学员卡片组件
class StudentCard extends StatelessWidget {
  final String name;
  final String course;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const StudentCard({
    super.key,
    required this.name,
    required this.course,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 学生详情页面
class StudentDetailPage extends StatefulWidget {
  final String studentName;
  final int? studentId;

  const StudentDetailPage({
    super.key,
    required this.studentName,
    this.studentId,
  });

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  Map<String, dynamic>? _studentInfo;
  List<Map<String, dynamic>> _classRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // 加载学员信息
    final students = await DatabaseHelper.instance.getAllStudents();
    _studentInfo = students.firstWhere(
      (s) => s['name'] == widget.studentName,
      orElse: () => {},
    );

    // 加载上课记录
    if (_studentInfo != null && _studentInfo!['id'] != null) {
      _classRecords = await DatabaseHelper.instance
          .getStudentClassRecords(_studentInfo!['id']);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showEditStudentSheet() {
    if (_studentInfo == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditStudentSheet(
        studentInfo: _studentInfo!,
        onStudentUpdated: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 顶部返回按钮和编辑按钮
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _showEditStudentSheet,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 学员信息卡片
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _studentInfo?['name'] ?? widget.studentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _studentInfo?['course'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        if (_studentInfo?['phone'] != null &&
                            _studentInfo!['phone'].toString().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _studentInfo!['phone'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 上课记录列表
                  Expanded(
                    child: _classRecords.isEmpty
                        ? Center(
                            child: Text(
                              '暂无上课记录',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _classRecords.length,
                            itemBuilder: (context, index) {
                              final record = _classRecords[index];
                              return GestureDetector(
                                onTap: () {
                                  // 跳转到记录编辑页
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClassRecordPage(
                                        studentName: widget.studentName,
                                        studentId: _studentInfo?['id'],
                                        recordId: record['id'],
                                      ),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                onLongPress: () {
                                  // 长按删除
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('删除记录'),
                                      content: const Text('确定要删除这条上课记录吗？'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await DatabaseHelper.instance
                                                .deleteClassRecord(record['id']);
                                            if (mounted) {
                                              Navigator.pop(context);
                                              _loadData();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text('删除成功')),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            '删除',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.description_outlined,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '上课时间：${record['date']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              record['time'] ?? '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

// 上课记录页面
class ClassRecordPage extends StatefulWidget {
  final String studentName;
  final int? studentId;
  final int? recordId; // 如果是编辑已有记录，传入记录ID

  const ClassRecordPage({
    super.key,
    required this.studentName,
    this.studentId,
    this.recordId,
  });

  @override
  State<ClassRecordPage> createState() => _ClassRecordPageState();
}

class _ClassRecordPageState extends State<ClassRecordPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  int? _studentId;
  int? _studentWeekday; // 学员设置的上课星期
  String? _studentCourse; // 学员课程
  double _fontSize = 16.0; // 字体大小

  // 应用文本格式
  void _applyFormat(String prefix, String suffix) {
    final text = _textController.text;
    final selection = _textController.selection;
    
    if (selection.baseOffset == -1) {
      // 没有选中文本，在光标位置插入
      final newText = text.substring(0, selection.baseOffset) +
          prefix + suffix +
          text.substring(selection.baseOffset);
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.baseOffset + prefix.length,
        ),
      );
    } else {
      // 有选中文本
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.substring(0, selection.start) +
          prefix + selectedText + suffix +
          text.substring(selection.end);
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + prefix.length + selectedText.length + suffix.length,
        ),
      );
    }
  }

  // 显示字体大小选择对话框
  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择字体大小'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('小', style: TextStyle(fontSize: 14)),
              leading: Radio<double>(
                value: 14.0,
                groupValue: _fontSize,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('正常', style: TextStyle(fontSize: 16)),
              leading: Radio<double>(
                value: 16.0,
                groupValue: _fontSize,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('大', style: TextStyle(fontSize: 18)),
              leading: Radio<double>(
                value: 18.0,
                groupValue: _fontSize,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('特大', style: TextStyle(fontSize: 20)),
              leading: Radio<double>(
                value: 20.0,
                groupValue: _fontSize,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 加载学员信息
    if (widget.studentId != null) {
      _studentId = widget.studentId;
      // 加载学员的星期信息
      final students = await DatabaseHelper.instance.getAllStudents();
      final student = students.firstWhere(
        (s) => s['id'] == widget.studentId,
        orElse: () => {},
      );
      _studentWeekday = student['weekday'];
      _studentCourse = student['course'];
    } else {
      final students = await DatabaseHelper.instance.getAllStudents();
      final student = students.firstWhere(
        (s) => s['name'] == widget.studentName,
        orElse: () => {},
      );
      _studentId = student['id'];
      _studentWeekday = student['weekday'];
      _studentCourse = student['course'];
    }

    // 如果是编辑模式，加载已有记录
    if (widget.recordId != null) {
      final record = await DatabaseHelper.instance.getClassRecord(widget.recordId!);
      if (record != null && record['content'] != null) {
        _textController.text = record['content'];
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (_studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('学员信息错误')),
      );
      return;
    }

    final now = DateTime.now();
    
    // 计算正确的上课日期（根据学员设置的星期）
    DateTime classDate = now;
    if (_studentWeekday != null) {
      // 计算当前星期到目标星期的天数差
      int daysToAdd = _studentWeekday! - now.weekday;
      if (daysToAdd < 0) {
        daysToAdd += 7; // 如果目标星期已过，则计算下周
      }
      classDate = now.add(Duration(days: daysToAdd));
    }
    
    final dateStr = '${classDate.year}-${classDate.month.toString().padLeft(2, '0')}-${classDate.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    try {
      if (widget.recordId != null) {
        // 更新已有记录
        final record = {
          'student_id': _studentId,
          'date': dateStr,
          'time': timeStr,
          'content': _textController.text,
        };
        await DatabaseHelper.instance.updateClassRecord(widget.recordId!, record);
      } else {
        // 检查当天是否已有记录
        final existingRecords = await DatabaseHelper.instance.getStudentClassRecords(_studentId!);
        final todayRecord = existingRecords.where((r) => r['date'] == dateStr).toList();
        
        if (todayRecord.isNotEmpty) {
          // 当天已有记录，更新而不是新建
          final record = {
            'student_id': _studentId,
            'date': dateStr,
            'time': timeStr,
            'content': _textController.text,
          };
          await DatabaseHelper.instance.updateClassRecord(todayRecord.first['id'], record);
        } else {
          // 插入新记录
          final record = {
            'student_id': _studentId,
            'date': dateStr,
            'time': timeStr,
            'content': _textController.text,
          };
          await DatabaseHelper.instance.insertClassRecord(record);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功！')),
        );
        // 返回首页
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _saveRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text('保存'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 学生信息标题
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.studentName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _studentCourse ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 文本编辑区域
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '请输入上课记录...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                style: TextStyle(
                  fontSize: _fontSize,
                  height: 1.5,
                ),
              ),
            ),
          ),
          // 底部工具栏
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildToolbarButton(
                      icon: Icons.format_bold,
                      isActive: false,
                      onTap: () => _applyFormat('**', '**'),
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Icons.format_italic,
                      isActive: false,
                      onTap: () => _applyFormat('*', '*'),
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Icons.format_underline,
                      isActive: false,
                      onTap: () => _applyFormat('__', '__'),
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Icons.text_fields,
                      isActive: false,
                      onTap: _showFontSizeDialog,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? Colors.orange.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.orange : Colors.grey.shade700,
        ),
      ),
    );
  }
}

// 添加学员底部弹窗
class AddStudentSheet extends StatefulWidget {
  final VoidCallback onStudentAdded;

  const AddStudentSheet({super.key, required this.onStudentAdded});

  @override
  State<AddStudentSheet> createState() => _AddStudentSheetState();
}

class _AddStudentSheetState extends State<AddStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _phoneController = TextEditingController();
  int? _selectedWeekday;
  TimeOfDay? _selectedTime;

  final List<String> _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final student = {
        'name': _nameController.text,
        'course': _courseController.text,
        'phone': _phoneController.text,
        'weekday': _selectedWeekday,
        'time': _selectedTime != null
            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
            : null,
      };

      await DatabaseHelper.instance.insertStudent(student);
      widget.onStudentAdded();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加学员成功！')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '添加学员',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('学生姓名', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '请输入学生姓名',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入学生姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('课程', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _courseController,
                  decoration: InputDecoration(
                    hintText: '请输入课程名称',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入课程名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('联系电话', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '请输入联系电话',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('上课时间', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedWeekday,
                        decoration: InputDecoration(
                          hintText: '星期',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: List.generate(7, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(_weekdays[index]),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _selectedWeekday = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedTime != null
                                ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                : '时间',
                            style: TextStyle(
                              color: _selectedTime != null
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 数据库帮助类
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, filePath);

    return await openDatabase(
      fullPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 学员表
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        course TEXT NOT NULL,
        phone TEXT,
        weekday INTEGER,
        time TEXT
      )
    ''');
    
    // 上课记录表
    await db.execute('''
      CREATE TABLE class_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        content TEXT,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert('students', student);
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final db = await database;
    return await db.query('students', orderBy: 'id DESC');
  }

  Future<int> updateStudent(int id, Map<String, dynamic> student) async {
    final db = await database;
    return await db.update(
      'students',
      student,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== 上课记录相关方法 ==========
  
  Future<int> insertClassRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('class_records', record);
  }

  Future<List<Map<String, dynamic>>> getStudentClassRecords(int studentId) async {
    final db = await database;
    return await db.query(
      'class_records',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC, time DESC',
    );
  }

  Future<Map<String, dynamic>?> getClassRecord(int id) async {
    final db = await database;
    final results = await db.query(
      'class_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateClassRecord(int id, Map<String, dynamic> record) async {
    final db = await database;
    return await db.update(
      'class_records',
      record,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteClassRecord(int id) async {
    final db = await database;
    return await db.delete(
      'class_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}

// 编辑学员底部弹窗
class EditStudentSheet extends StatefulWidget {
  final Map<String, dynamic> studentInfo;
  final VoidCallback onStudentUpdated;

  const EditStudentSheet({
    super.key,
    required this.studentInfo,
    required this.onStudentUpdated,
  });

  @override
  State<EditStudentSheet> createState() => _EditStudentSheetState();
}

class _EditStudentSheetState extends State<EditStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _courseController;
  late TextEditingController _phoneController;
  int? _selectedWeekday;
  TimeOfDay? _selectedTime;

  final List<String> _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.studentInfo['name']);
    _courseController = TextEditingController(text: widget.studentInfo['course']);
    _phoneController = TextEditingController(text: widget.studentInfo['phone'] ?? '');
    _selectedWeekday = widget.studentInfo['weekday'];
    
    if (widget.studentInfo['time'] != null) {
      final timeParts = widget.studentInfo['time'].toString().split(':');
      if (timeParts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateStudent() async {
    if (_formKey.currentState!.validate()) {
      final student = {
        'name': _nameController.text,
        'course': _courseController.text,
        'phone': _phoneController.text,
        'weekday': _selectedWeekday,
        'time': _selectedTime != null
            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
            : null,
      };

      await DatabaseHelper.instance.updateStudent(widget.studentInfo['id'], student);
      widget.onStudentUpdated();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新学员成功！')),
        );
      }
    }
  }

  Future<void> _deleteStudent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除学员'),
        content: const Text('确定要删除该学员吗？所有上课记录也将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DatabaseHelper.instance.deleteStudent(widget.studentInfo['id']);
      if (mounted) {
        Navigator.pop(context); // 关闭底部弹窗
        Navigator.pop(context); // 返回上一页
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除学员成功！')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '编辑学员',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: _deleteStudent,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('学生姓名', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '请输入学生姓名',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入学生姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('课程', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _courseController,
                  decoration: InputDecoration(
                    hintText: '请输入课程名称',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入课程名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('联系电话', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '请输入联系电话',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('上课时间', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedWeekday,
                        decoration: InputDecoration(
                          hintText: '星期',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: List.generate(7, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(_weekdays[index]),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _selectedWeekday = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedTime != null
                                ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                : '时间',
                            style: TextStyle(
                              color: _selectedTime != null
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
