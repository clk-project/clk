# Test Coverage Overlap Report

## Summary

- **Total tests:** 107
- **Full subsets (100%):** 86
- **High overlap (≥75%):** 4773
- **Significant overlap (≥50%):** 4978

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 3009 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2738 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3196 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3196 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3205 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2501 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2501 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2510 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2511 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2501 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2501 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2510 |
| command:dynamic_option | alias:alias_overrides_parameters | 2511 |
| alias:composite_alias | alias:simple_alias_command | 2945 |
| alias:simple_alias_command | alias:composite_alias | 2945 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2501 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2501 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2501 |
| command:dynamic_default_value | command:dynamic_option | 2501 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2501 |
| command:dynamic_default_value_callback | command:dynamic_option | 2501 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2510 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2511 |
| completion:command | completion:completion_with_saved_parameter | 3052 |
| completion:command | completion:dynamic_command | 3052 |
| completion:command | completion:dynamic_group | 3052 |
| completion:command | completion:group | 3052 |
| completion:command | types:complete_date | 3052 |
| completion:command | types:suggestion | 3052 |
| custom:group_python | completion:completion_with_saved_parameter | 2968 |
| completion:dynamic_command | completion:dynamic_group | 3110 |
| completion:dynamic_group | completion:dynamic_command | 3110 |
| completion:group | completion:dynamic_command | 3102 |
| completion:group | completion:dynamic_group | 3102 |
| custom:group_python | custom:simple_python | 2968 |
| custom:group_python | types:date | 2968 |
| custom:group_python | types:default_with_converter | 2968 |
| custom:group_python | types:suggestion | 2968 |
| parameter:simple_parameter | extension:copy_extension | 2738 |
| parameter:simple_parameter | extension:move_extension | 2738 |
| flow:overwrite_flow | flow:extend_flow | 3323 |
| parameter:simple_parameter | parameter:appending_parameters | 2738 |
| parameter:appending_parameters | parameter:using_automatic_options | 2746 |
| parameter:simple_parameter | parameter:parameter_precedence | 2738 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2738 |
| parameter:simple_parameter | parameter:removing_parameters | 2738 |
| parameter:removing_parameters | parameter:using_automatic_options | 2760 |
| parameter:simple_parameter | parameter:replacing_parameters | 2738 |
| parameter:simple_parameter | parameter:using_automatic_options | 2738 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2738 |
| types:default_with_converter | types:date | 2970 |
| types:default_with_converter | types:suggestion | 2970 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3303 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2984 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3238 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3303 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3210 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3306 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2984 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3238 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3210 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2984 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2984 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3238 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3238 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3238 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3238 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3238 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3210 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3028 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3028 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3303 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3303 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3210 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3058 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3210 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3210 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3210 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3210 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3210 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3306 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.0% | 99.9% | 3009 | 2741 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 74.1% | 3009 | 4057 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.1% | 3009 | 3533 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3196 | 2862 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.2% | 99.9% | 3205 | 2862 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3213 | 2862 |
| alias:alias_to_clk | use_cases:use_case[alias_to_root] | 99.9% | 88.8% | 2977 | 3350 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.7% | 2945 | 3694 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2945 | 3533 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.7% | 2945 | 3694 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2945 | 3533 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.3% | 99.9% | 3148 | 2970 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3148 | 3062 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.4% | 3207 | 3985 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2984 | 2970 |
| extension:copy_extension | parameter:replacing_parameters | 85.7% | 99.9% | 3195 | 2741 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3207 | 2741 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2746 | 2741 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.9% | 99.9% | 3081 | 2741 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 3014 | 2741 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2760 | 2741 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2741 | 2842 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2741 | 2797 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.5% | 2741 | 3533 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.4% | 2738 | 2991 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.4% | 2738 | 4057 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2738 | 3533 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.6% | 2984 | 4165 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.7% | 99.9% | 4165 | 3238 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3238 | 3210 |
| ... | *4657 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4456 |
| use_cases:use_case[bash_command_from_alias] | 4165 |
| use_cases:use_case[self_documentation] | 4156 |
| use_cases:use_case[3D_printing_flow] | 4057 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3985 |
| use_cases:use_case[creating_extensions] | 3984 |
| use_cases:use_case[setting_default_values] | 3823 |
| command:command | 3733 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3733 |
| use_cases:use_case[global_workflow_local_implementation] | 3694 |
| custom:capture_alias | 3583 |
| help:main_help | 3559 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3548 |
| use_cases:use_case[using_a_project] | 3533 |
| use_cases:use_case[bash_command_use_option] | 3478 |
| custom:cannot_remove_existing_command | 3477 |
| use_cases:use_case[ipfs_name_publish] | 3474 |
| use_cases:use_case[choices] | 3461 |
| use_cases:use_case[podcast_automation] | 3451 |
| use_cases:use_case[using_a_plugin] | 3438 |
| ... | *87 more tests* |
