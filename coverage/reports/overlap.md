# Test Coverage Overlap Report

## Summary

- **Total tests:** 78
- **Full subsets (100%):** 50
- **High overlap (≥75%):** 2226
- **Significant overlap (≥50%):** 2374

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 3043 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2773 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3113 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3113 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3122 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2474 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2474 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2474 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2475 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2474 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2474 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2474 |
| command:dynamic_option | alias:alias_overrides_parameters | 2475 |
| alias:composite_alias | alias:simple_alias_command | 2980 |
| alias:simple_alias_command | alias:composite_alias | 2980 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2474 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2474 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2474 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_default_value | 2474 |
| command:dynamic_default_value | command:dynamic_option | 2474 |
| command:dynamic_option | command:dynamic_default_value | 2475 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2474 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_default_value_callback | 2474 |
| command:dynamic_default_value_callback | command:dynamic_option | 2474 |
| command:dynamic_option | command:dynamic_default_value_callback | 2475 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2474 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2475 |
| completion:command | completion:completion_with_saved_parameter | 2984 |
| completion:command | completion:dynamic_command | 2984 |
| completion:command | completion:dynamic_group | 2984 |
| completion:command | completion:group | 2984 |
| completion:command | types:complete_date | 2984 |
| completion:command | types:suggestion | 2984 |
| custom:group_python | completion:completion_with_saved_parameter | 2901 |
| completion:dynamic_command | completion:dynamic_group | 3017 |
| completion:dynamic_group | completion:dynamic_command | 3017 |
| completion:group | completion:dynamic_command | 3009 |
| completion:group | completion:dynamic_group | 3009 |
| custom:group_python | custom:simple_python | 2901 |
| custom:group_python | types:date | 2901 |
| custom:group_python | types:default_with_converter | 2901 |
| custom:group_python | types:suggestion | 2901 |
| parameter:simple_parameter | extension:copy_extension | 2773 |
| parameter:simple_parameter | extension:move_extension | 2773 |
| flow:overwrite_flow | flow:extend_flow | 3262 |
| lib:which | lib:check_output_on_path | 14 |
| lib:which | lib:safe_check_output_on_path | 14 |
| parameter:simple_parameter | parameter:appending_parameters | 2773 |
| parameter:appending_parameters | parameter:using_automatic_options | 2780 |
| parameter:simple_parameter | parameter:parameter_precedence | 2773 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2773 |
| parameter:simple_parameter | parameter:removing_parameters | 2773 |
| parameter:removing_parameters | parameter:using_automatic_options | 2793 |
| parameter:simple_parameter | parameter:replacing_parameters | 2773 |
| parameter:simple_parameter | parameter:using_automatic_options | 2773 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2773 |
| types:default_with_converter | types:date | 2903 |
| types:default_with_converter | types:suggestion | 2903 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.1% | 99.9% | 3043 | 2775 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 90.0% | 99.9% | 3113 | 2806 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.8% | 99.9% | 3122 | 2806 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.7% | 99.9% | 3126 | 2806 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.4% | 99.9% | 3114 | 3096 |
| alias:capture_flow_command | flow:reuse_flow_parameters | 82.4% | 99.9% | 3114 | 2569 |
| alias:capture_partial_flow | flow:reuse_flow_parameters | 82.9% | 99.9% | 3096 | 2569 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3080 | 2903 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3080 | 2994 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2917 | 2903 |
| extension:copy_extension | parameter:replacing_parameters | 88.9% | 99.9% | 3119 | 2775 |
| extension:move_extension | parameter:replacing_parameters | 88.8% | 99.9% | 3124 | 2775 |
| flow:extend_flow | flow:reuse_flow_parameters | 78.5% | 99.9% | 3268 | 2569 |
| flow:overwrite_flow | flow:reuse_flow_parameters | 78.7% | 99.9% | 3262 | 2569 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2780 | 2775 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.3% | 99.9% | 3105 | 2775 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 91.0% | 99.9% | 3047 | 2775 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.3% | 99.9% | 2793 | 2775 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.9% | 2775 | 2861 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 98.0% | 2775 | 2830 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 94.5% | 2773 | 2932 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.1% | 3114 | 3268 |
| alias:capture_flow_command | flow:overwrite_flow | 99.8% | 95.3% | 3114 | 3262 |
| alias:capture_partial_flow | flow:extend_flow | 99.8% | 94.5% | 3096 | 3268 |
| alias:capture_partial_flow | flow:overwrite_flow | 99.8% | 94.7% | 3096 | 3262 |
| command:invoked_commands_still_work_even_though_they_are_no_customizable | completion:completion_with_saved_parameter | 99.8% | 90.9% | 2806 | 3080 |
| command:invoked_commands_still_work_even_though_they_are_no_customizable | run:can_edit_parameters | 99.8% | 95.5% | 2806 | 2932 |
| completion:command | custom:group_python | 97.0% | 99.8% | 2984 | 2901 |
| completion:dynamic_command | custom:group_python | 95.9% | 99.8% | 3017 | 2901 |
| completion:dynamic_group | custom:group_python | 95.9% | 99.8% | 3017 | 2901 |
| ... | *2146 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| command:command | 3796 |
| help:main_help | 3648 |
| custom:capture_alias | 3594 |
| custom:cannot_remove_existing_command | 3399 |
| flow:dump_flowdeps | 3296 |
| flow:flow_to_subcommand_of_refactored_group | 3272 |
| flow:extend_flow | 3268 |
| flow:overwrite_flow | 3262 |
| extension:update_extension | 3258 |
| plugin:normal_use_case | 3240 |
| custom:default_help_message_triggers_a_warning | 3141 |
| alias:alias_overrides_parameters | 3126 |
| extension:move_extension | 3124 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | 3122 |
| extension:copy_extension | 3119 |
| alias:capture_flow_command | 3114 |
| alias:alias_conserves_parameters_of_group | 3113 |
| log:action | 3111 |
| custom:simple_bash | 3105 |
| parameter:parameter_precedence | 3105 |
| ... | *58 more tests* |
