# Flutter Analyze Errors

## Summary

- **Total Issues:** 60
- **Errors:** 46
- **Warnings:** 1
- **Infos:** 13

## Error Details

### `lib\core\services\notification_service.dart`

- **error** - The argument type 'PaginatedResponse<Notification>' can't be assigned to the parameter type 'Iterable<Notification>'. - lib\core\services\notification_service.dart:176:29 - argument_type_not_assignable
- **error** - The method 'markNotificationAsRead' isn't defined for the type 'NotificationRepository' - lib\core\services\notification_service.dart:204:37 - undefined_method
- **error** - The method 'markAllNotificationsAsRead' isn't defined for the type 'NotificationRepository' - lib\core\services\notification_service.dart:230:37 - undefined_method

### `lib\core\services\socket_service.dart`

- **info** - The prefix 'IO' isn't a lower_case_with_underscores identifier - lib\core\services\socket_service.dart:3:60 - library_prefixes

### `lib\presentation\providers\answer_provider.dart`

- **error** - The method 'voteAnswer' isn't defined for the type 'AnswerRepository' - lib\presentation\providers\answer_provider.dart:304:25 - undefined_method

### `lib\presentation\providers\auth_provider.dart`

- **error** - The argument type 'String' can't be assigned to the parameter type 'Map<String, dynamic>'. - lib\presentation\providers\auth_provider.dart:38:31 - argument_type_not_assignable
- **error** - The getter 'token' isn't defined for the type 'User' - lib\presentation\providers\auth_provider.dart:59:21 - undefined_getter
- **error** - The getter 'token' isn't defined for the type 'User' - lib\presentation\providers\auth_provider.dart:82:21 - undefined_getter
- **error** - The argument type 'Map<String, dynamic>' can't be assigned to the parameter type 'String'. - lib\presentation\providers\auth_provider.dart:134:49 - argument_type_not_assignable

### `lib\presentation\providers\notification_provider.dart`

- **error** - The getter 'items' isn't defined for the type 'PaginatedResponse<Notification>' - lib\presentation\providers\notification_provider.dart:53:33 - undefined_getter
- **error** - The getter 'items' isn't defined for the type 'PaginatedResponse<Notification>' - lib\presentation\providers\notification_provider.dart:55:38 - undefined_getter
- **info** - The type of the right operand ('int') isn't a subtype or a supertype of the left operand ('String') - lib\presentation\providers\notification_provider.dart:84:59 - unrelated_type_equality_checks
- **info** - The type of the right operand ('int') isn't a subtype or a supertype of the left operand ('String') - lib\presentation\providers\notification_provider.dart:153:59 - unrelated_type_equality_checks

### `lib\presentation\providers\question_provider.dart`

- **error** - The method 'voteQuestion' isn't defined for the type 'QuestionRepository' - lib\presentation\providers\question_provider.dart:303:25 - undefined_method

### `lib\presentation\providers\tag_provider.dart`

- **error** - The returned type 'Null' isn't returnable from a 'Tag' function, as required by the closure's context - lib\presentation\providers\tag_provider.dart:98:119 - return_of_invalid_type_from_closure
- **warning** - Dead code - lib\presentation\providers\tag_provider.dart:102:5 - dead_code

### `lib\presentation\routes\route_generator.dart`

- **error** - Undefined name '_' - lib\presentation\routes\route_generator.dart:19:60 - undefined_identifier
- **error** - Undefined name '_' - lib\presentation\routes\route_generator.dart:19:81 - undefined_identifier

### `lib\presentation\screens\answer\answer_screen.dart`

- **error** - The method 'AnswerRequest' isn't defined for the type '_AnswerScreenState' - lib\presentation\screens\answer\answer_screen.dart:46:31 - undefined_method
- **error** - 2 positional arguments expected by 'createAnswer', but 1 found - lib\presentation\screens\answer\answer_screen.dart:52:40 - not_enough_positional_arguments
- **error** - The named parameter 'showBackButton' isn't defined - lib\presentation\screens\answer\answer_screen.dart:83:11 - undefined_named_parameter
- **error** - The named parameter 'showBackButton' isn't defined - lib\presentation\screens\answer\answer_screen.dart:92:9 - undefined_named_parameter
- **error** - The named parameter 'onContentChanged' is required, but there's no corresponding argument - lib\presentation\screens\answer\answer_screen.dart:124:19 - missing_required_argument
- **error** - The named parameter 'controller' isn't defined - lib\presentation\screens\answer\answer_screen.dart:125:21 - undefined_named_parameter
- **error** - The named parameter 'hint' isn't defined - lib\presentation\screens\answer\answer_screen.dart:126:21 - undefined_named_parameter
- **error** - The named parameter 'minLines' isn't defined - lib\presentation\screens\answer\answer_screen.dart:127:21 - undefined_named_parameter
- **error** - The named parameter 'validator' isn't defined - lib\presentation\screens\answer\answer_screen.dart:128:21 - undefined_named_parameter

### `lib\presentation\screens\answer\edit_answer_screen.dart`

