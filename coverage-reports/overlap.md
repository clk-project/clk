# Test Coverage Overlap Report

## Summary

- **Total tests:** 106
- **Full subsets (100%):** 85
- **High overlap (≥75%):** 4676
- **Significant overlap (≥50%):** 4879

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2994 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2725 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3181 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3181 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3190 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2489 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2489 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2498 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2499 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2489 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2489 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2498 |
| command:dynamic_option | alias:alias_overrides_parameters | 2499 |
| alias:composite_alias | alias:simple_alias_command | 2930 |
| alias:simple_alias_command | alias:composite_alias | 2930 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2489 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2489 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2489 |
| command:dynamic_default_value | command:dynamic_option | 2489 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2489 |
| command:dynamic_default_value_callback | command:dynamic_option | 2489 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2498 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2499 |
| completion:command | completion:completion_with_saved_parameter | 3039 |
| completion:command | completion:dynamic_command | 3039 |
| completion:command | completion:dynamic_group | 3039 |
| completion:command | completion:group | 3039 |
| completion:command | types:complete_date | 3039 |
| completion:command | types:suggestion | 3039 |
| custom:group_python | completion:completion_with_saved_parameter | 2955 |
| completion:dynamic_command | completion:dynamic_group | 3097 |
| completion:dynamic_group | completion:dynamic_command | 3097 |
| completion:group | completion:dynamic_command | 3089 |
| completion:group | completion:dynamic_group | 3089 |
| custom:group_python | custom:simple_python | 2955 |
| custom:group_python | types:date | 2955 |
| custom:group_python | types:default_with_converter | 2955 |
| custom:group_python | types:suggestion | 2955 |
| parameter:simple_parameter | extension:copy_extension | 2725 |
| parameter:simple_parameter | extension:move_extension | 2725 |
| flow:overwrite_flow | flow:extend_flow | 3309 |
| parameter:simple_parameter | parameter:appending_parameters | 2725 |
| parameter:appending_parameters | parameter:using_automatic_options | 2733 |
| parameter:simple_parameter | parameter:parameter_precedence | 2725 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2725 |
| parameter:simple_parameter | parameter:removing_parameters | 2725 |
| parameter:removing_parameters | parameter:using_automatic_options | 2747 |
| parameter:simple_parameter | parameter:replacing_parameters | 2725 |
| parameter:simple_parameter | parameter:using_automatic_options | 2725 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2725 |
| types:default_with_converter | types:date | 2957 |
| types:default_with_converter | types:suggestion | 2957 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3288 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2972 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3225 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3288 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3197 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3292 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2972 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3225 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3197 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2972 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2972 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3225 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3225 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3225 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3225 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3225 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3197 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3015 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3288 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3288 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3197 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3045 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3197 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3197 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3197 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3197 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3197 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3292 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.0% | 99.9% | 2994 | 2728 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 74.0% | 2994 | 4042 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.0% | 2994 | 3519 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3181 | 2850 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.2% | 99.9% | 3190 | 2850 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3198 | 2850 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2930 | 3679 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2930 | 3519 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2930 | 3679 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2930 | 3519 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3135 | 2957 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3135 | 3049 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.4% | 3193 | 3968 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2971 | 2957 |
| extension:copy_extension | parameter:replacing_parameters | 85.7% | 99.9% | 3180 | 2728 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3192 | 2728 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2733 | 2728 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.9% | 99.9% | 3065 | 2728 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 2999 | 2728 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2747 | 2728 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2728 | 2829 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2728 | 2784 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2728 | 3519 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.3% | 2725 | 2979 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.3% | 2725 | 4042 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2725 | 3519 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.5% | 2972 | 4150 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.6% | 99.9% | 4150 | 3225 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3225 | 3197 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.3% | 99.9% | 3462 | 3197 |
| ... | *4561 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4551 |
| use_cases:use_case[bash_command_from_alias] | 4150 |
| use_cases:use_case[self_documentation] | 4140 |
| use_cases:use_case[3D_printing_flow] | 4042 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3968 |
| use_cases:use_case[creating_extensions] | 3966 |
| use_cases:use_case[setting_default_values] | 3810 |
| command:command | 3720 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3709 |
| use_cases:use_case[global_workflow_local_implementation] | 3679 |
| custom:capture_alias | 3567 |
| help:main_help | 3546 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3532 |
| use_cases:use_case[using_a_project] | 3519 |
| use_cases:use_case[bash_command_use_option] | 3462 |
| custom:cannot_remove_existing_command | 3461 |
| use_cases:use_case[ipfs_name_publish] | 3461 |
| use_cases:use_case[choices] | 3447 |
| use_cases:use_case[podcast_automation] | 3436 |
| use_cases:use_case[using_a_plugin] | 3424 |
| ... | *86 more tests* |
