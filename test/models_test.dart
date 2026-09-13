import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pearant_app/app_locale.dart';
import 'package:pearant_app/models/behavior_goal_model.dart';
import 'package:pearant_app/models/child_model.dart';
import 'package:pearant_app/models/session_model.dart';

/// Unit tests for the data layer.
///
/// These models sit between Supabase and the UI, so every field they decode is
/// a field the app can crash on. The rows below are shaped like the ones the
/// toy and the app actually exchange, including the rough edges: missing keys,
/// numbers arriving as strings, and timestamps that failed to serialise.
void main() {
  group('Child.fromJson', () {
    test('decodes a complete row', () {
      final child = Child.fromJson({
        'id': 'c-1',
        'name': 'أيهم',
        'nameEn': 'Ayham',
        'age': 7,
        'gender': 'ذكر',
        'avatar': '👦',
        'interests': ['قصص', 'حيوانات'],
        'createdAt': '2026-03-01T10:30:00.000Z',
        'parentId': 'p-1',
        'parentNotes': 'يحب قصص الحيوانات',
        'rfidId': 'RFID-004',
      });

      expect(child.id, 'c-1');
      expect(child.name, 'أيهم');
      expect(child.nameEn, 'Ayham');
      expect(child.age, 7);
      expect(child.interests, ['قصص', 'حيوانات']);
      expect(child.createdAt.toUtc().year, 2026);
      expect(child.rfidId, 'RFID-004');
    });

    test('falls back to defaults when the row is empty', () {
      final child = Child.fromJson({});

      expect(child.id, '');
      expect(child.name, '');
      expect(child.nameEn, isNull);
      expect(child.age, 5);
      expect(child.gender, 'ذكر');
      expect(child.avatar, '👦');
      expect(child.interests, isEmpty);
      expect(child.rfidId, isNull);
    });

    test('survives an unparseable createdAt instead of throwing', () {
      final before = DateTime.now();
      final child = Child.fromJson({'createdAt': 'not-a-date'});

      expect(
        child.createdAt.isBefore(before.subtract(const Duration(seconds: 1))),
        isFalse,
        reason: 'a bad timestamp should fall back to now, not to epoch',
      );
    });

    test('round-trips through toJson', () {
      final original = Child.fromJson({
        'id': 'c-2',
        'name': 'أبي',
        'age': 6,
        'interests': ['ألوان'],
        'createdAt': '2026-05-20T08:00:00.000Z',
      });

      final restored = Child.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.age, original.age);
      expect(restored.interests, original.interests);
      expect(
        restored.createdAt.toIso8601String(),
        original.createdAt.toIso8601String(),
      );
    });
  });

  group('Child.displayName', () {
    final locale = AppLocale.notifier;
    final original = locale.value;

    tearDown(() => locale.value = original);

    Child child({String? nameEn}) => Child(
          id: 'c-1',
          name: 'أيهم',
          nameEn: nameEn,
          age: 7,
          gender: 'ذكر',
          avatar: '👦',
          interests: const [],
          createdAt: DateTime(2026, 3, 1),
        );

    test('uses the Arabic name while the app is in Arabic', () {
      locale.value = const Locale('ar');
      expect(child(nameEn: 'Ayham').displayName, 'أيهم');
    });

    test('uses the English name while the app is in English', () {
      locale.value = const Locale('en');
      expect(child(nameEn: 'Ayham').displayName, 'Ayham');
    });

    test('falls back to the Arabic name when no English name was entered', () {
      locale.value = const Locale('en');
      expect(child(nameEn: null).displayName, 'أيهم');
      expect(child(nameEn: '   ').displayName, 'أيهم');
    });
  });

  group('Child.copyWith', () {
    final child = Child(
      id: 'c-1',
      name: 'أيهم',
      nameEn: 'Ayham',
      age: 7,
      gender: 'ذكر',
      avatar: '👦',
      interests: const ['قصص'],
      createdAt: DateTime(2026, 3, 1),
      rfidId: 'RFID-004',
    );

    test('changes only the fields it is given', () {
      final updated = child.copyWith(age: 8);

      expect(updated.age, 8);
      expect(updated.name, 'أيهم');
      expect(updated.nameEn, 'Ayham');
      expect(updated.rfidId, 'RFID-004');
    });

    test('clears optional fields only when explicitly asked', () {
      expect(child.copyWith(nameEn: null).nameEn, 'Ayham');
      expect(child.copyWith(clearNameEn: true).nameEn, isNull);
      expect(child.copyWith(clearRfidId: true).rfidId, isNull);
    });
  });

  group('BehaviorGoal.progressPercent', () {
    BehaviorGoal goal({required int target, required int current}) =>
        BehaviorGoal(
          id: 'g-1',
          childId: 'c-1',
          parentId: 'p-1',
          title: 'ترتيب الألعاب',
          description: 'يرتّب ألعابه بعد اللعب',
          targetBehavior: 'tidy_up',
          targetCount: target,
          currentCount: current,
          createdAt: DateTime(2026, 4, 1),
        );

    test('reports the fraction completed', () {
      expect(goal(target: 10, current: 3).progressPercent, closeTo(0.3, 1e-9));
    });

    test('never exceeds 1 when the child overshoots the target', () {
      expect(goal(target: 5, current: 9).progressPercent, 1.0);
    });

    test('returns 0 for a zero target instead of dividing by zero', () {
      expect(goal(target: 0, current: 4).progressPercent, 0);
    });
  });

  group('BehaviorGoal.fromSupabase', () {
    test('maps snake_case columns onto the model', () {
      final goal = BehaviorGoal.fromSupabase({
        'id': 'g-1',
        'child_id': 'c-1',
        'parent_id': 'p-1',
        'title': 'تناول الفطور',
        'description': 'يفطر كل صباح',
        'zone': 'home',
        'target_behavior': 'eat_breakfast',
        'target_count': 7,
        'current_count': 2,
        'is_completed': false,
        'created_at': '2026-04-01T06:00:00.000Z',
      });

      expect(goal.childId, 'c-1');
      expect(goal.zone, 'home');
      expect(goal.targetBehavior, 'eat_breakfast');
      expect(goal.targetCount, 7);
      expect(goal.currentCount, 2);
      expect(goal.isCompleted, isFalse);
      expect(goal.completedAt, isNull);
    });

    test('coerces counts that arrive as strings', () {
      final goal = BehaviorGoal.fromSupabase({
        'target_count': '5',
        'current_count': '2',
        'created_at': '2026-04-01T06:00:00.000Z',
      });

      expect(goal.targetCount, 5);
      expect(goal.currentCount, 2);
    });

    test('treats anything other than true as not completed', () {
      expect(BehaviorGoal.fromSupabase({'is_completed': 'true'}).isCompleted,
          isFalse);
      expect(BehaviorGoal.fromSupabase({'is_completed': null}).isCompleted,
          isFalse);
      expect(
          BehaviorGoal.fromSupabase({'is_completed': true}).isCompleted, isTrue);
    });
  });

  group('BehaviorGoal.toSupabaseInsert', () {
    test('omits completed_at for a goal still in progress', () {
      final payload = BehaviorGoal(
        id: 'g-1',
        childId: 'c-1',
        parentId: 'p-1',
        title: 'ترتيب الألعاب',
        description: '',
        targetBehavior: 'tidy_up',
        targetCount: 5,
        createdAt: DateTime(2026, 4, 1),
      ).toSupabaseInsert('p-1');

      expect(payload.containsKey('completed_at'), isFalse);
      expect(payload['child_id'], 'c-1');
      expect(payload['target_count'], 5);
      expect(payload.containsKey('id'), isFalse,
          reason: 'the database generates the id');
    });

    test('includes completed_at once the goal is finished', () {
      final payload = BehaviorGoal(
        id: 'g-1',
        childId: 'c-1',
        parentId: 'p-1',
        title: 'ترتيب الألعاب',
        description: '',
        targetBehavior: 'tidy_up',
        targetCount: 5,
        currentCount: 5,
        isCompleted: true,
        createdAt: DateTime(2026, 4, 1),
        completedAt: DateTime(2026, 4, 20),
      ).toSupabaseInsert('p-1');

      expect(payload['is_completed'], isTrue);
      expect(payload['completed_at'], isNotNull);
    });
  });

  group('Session.fromJson', () {
    test('decodes nested activities and the zone visit counts', () {
      final session = Session.fromJson({
        'id': 's-1',
        'childId': 'c-1',
        'startTime': '2026-05-02T16:00:00.000Z',
        'endTime': '2026-05-02T16:25:00.000Z',
        'totalMinutes': 25,
        'activities': [
          {
            'id': 'a-1',
            'title': 'قصة الأسد',
            'type': 'story',
            'zone': 'zoo',
            'duration': 6,
            'result': 'completed',
            'starsEarned': 2,
            'completedAt': '2026-05-02T16:08:00.000Z',
          },
        ],
        'zonesVisited': {'zoo': 2, 'home': 1},
        'mood': 'happy',
        'focusLevel': 'high',
        'starsEarned': 5,
      });

      expect(session.totalMinutes, 25);
      expect(session.activities, hasLength(1));
      expect(session.activities.first.zone, 'zoo');
      expect(session.zonesVisited['zoo'], 2);
      expect(session.starsEarned, 5);
      expect(session.endTime, isNotNull);
    });

    test('handles a session that is still running', () {
      final session = Session.fromJson({
        'id': 's-2',
        'childId': 'c-1',
        'startTime': '2026-05-02T16:00:00.000Z',
        'totalMinutes': 0,
        'activities': <dynamic>[],
        'zonesVisited': <String, dynamic>{},
        'mood': '',
        'focusLevel': '',
        'starsEarned': 0,
      });

      expect(session.endTime, isNull);
      expect(session.activities, isEmpty);
      expect(session.zonesVisited, isEmpty);
    });
  });
}
