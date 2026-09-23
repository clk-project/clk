# Test Coverage Overlap Report

## Summary

- **Total tests:** 101
- **Full subsets (100%):** 22
- **High overlap (≥75%):** 3948
- **Significant overlap (≥50%):** 4081

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3061 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3061 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3070 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2339 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2348 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2339 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2348 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2339 |
| completion:command | completion:completion_with_saved_parameter | 2821 |
| completion:command | completion:dynamic_group | 2821 |
| completion:command | completion:group | 2821 |
| completion:command | types:complete_date | 2821 |
| completion:command | types:suggestion | 2821 |
| custom:group_python | completion:completion_with_saved_parameter | 2741 |
| completion:group | completion:dynamic_group | 2875 |
| custom:group_python | custom:simple_python | 2741 |
| custom:group_python | types:date | 2741 |
| custom:group_python | types:default_with_converter | 2741 |
| custom:group_python | types:suggestion | 2741 |
| parameter:removing_parameters | parameter:using_automatic_options | 2739 |
| types:default_with_converter | types:date | 2743 |
| types:default_with_converter | types:suggestion | 2743 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3061 | 2735 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3070 | 2735 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.8% | 99.9% | 3078 | 2735 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.3% | 99.9% | 3056 | 3038 |
| completion:completion_with_saved_parameter | types:default_with_converter | 89.8% | 99.9% | 3050 | 2743 |
| completion:completion_with_saved_parameter | types:suggestion | 92.7% | 99.9% | 3050 | 2832 |
| custom:simple_python | types:default_with_converter | 99.4% | 99.9% | 2757 | 2743 |
| extension:copy_extension | parameter:config_extension_overrides_global | 96.1% | 99.9% | 3102 | 2982 |
| extension:copy_extension | parameter:replacing_parameters | 87.6% | 99.9% | 3102 | 2720 |
| extension:move_extension | parameter:config_extension_overrides_global | 95.8% | 99.9% | 3111 | 2982 |
| extension:move_extension | parameter:replacing_parameters | 87.4% | 99.9% | 3111 | 2720 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 2982 | 3026 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 91.1% | 99.9% | 2982 | 2720 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.8% | 99.9% | 3026 | 2720 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.8% | 99.9% | 2992 | 2720 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2739 | 2720 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.6% | 2720 | 2814 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 98.2% | 2720 | 2769 |
| use_cases:use_case[controlling_the_audio] | use_cases:use_case[python_command] | 99.9% | 91.2% | 2853 | 3127 |
| use_cases:use_case[controlling_the_audio] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 99.9% | 68.9% | 2853 | 4135 |
| use_cases:use_case[global_workflow_local_implementation] | use_cases:use_case[using_a_project] | 99.9% | 88.9% | 3618 | 4065 |
| alias:can_use_a_flow_in_an_alias | flow:reuse_flow_parameters | 77.7% | 99.8% | 3138 | 2442 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.1% | 3056 | 3208 |
| alias:capture_partial_flow | flow:extend_flow | 99.8% | 94.5% | 3038 | 3208 |
| alias:capture_partial_flow | use_cases:use_case[3D_printing_flow] | 99.8% | 66.1% | 3038 | 4589 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.8% | 80.9% | 2931 | 3618 |
| alias:simple_alias_command | use_cases:use_case[podcast_automation] | 99.8% | 77.3% | 2931 | 3786 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.8% | 72.0% | 2931 | 4065 |
| command:invoked_commands_still_work_even_though_they_are_no_customizable | completion:completion_with_saved_parameter | 99.8% | 89.5% | 2735 | 3050 |
| command:invoked_commands_still_work_even_though_they_are_no_customizable | run:can_edit_parameters | 99.8% | 95.3% | 2735 | 2864 |
| ... | *3896 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[3D_printing_flow] | 4589 |
| use_cases:use_case[creating_extensions] | 4478 |
| use_cases:use_case[backing_up_documents] | 4322 |
| use_cases:use_case[controlling_my_music] | 4185 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 4135 |
| use_cases:use_case[using_a_project] | 4065 |
| use_cases:use_case[self_documentation] | 3973 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3884 |
| use_cases:use_case[podcast_automation] | 3786 |
| use_cases:use_case[setting_default_values] | 3631 |
| use_cases:use_case[global_workflow_local_implementation] | 3618 |
| command:command | 3599 |
| use_cases:use_case[using_a_plugin] | 3583 |
| use_cases:use_case[checking_my_server] | 3520 |
| custom:capture_alias | 3517 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3488 |
| use_cases:use_case[alias_to_root] | 3459 |
| use_cases:use_case[dealing_with_secrets] | 3383 |
| help:main_help | 3373 |
| custom:cannot_remove_existing_command | 3337 |
| ... | *81 more tests* |