- **error** - The method 'AnswerRequest' isn't defined for the type '_EditAnswerScreenState' - lib\presentation\screens\answer\edit_answer_screen.dart:51:31 - undefined_method
- **error** - The named parameter 'showBackButton' isn't defined - lib\presentation\screens\answer\edit_answer_screen.dart:88:11 - undefined_named_parameter
- **error** - The named parameter 'showBackButton' isn't defined - lib\presentation\screens\answer\edit_answer_screen.dart:97:9 - undefined_named_parameter
- **error** - The named parameter 'onContentChanged' is required, but there's no corresponding argument - lib\presentation\screens\answer\edit_answer_screen.dart:113:19 - missing_required_argument
- **error** - The named parameter 'controller' isn't defined - lib\presentation\screens\answer\edit_answer_screen.dart:114:21 - undefined_named_parameter
- **error** - The named parameter 'hint' isn't defined - lib\presentation\screens\answer\edit_answer_screen.dart:115:21 - undefined_named_parameter
- **error** - The named parameter 'minLines' isn't defined - lib\presentation\screens\answer\edit_answer_screen.dart:116:21 - undefined_named_parameter
- **error** - The named parameter 'validator' isn't defined - lib\presentation\screens\answer\edit_answer_screen.dart:117:21 - undefined_named_parameter

### `lib\presentation\screens\home\home_screen.dart`

- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\screens\home\home_screen.dart:92:44 - use_build_context_synchronously

### `lib\presentation\screens\profile\user_answers_screen.dart`

- **error** - The method 'getUserAnswers' isn't defined for the type 'AnswerProvider' - lib\presentation\screens\profile\user_answers_screen.dart:75:44 - undefined_method
- **error** - The method 'getUserAnswers' isn't defined for the type 'AnswerProvider' - lib\presentation\screens\profile\user_answers_screen.dart:107:44 - undefined_method
- **error** - The named parameter 'showQuestionTitle' isn't defined - lib\presentation\screens\profile\user_answers_screen.dart:180:13 - undefined_named_parameter
- **error** - The named parameter 'onTap' isn't defined - lib\presentation\screens\profile\user_answers_screen.dart:181:13 - undefined_named_parameter

### `lib\presentation\screens\profile\user_questions_screen.dart`

- **error** - The method 'getUserQuestions' isn't defined for the type 'QuestionProvider' - lib\presentation\screens\profile\user_questions_screen.dart:75:48 - undefined_method
- **error** - The method 'getUserQuestions' isn't defined for the type 'QuestionProvider' - lib\presentation\screens\profile\user_questions_screen.dart:107:48 - undefined_method

### `lib\presentation\screens\question\ask_question_screen.dart`

- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\screens\question\ask_question_screen.dart:111:13 - use_build_context_synchronously
- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\screens\question\ask_question_screen.dart:116:42 - use_build_context_synchronously
- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\screens\question\ask_question_screen.dart:119:13 - use_build_context_synchronously

### `lib\presentation\screens\question\question_detail_screen.dart`

- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\screens\question\question_detail_screen.dart:76:30 - use_build_context_synchronously
- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\screens\question\question_detail_screen.dart:79:11 - use_build_context_synchronously
- **info** - Don't use 'BuildContext's across async gaps - lib\presentation\screens\question\question_detail_screen.dart:108:58 - use_build_context_synchronously
- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\screens\question\question_detail_screen.dart:113:32 - use_build_context_synchronously
- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\screens\question\question_detail_screen.dart:116:13 - use_build_context_synchronously

### `lib\presentation\widgets\answer\answer_form.dart`

- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\widgets\answer\answer_form.dart:77:13 - use_build_context_synchronously
- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\widgets\answer\answer_form.dart:84:13 - use_build_context_synchronously

### `lib\presentation\widgets\auth\auth_form.dart`

- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\widgets\auth\auth_form.dart:38:13 - use_build_context_synchronously

### `lib\presentation\widgets\auth\login_form.dart`

- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\widgets\auth\login_form.dart:45:42 - use_build_context_synchronously
- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\widgets\auth\login_form.dart:49:11 - use_build_context_synchronously

### `lib\presentation\widgets\auth\register_form.dart`

- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\widgets\auth\register_form.dart:67:42 - use_build_context_synchronously
- **info** - Don't use 'BuildContext's across async gaps, guarded by an unrelated 'mounted' check - lib\presentation\widgets\auth\register_form.dart:71:11 - use_build_context_synchronously

### `lib\presentation\widgets\common\typing_indicator.dart`

- **error** - Target of URI doesn't exist: 'package:stackit_frontend/data/repositories/user_repository.dart' - lib\presentation\widgets\common\typing_indicator.dart:4:8 - uri_does_not_exist
- **error** - The name 'UserRepository' isn't a type, so it can't be used as a type argument - lib\presentation\widgets\common\typing_indicator.dart:25:40 - non_type_as_type_argument
- **error** - Undefined class 'UserRepository' - lib\presentation\widgets\common\typing_indicator.dart:84:38 - undefined_class
