import 'package:app/features/question_bank/presentation/pages/passages_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/exams/presentation/pages/available_exams_page.dart';
import '../../features/exams/presentation/pages/create_exam_page.dart';
import '../../features/exams/presentation/pages/take_exam_page.dart';
import '../../features/exams/presentation/pages/exams_list_page.dart';
import '../../features/exams/presentation/pages/exam_detail_page.dart';
import '../../features/exams/presentation/pages/select_questions_page.dart';
import '../../features/exams/data/models/exam_model.dart';
import '../../features/exam_sessions/presentation/pages/schedule_exam_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/question_bank/presentation/pages/question_bank_page.dart';
import '../../features/question_bank/presentation/pages/chapters_page.dart';
import '../../features/question_bank/presentation/pages/create_question_page.dart';
import '../../features/question_bank/presentation/pages/questions_list_page.dart';
import '../../features/question_bank/data/models/chapter_model.dart';
import '../../features/question_bank/data/models/passage_model.dart';
import '../../features/question_bank/data/models/question_model.dart';
import '../../features/exam_taking/presentation/pages/exam_result_detail_page.dart';
import '../../features/exam_taking/data/models/exam_result_model.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/statistics/presentation/pages/statistics_dashboard_page.dart';
import '../../features/statistics/presentation/pages/student_statistics_page.dart';
import '../../features/subjects/data/models/subject_model.dart'
    hide ChapterModel;
import '../../features/subjects/presentation/pages/subjects_page.dart';
import '../../features/users/presentation/pages/users_page.dart';
import '../../features/users/presentation/pages/users_management_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Auth routes
    AutoRoute(page: LoginRoute.page, path: '/login', initial: true),
    AutoRoute(page: RegisterRoute.page, path: '/register'),

    // Dashboard route
    AutoRoute(page: DashboardRoute.page, path: '/dashboard'),

    // Profile routes
    AutoRoute(page: ProfileRoute.page, path: '/profile'),
    AutoRoute(page: EditProfileRoute.page, path: '/profile/edit'),
    AutoRoute(page: ChangePasswordRoute.page, path: '/profile/change-password'),

    // Subject Management
    AutoRoute(page: SubjectsRoute.page, path: '/subjects'),

    // Question Bank
    AutoRoute(page: QuestionBankRoute.page, path: '/question-bank'),
    AutoRoute(page: ChaptersRoute.page, path: '/question-bank/chapters'),
    AutoRoute(page: PassagesRoute.page, path: '/question-bank/passages'),
    AutoRoute(page: QuestionsListRoute.page, path: '/question-bank/questions'),
    AutoRoute(
      page: CreateQuestionRoute.page,
      path: '/question-bank/questions/create',
    ),

    // Exam routes (for students)
    AutoRoute(page: AvailableExamsRoute.page, path: '/exams'),
    AutoRoute(page: TakeExamRoute.page, path: '/exams/:examId/take'),

    // Exam Management (for teachers/admins)
    AutoRoute(page: ExamsListRoute.page, path: '/exams-management'),
    AutoRoute(page: CreateExamRoute.page, path: '/exams-management/create'),
    AutoRoute(page: ExamDetailRoute.page, path: '/exams-management/:examId'),
    AutoRoute(
      page: SelectQuestionsRoute.page,
      path: '/exams-management/:examId/select-questions',
    ),
    AutoRoute(page: ScheduleExamRoute.page, path: '/exams-management/schedule'),

    // User Management
    AutoRoute(page: UsersRoute.page, path: '/users'),

    // Statistics
    AutoRoute(page: StatisticsRoute.page, path: '/statistics'),
    AutoRoute(page: StudentStatisticsRoute.page, path: '/statistics/student'),
  ];
}
