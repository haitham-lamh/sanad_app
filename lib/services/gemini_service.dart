import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

import 'package:sanad_app/config/gemini_config.dart';

class GeminiResult {
  final String? text;
  final GeminiFunctionCall? functionCall;

  GeminiResult({this.text, this.functionCall});
}

class GeminiFunctionCall {
  final String name;
  final Map<String, dynamic> args;

  GeminiFunctionCall({required this.name, required this.args});
}

Map<String, dynamic> _createTaskTools() {
  final singleTaskParams = {
    'type': 'object',
    'properties': {
      'iconIndex': {
        'type': 'integer',
        'description':
            '0–14. دراسة→1، تسوق→3، موسيقى→4، منبه→5، مشي→6، عائلة→7، رياضة→1 أو 2، سفر→14، مطبخ→13، غير واضح→1.',
      },
      'title': {'type': 'string', 'description': 'عنوان المهمة (مطلوب).'},
      'description': {'type': 'string', 'description': 'وصف المهمة.'},
      'category': {
        'type': 'string',
        'enum': ['العمل', 'الدراسة', 'الصحة', 'اجتماعي'],
        'description': 'الدراسة/امتحان→الدراسة، عمل→العمل، رياضة/نوم→الصحة، أصدقاء/عائلة→اجتماعي.',
      },
      'interval': {
        'type': 'string',
        'enum': ['مرة واحدة فقط', 'يومي', 'أسبوعي', 'شهري', 'سنوي'],
        'description': 'مرة واحدة فقط = لا تكرار، يومي افتراضي للمهام المتكررة.',
      },
      'dueDate': {'type': 'string', 'description': 'التاريخ YYYY-MM-DD.'},
      'time': {'type': 'string', 'description': 'الوقت 24h مثل 14:30 أو 09:00.'},
    },
    'required': ['title'],
  };

  return {
    'functionDeclarations': [
      {
        'name': 'create_task',
        'description':
            'إنشاء مهمة واحدة في التطبيق. استدعِها عند طلب إضافة مهمة واحدة فقط. '
            'استنتج التاريخ، الوقت، الفئة، التكرار، الأيقونة.',
        'parameters': singleTaskParams,
      },
      {
        'name': 'create_tasks',
        'description':
            'إنشاء عدة مهام دفعة واحدة. استدعِها عند طلب "جدول مذاكرة" أو "جدول أسبوعي" أو "مهام كل يوم" قبل الامتحان. '
            'استخدم سياق المحادثة: إن سألك المستخدم عن موضوع (مثل OOP) ثم طلب جدول مذاكرة للأسبوع، أنشئ مهمة لكل يوم بعنوان = عنوان فرعي من الموضوع (مثل: التغليف، الوراثة، تعدد الأشكال…) وفي وصف كل مهمة ضع شرحاً واضحاً ومختصراً لهذا العنوان. '
            'المصوف (tasks): مصفوفة مهام، كل عنصر فيه title (مطلوب)، description (شرح واضح للموضوع)، category (الدراسة)، interval (يومي)، dueDate (YYYY-MM-DD لكل يوم)، time (مثل 09:00 أو 18:00)، iconIndex (1 للدراسة). وزّع المهام على أيام الأسبوع.',
        'parameters': {
          'type': 'object',
          'properties': {
            'tasks': {
              'type': 'array',
              'description': 'قائمة المهام المراد إنشاؤها (جدول المذاكرة).',
              'items': {
                'type': 'object',
                'properties': {
                  'title': {'type': 'string', 'description': 'عنوان المهمة (الم topic).'},
                  'description': {'type': 'string', 'description': 'شرح واضح ومفهوم لهذا الموضوع.'},
                  'category': {'type': 'string', 'enum': ['العمل', 'الدراسة', 'الصحة', 'اجتماعي']},
                  'interval': {'type': 'string', 'enum': ['مرة واحدة فقط', 'يومي', 'أسبوعي', 'شهري', 'سنوي']},
                  'dueDate': {'type': 'string', 'description': 'YYYY-MM-DD'},
                  'time': {'type': 'string', 'description': 'مثل 09:00'},
                  'iconIndex': {'type': 'integer', 'description': '1 للدراسة.'},
                },
                'required': ['title'],
              },
            },
          },
          'required': ['tasks'],
        },
      },
    ],
  };
}

