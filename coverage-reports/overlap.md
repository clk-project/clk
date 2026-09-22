# Test Coverage Overlap Report

## Summary

- **Total tests:** 101
- **Full subsets (100%):** 26
- **High overlap (≥75%):** 3949
- **Significant overlap (≥50%):** 4079

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3061 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3061 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3070 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2338 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2338 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2347 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2338 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2338 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2347 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2338 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2338 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2338 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2338 |
| completion:command | completion:completion_with_saved_parameter | 2819 |
| completion:command | completion:dynamic_group | 2819 |
| completion:command | completion:group | 2819 |
| completion:command | types:complete_date | 2819 |
| completion:command | types:suggestion | 2819 |
| custom:group_python | completion:completion_with_saved_parameter | 2739 |
| completion:group | completion:dynamic_group | 2873 |
| custom:group_python | custom:simple_python | 2739 |
| custom:group_python | types:date | 2739 |
| custom:group_python | types:default_with_converter | 2739 |
| custom:group_python | types:suggestion | 2739 |
| parameter:removing_parameters | parameter:using_automatic_options | 2739 |
| types:default_with_converter | types:date | 2742 |
| types:default_with_converter | types:suggestion | 2742 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3061 | 2735 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3070 | 2735 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.8% | 99.9% | 3078 | 2735 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.3% | 99.9% | 3056 | 3038 |
| custom:simple_python | types:default_with_converter | 99.4% | 99.9% | 2755 | 2742 |
| extension:copy_extension | parameter:config_extension_overrides_global | 96.1% | 99.9% | 3100 | 2982 |
| extension:copy_extension | parameter:replacing_parameters | 87.7% | 99.9% | 3100 | 2720 |
| extension:move_extension | parameter:config_extension_overrides_global | 95.9% | 99.9% | 3109 | 2982 |
| extension:move_extension | parameter:replacing_parameters | 87.4% | 99.9% | 3109 | 2720 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 2982 | 3026 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 91.1% | 99.9% | 2982 | 2720 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.8% | 99.9% | 3026 | 2720 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.8% | 99.9% | 2992 | 2720 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2739 | 2720 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.6% | 2720 | 2814 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 98.2% | 2720 | 2769 |
| use_cases:use_case[controlling_the_audio] | use_cases:use_case[python_command] | 99.9% | 91.2% | 2851 | 3125 |
| use_cases:use_case[controlling_the_audio] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 99.9% | 68.9% | 2851 | 4133 |
| use_cases:use_case[global_workflow_local_implementation] | use_cases:use_case[using_a_project] | 99.9% | 88.9% | 3616 | 4063 |
| alias:can_use_a_flow_in_an_alias | flow:reuse_flow_parameters | 77.6% | 99.8% | 3138 | 2441 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.1% | 3056 | 3208 |
| alias:capture_partial_flow | flow:extend_flow | 99.8% | 94.5% | 3038 | 3208 |
| alias:capture_partial_flow | use_cases:use_case[3D_printing_flow] | 99.8% | 66.1% | 3038 | 4587 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.8% | 80.9% | 2931 | 3616 |
| alias:simple_alias_command | use_cases:use_case[podcast_automation] | 99.8% | 77.3% | 2931 | 3784 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.8% | 72.0% | 2931 | 4063 |
| command:invoked_commands_still_work_even_though_they_are_no_customizable | completion:completion_with_saved_parameter | 99.8% | 89.5% | 2735 | 3048 |
| command:invoked_commands_still_work_even_though_they_are_no_customizable | run:can_edit_parameters | 99.8% | 95.3% | 2735 | 2864 |
| completion:completion_with_saved_parameter | types:default_with_converter | 89.8% | 99.8% | 3048 | 2742 |
| completion:completion_with_saved_parameter | types:suggestion | 92.7% | 99.8% | 3048 | 2831 |
| ... | *3893 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[3D_printing_flow] | 4587 |
| use_cases:use_case[creating_extensions] | 4476 |
| use_cases:use_case[backing_up_documents] | 4320 |
| use_cases:use_case[controlling_my_music] | 4183 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 4133 |
| use_cases:use_case[using_a_project] | 4063 |
| use_cases:use_case[self_documentation] | 3973 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3883 |
| use_cases:use_case[podcast_automation] | 3784 |
| use_cases:use_case[setting_default_values] | 3631 |
| use_cases:use_case[global_workflow_local_implementation] | 3616 |
| command:command | 3599 |
| use_cases:use_case[using_a_plugin] | 3581 |
| use_cases:use_case[checking_my_server] | 3518 |
| custom:capture_alias | 3517 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3486 |
| use_cases:use_case[alias_to_root] | 3459 |
| use_cases:use_case[dealing_with_secrets] | 3381 |
| help:main_help | 3373 |
| custom:cannot_remove_existing_command | 3335 |
| ... | *81 more tests* |
