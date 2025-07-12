import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String code;
  final String name;
  final int credits;
  final String category;
  final String description;
  final List<String> tags;
  final String courseType;
  final String academicCategory;
  final List<int> semester;

  Course({
    required this.code,
    required this.name,
    required this.credits,
    this.category = 'General',
    this.description = '',
    this.tags = const [],
    this.courseType = 'Core Course',
    this.academicCategory = 'General',
    required this.semester,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'credits': credits,
      'category': category,
      'description': description,
      'tags': tags,
      'courseType': courseType,
      'academicCategory': academicCategory,
      'semester': semester,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      credits: map['credits'] ?? 0,
      category: map['category'] ?? 'General',
      description: map['description'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      courseType: map['courseType'] ?? 'Core Course',
      academicCategory: map['academicCategory'] ?? 'General',
      semester: List<int>.from(map['semester'] ?? []),
    );
  }
}


class CourseDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _coursesCollection = 'courses';

  // Initialize the database with courses from the study scheme
  Future<void> initializeCoursesDatabase() async {
    final QuerySnapshot snapshot = await _firestore.collection(_coursesCollection).get();

    // Only initialize if collection is empty
    if (snapshot.docs.isEmpty) {
      await _addCoreCourses();
      await _addElectiveCourses();
    }
  }

  // Add core courses from study scheme
  // Add core courses from study scheme
  Future<void> _addCoreCourses() async {
    final List<Course> coreCourses = [
      // 1st Semester
      Course(code: 'EN-101', name: 'Functional English', credits: 3, courseType: 'Core Course', academicCategory: 'Compulsory', semester:[1]),
      Course(code: 'PS-101', name: 'Introduction to Pakistan Studies', credits: 2, courseType: 'Core Course', academicCategory: 'Compulsory', semester:[1]),
      Course(code: 'CS-101', name: 'Introduction to Computing', credits: 3, courseType: 'Core Course', academicCategory: 'Compulsory', semester:[1]),
      Course(code: 'MA-101', name: 'Calculus and Analytical Geometry-I', credits: 3, courseType: 'Core Course', academicCategory: 'Compulsory', semester:[1]),
      Course(code: 'PH-101', name: 'Introductory Mechanics and Waves', credits: 2, courseType: 'Core Course', academicCategory: 'Faculty Elective', semester:[1]),
      Course(code: 'PH-191', name: 'Introductory Mechanics and Waves Lab', credits: 1, courseType: 'Core Course', academicCategory: 'Faculty Elective', semester:[1]),

      // 2nd Semester
      Course(code: 'EN-102', name: 'Functional English-II', credits: 3, courseType: 'Core Course', academicCategory: 'Compulsory', semester:[2]),
      Course(code: 'IS-101', name: 'Islamic Studies', credits: 2, courseType: 'Core Course', academicCategory: 'Compulsory', semester:[2]),
      Course(code: 'MA-102', name: 'Calculus and Analytical Geometry-II', credits: 3, courseType: 'Core Course', academicCategory: 'Compulsory', semester:[2]),
      Course(code: 'PY-101', name: 'Introduction to Psychology', credits: 3, courseType: 'Core Course', academicCategory: 'Compulsory', semester:[2]),
      Course(code: 'PH-103', name: 'Electricity, Magnetism and Thermal Physics', credits: 2, courseType: 'Core Course', academicCategory: 'Faculty Elective', semester:[2]),
      Course(code: 'PH-193', name: 'Electricity, Magnetism and Thermal Physics Lab', credits: 1, courseType: 'Core Course', academicCategory: 'Faculty Elective', semester:[2]),
      Course(code: 'IT-101', name: 'Fundamentals of Information Technology', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[2]),

      // 3rd Semester
      Course(code: 'IT-201', name: 'Computer Programming', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[3]),
      Course(code: 'IT-211', name: 'Discrete Mathematics', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[3]),
      Course(code: 'IT-212', name: 'Engineering Mathematics', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[3]),
      Course(code: 'IT-221', name: 'Digital Logic Design', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[3]),
      Course(code: 'EC-201', name: 'Economics', credits: 3, courseType: 'Core Course', academicCategory: 'Faculty Elective', semester:[3]),

      // 4th Semester
      Course(code: 'IT-222', name: 'Computer Architecture', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[4]),
      Course(code: 'IT-231', name: 'System Analysis and Design', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[4]),
      Course(code: 'IT-232', name: 'Database Systems', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[4]),
      Course(code: 'ES-101', name: 'Introduction to Geology', credits: 3, courseType: 'Core Course', academicCategory: 'Faculty Elective', semester:[4]),
      Course(code: 'MA-207', name: 'Differential Equations and Linear Algebra', credits: 3, courseType: 'Core Course', academicCategory: 'Faculty Elective', semester:[4]),
      Course(code: 'IT-202', name: 'Data Structures', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[4]),

      // 5th Semester
      Course(code: 'IT-332', name: 'Web Engineering', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[5]),
      Course(code: 'IT-331', name: 'Operating System', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[5]),
      Course(code: 'IT-321', name: 'Linear Circuit Analysis', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[5]),
      Course(code: 'IT-301', name: 'Object Oriented Programming', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[5]),
      Course(code: 'ST-101', name: 'Probability and Statistics', credits: 3, courseType: 'Core Course', academicCategory: 'Faculty Elective', semester:[5]),
      Course(code: 'IT-341', name: 'Communication Systems', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[5]),

      // 6th Semester
      Course(code: 'IT-342', name: 'Computer Communication and Networks', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[6]),
      Course(code: 'IT-302', name: 'Analysis of Algorithm', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[6]),
      Course(code: 'IT-322', name: 'Nonlinear Electronics', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[6]),
      Course(code: 'IT-333', name: 'Software Engineering', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[6]),
      Course(code: 'CH-101', name: 'Chemistry-1', credits: 3, courseType: 'Core Course', academicCategory: 'Faculty Elective', semester:[6]),

      // 7th Semester
      Course(code: 'IT-442', name: 'Network Security & Management', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[7]),
      Course(code: 'IT-411', name: 'Multimedia and Computer Graphics', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[7]),
      Course(code: 'IT-491', name: 'Project I', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[7]),

      // 8th Semester
      Course(code: 'IT-492', name: 'Project-II', credits: 3, courseType: 'Core Course', academicCategory: 'Domain Core', semester:[8]),
    ];

    // Add courses to both Firestore collections
    for (var course in coreCourses) {
      // Add to flat collection for easier queries
      await _firestore
          .collection(_coursesCollection)
          .doc(course.code)
          .set(course.toMap());

      // Also add to semester structure
      for (var sem in course.semester) {
        await _firestore
            .collection('semesters')
            .doc(sem.toString())
            .collection('courses')
            .doc(course.code)
            .set(course.toMap());
      }
    }
  }


  // Add elective courses from study scheme
  Future<void> _addElectiveCourses() async {
    final List<Course> electiveCourses = [
      Course(
        code: 'IT-412',
        name: 'Theory of Automata',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Study of abstract machines and automata, as well as computational problems that can be solved using them.',
        tags: ['theory', 'computational models', 'algorithms'],
        semester: [7, 8],
      ),
      Course(
        code: 'IT-402',
        name: 'Visual Programming',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Development of graphical user interfaces and applications using visual programming tools.',
        tags: ['UI/UX', 'front-end', 'GUI'],
        semester: [7, 8],
      ),
      Course(
        code: 'IT-434',
        name: 'Software Requirement Engineering',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Process of determining, analyzing, documenting, and validating software requirements.',
        tags: ['software engineering', 'requirements', 'documentation'],
        semester: [7, 8],
      ),
      Course(
        code: 'IT-435',
        name: 'Component Based Software Engineering',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Software engineering approach based on reusable software components.',
        tags: ['software engineering', 'components', 'reusability'],
        semester: [7, 8],
      ),
      Course(
        code: 'IT-436',
        name: 'Software Quality Assurance',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Processes and methods for ensuring software quality, testing, and verification.',
        tags: ['QA', 'testing', 'software quality'],
        semester: [7, 8],
      ),
      Course(
        code: 'IT-441',
        name: 'Mobile Computing',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Development of applications for mobile devices and understanding mobile computing platforms.',
        tags: ['mobile', 'Android', 'iOS', 'app development'],
        semester: [7, 8],
      ),
      Course(
        code: 'IT-401',
        name: 'Rapid Application Development',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Fast and efficient application development methodologies and tools.',
        tags: ['agile', 'development methodologies', 'frameworks'],
        semester:[7, 8] ,
      ),
      Course(
        code: 'IT-431',
        name: 'Information System',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Study of information systems in organizations, their design, implementation, and management.',
        tags: ['information systems', 'databases', 'business'],
        semester: [7, 8],
      ),
      Course(
        code: 'IT-432',
        name: 'Advanced Database Systems',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Advanced database concepts including distributed databases, NoSQL, and data warehousing.',
        tags: ['databases', 'SQL', 'NoSQL', 'data warehousing'],
        semester:[7, 8] ,
      ),
      Course(
        code: 'IT-433',
        name: 'Software Project Management',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Planning, organizing, and managing resources for successful software project completion.',
        tags: ['project management', 'leadership', 'agile'],
        semester:[7, 8] ,
      ),
      Course(
        code: 'IT-421',
        name: 'Microcontroller and Interfacing',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Design and implementation of microcontroller-based systems and their interfacing.',
        tags: ['hardware', 'embedded systems', 'IoT'],
        semester:[7, 8] ,
      ),
      Course(
        code: 'IT-442',
        name: 'Digital Image Processing',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Techniques for processing and analyzing digital images.',
        tags: ['image processing', 'computer vision', 'graphics'],
        semester:[7, 8] ,
      ),
      Course(
        code: 'IT-451',
        name: 'Introduction to Machine Learning',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Fundamental concepts of machine learning algorithms and their applications.',
        tags: ['machine learning', 'AI', 'data science'],
        semester: [7, 8],
      ),
      Course(
        code: 'IT-461',
        name: 'Organizational Behaviour',
        credits: 3,
        category: 'General',
        courseType: 'Elective',
        academicCategory: 'General',
        description: 'Study of human behavior in organizational settings and its impact on performance.',
        tags: ['psychology', 'management', 'leadership'],
        semester: [7, 8]
      ),
    ];

    // Add courses to both structures
    for (var course in electiveCourses) {
      // Add to flat collection for easier queries
      await _firestore
          .collection(_coursesCollection)
          .doc(course.code)
          .set(course.toMap());

      // Use "7-8" for multi-semester electives
      await _firestore
          .collection('semesters')
          .doc('electives')
          .collection('courses')
          .doc(course.code)
          .set(course.toMap());
    }
  }

    // Get all courses
    Future<List<Course>> getAllCourses() async {
      final QuerySnapshot snapshot = await _firestore.collection(_coursesCollection).get();
      return snapshot.docs.map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>)).toList();
    }

    // Get courses by semester
    Future<List<Course>> getCoursesBySemester(int semester) async {
      final QuerySnapshot snapshot = await _firestore
          .collection('semesters')
          .doc(semester.toString())
          .collection('courses')
          .get();
      return snapshot.docs.map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>)).toList();
    }

    // Get elective courses (from semesters 7-8)
    Future<List<Course>> getElectiveCourses() async {
      final QuerySnapshot snapshot = await _firestore
          .collection('semesters')
          .doc('electives')
          .collection('courses')
          .get();
      return snapshot.docs.map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>)).toList();
    }

    // Alternative method to get elective courses (by type)
    Future<List<Course>> getElectiveCoursesByType() async {
      final QuerySnapshot snapshot = await _firestore
          .collection(_coursesCollection)
          .where('courseType', isEqualTo: 'Elective')
          .get();
      return snapshot.docs.map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>)).toList();
    }

    // Get core courses
    Future<List<Course>> getCoreCourses() async {
      final QuerySnapshot snapshot = await _firestore
          .collection(_coursesCollection)
          .where('courseType', isEqualTo: 'Core Course')
          .get();
      return snapshot.docs.map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>)).toList();
    }

    // Get courses by department/category
    Future<List<Course>> getCoursesByCategory(String category) async {
      final QuerySnapshot snapshot = await _firestore
          .collection(_coursesCollection)
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>)).toList();
    }

    // Get course by code
    Future<Course?> getCourseByCode(String code) async {
      final DocumentSnapshot snapshot = await _firestore.collection(_coursesCollection).doc(code).get();
      if (snapshot.exists) {
        return Course.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    }

    // Update user's current courses
    Future<void> updateUserCourses(String userId, List<String> courseCodes) async {
      await _firestore.collection('users').doc(userId).update({
        'currentCourses': courseCodes,
      });
    }

    // Get user's current courses
    Future<List<Course>> getUserCourses(String userId) async {
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && (userDoc.data() as Map<String, dynamic>).containsKey('currentCourses')) {
        List<String> courseCodes = List<String>.from((userDoc.data() as Map<String, dynamic>)['currentCourses']);
        List<Course> courses = [];

        for (String code in courseCodes) {
          Course? course = await getCourseByCode(code);
          if (course != null) {
            courses.add(course);
          }
        }

        return courses;
      }

      return [];
    }

    // Update user's interests
    Future<void> updateUserInterests(String userId, List<String> interests) async {
      await _firestore.collection('users').doc(userId).update({
        'interests': interests,
      });
    }

    // Get courses by tags (for recommendations)
    Future<List<Course>> getCoursesByTags(List<String> tags) async {
      final QuerySnapshot snapshot = await _firestore.collection(_coursesCollection).get();

      List<Course> allCourses = snapshot.docs
          .map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter courses based on tags
      return allCourses.where((course) {
        for (String tag in course.tags) {
          for (String searchTag in tags) {
            if (tag.toLowerCase().contains(searchTag.toLowerCase())) {
              return true;
            }
          }
        }
        return false;
      }).toList();
    }
  }