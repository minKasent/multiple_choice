import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/chapter_model.dart';
import '../../data/models/passage_model.dart';
import '../../data/models/question_model.dart';

part 'question_bank_state.freezed.dart';

@freezed
class QuestionBankState with _$QuestionBankState {
  const factory QuestionBankState.initial() = _Initial;
  const factory QuestionBankState.loading() = _Loading;
  
  // Chapters
  const factory QuestionBankState.chaptersLoaded(List<ChapterModel> chapters) = _ChaptersLoaded;
  const factory QuestionBankState.chapterCreated(ChapterModel chapter) = _ChapterCreated;
  const factory QuestionBankState.chapterUpdated(ChapterModel chapter) = _ChapterUpdated;
  const factory QuestionBankState.chapterDeleted() = _ChapterDeleted;
  
  // Passages
  const factory QuestionBankState.passagesLoaded(List<PassageModel> passages) = _PassagesLoaded;
  const factory QuestionBankState.passageCreated(PassageModel passage) = _PassageCreated;
  const factory QuestionBankState.passageUpdated(PassageModel passage) = _PassageUpdated;
  const factory QuestionBankState.passageDeleted() = _PassageDeleted;
  
  // Questions
  const factory QuestionBankState.questionsLoaded(List<QuestionModel> questions) = _QuestionsLoaded;
  const factory QuestionBankState.questionCreated(QuestionModel question) = _QuestionCreated;
  const factory QuestionBankState.questionUpdated(QuestionModel question) = _QuestionUpdated;
  const factory QuestionBankState.questionDeleted() = _QuestionDeleted;
  
  const factory QuestionBankState.error(String message) = _Error;
}