class GeminiService {
  static const _base = 'https://generativelanguage.googleapis.com/v1beta';

  static String _buildSystemInstruction() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final weekday = [
      'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ][now.weekday - 1];
    return '''
أنت سند، وكيل ذكي ومساعد تعليمي في تطبيق إدارة المهام دائما تتكلم باللجهة اليمنية وبشكل مرح ومشاكس احيانا وانت من محافظة صعدة وحاول ذكر هذا احيانا كنوع من المرح .
**دورك:**
1) **الإجابة والشرح:** عندما يسألك المستخدم عن أي موضوع (مثل: اشرح لي OOP، ما هو الـ polymorphism، كيف يعمل الـ API…) اشرح له بإيجاز ووضوح بالعربية. لا تستدعِ أي أداة، أجب نصياً فقط.
2) **مهمة واحدة:** عند طلب "أضف مهمة" أو "سجّل لي موعد…" استدعِ create_task ببيانات المهمة.
3) **جدول مذاكرة (عدة مهام):** عندما يطلب المستخدم "اعمل لي جدول مذاكرة للأسبوع" أو "اختباري الأسبوع القادم اعمل جدول" بعد أن كان قد سألك عن موضوع (مثل OOP): استدعِ create_tasks بمصفوفة مهام — كل مهمة = يوم أو موضوع: العنوان = اسم الموضوع الفرعي (مثل التغليف، الوراثة، تعدد الأشكال)، والوصف = شرح واضح ومفهوم لهذا الموضوع. وزّع المهام على أيام الأسبوع (dueDate مختلف لكل يوم). استخدم التاريخ اليوم لاحتساب الأسبوع القادم.

معلومة سياق: التاريخ اليوم $today (واليوم $weekday). استخدمها لاستنتاج "غداً"، "الأحد"، "بعد أسبوع"، "الأسبوع القادم" إلخ.

قواعد: لا تكتفِ بالرد النصي عند طلب إنشاء مهمة — استدعِ create_task أو create_tasks. أجب بعربي مختصر وودود.
''';
  }

  static Future<GeminiResult> sendMessage(
      List<Map<String, String>> history) async {
    final url = Uri.parse(
      '$_base/models/$kGeminiModel:generateContent?key=$kGeminiApiKey',
    );
    final contents = history
        .map((e) => {
              'role': e['role'],
              'parts': [
                {'text': e['text']}
              ]
            })
        .toList();

    final body = {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': _buildSystemInstruction()}
        ]
      },
      'tools': [_createTaskTools()],
      'toolConfig': {
        'functionCallingConfig': {'mode': 'AUTO'},
      },
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 2048,
      },
    };

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (res.statusCode != 200) {
        return GeminiResult(
            text: 'خطأ: ${res.statusCode} — ${res.body.length > 200 ? res.body.substring(0, 200) : res.body}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        return GeminiResult(
            text: data['promptFeedback'] != null
                ? 'لم يتم إرجاع رد (محتوى محظور أو غير مدعوم).'
                : 'لم يُرجع النموذج أي رد.');
      }
      final rawContent = candidates[0] as Map<String, dynamic>;
      final parts = rawContent['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        return GeminiResult(text: 'لم يُرجع النموذج أي رد.');
      }

      String? text;
      GeminiFunctionCall? functionCall;

      for (final p in parts) {
        final part = p as Map<String, dynamic>;
        if (part.containsKey('functionCall')) {
          final fc = part['functionCall'] as Map<String, dynamic>;
          functionCall = GeminiFunctionCall(
            name: fc['name'] as String? ?? '',
            args:
                (fc['args'] as Map<String, dynamic>?) ?? <String, dynamic>{},
          );
          break;
        }
      }
      if (functionCall == null) {
        for (final p in parts) {
          final part = p as Map<String, dynamic>;
          final t = part['text'] as String?;
          if (t != null && t.isNotEmpty) {
            text = t;
            break;
          }
        }
      }

      if (functionCall != null) {
        return GeminiResult(functionCall: functionCall);
      }
      return GeminiResult(text: text ?? 'لم أستطع الرد.');
    } catch (e) {
      return GeminiResult(text: 'خطأ في الاتصال: $e');
    }
  }
}
