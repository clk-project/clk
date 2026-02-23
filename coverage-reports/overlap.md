# Test Coverage Overlap Report

## Summary

- **Total tests:** 105
- **Full subsets (100%):** 80
- **High overlap (≥75%):** 4578
- **Significant overlap (≥50%):** 4778

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2986 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2717 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3172 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3172 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3181 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2482 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2482 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2491 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2492 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2482 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2482 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2491 |
| command:dynamic_option | alias:alias_overrides_parameters | 2492 |
| alias:composite_alias | alias:simple_alias_command | 2922 |
| alias:simple_alias_command | alias:composite_alias | 2922 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2482 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2482 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2482 |
| command:dynamic_default_value | command:dynamic_option | 2482 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2482 |
| command:dynamic_default_value_callback | command:dynamic_option | 2482 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2491 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2492 |
| completion:command | completion:completion_with_saved_parameter | 3030 |
| completion:command | completion:dynamic_command | 3030 |
| completion:command | completion:dynamic_group | 3030 |
| completion:command | completion:group | 3030 |
| completion:command | types:complete_date | 3030 |
| completion:command | types:suggestion | 3030 |
| custom:group_python | completion:completion_with_saved_parameter | 2946 |
| completion:dynamic_command | completion:dynamic_group | 3088 |
| completion:dynamic_group | completion:dynamic_command | 3088 |
| completion:group | completion:dynamic_command | 3080 |
| completion:group | completion:dynamic_group | 3080 |
| custom:group_python | custom:simple_python | 2946 |
| custom:group_python | types:date | 2946 |
| custom:group_python | types:default_with_converter | 2946 |
| custom:group_python | types:suggestion | 2946 |
| parameter:simple_parameter | extension:copy_extension | 2717 |
| parameter:simple_parameter | extension:move_extension | 2717 |
| flow:overwrite_flow | flow:extend_flow | 3300 |
| parameter:simple_parameter | parameter:appending_parameters | 2717 |
| parameter:appending_parameters | parameter:using_automatic_options | 2725 |
| parameter:simple_parameter | parameter:parameter_precedence | 2717 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2717 |
| parameter:simple_parameter | parameter:removing_parameters | 2717 |
| parameter:removing_parameters | parameter:using_automatic_options | 2739 |
| parameter:simple_parameter | parameter:replacing_parameters | 2717 |
| parameter:simple_parameter | parameter:using_automatic_options | 2717 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2717 |
| types:default_with_converter | types:date | 2948 |
| types:default_with_converter | types:suggestion | 2948 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3274 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2960 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3210 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3183 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2960 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2960 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3210 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3210 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3210 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3210 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3210 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3183 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3002 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3274 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3274 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3183 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3032 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3183 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3183 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3183 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3183 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3183 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3277 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.0% | 99.9% | 2986 | 2720 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 74.0% | 2986 | 4029 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.2% | 2986 | 3504 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3172 | 2841 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.2% | 99.9% | 3181 | 2841 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3189 | 2841 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.7% | 2922 | 3664 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2922 | 3504 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.7% | 2922 | 3664 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2922 | 3504 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3126 | 2948 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3126 | 3040 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.4% | 3182 | 3953 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2962 | 2948 |
| extension:copy_extension | parameter:replacing_parameters | 85.7% | 99.9% | 3171 | 2720 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3183 | 2720 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2725 | 2720 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.9% | 99.9% | 3057 | 2720 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 2991 | 2720 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2739 | 2720 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.5% | 2720 | 2816 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2720 | 2776 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.5% | 2720 | 3504 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.3% | 2717 | 2970 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.3% | 2717 | 4029 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.5% | 2717 | 3504 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 73.4% | 2960 | 4031 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 79.6% | 99.9% | 4031 | 3210 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3210 | 3183 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.4% | 99.9% | 3444 | 3183 |
| ... | *4468 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[self_documentation] | 4125 |
| use_cases:use_case[bash_command_from_alias] | 4031 |
| use_cases:use_case[3D_printing_flow] | 4029 |
| use_cases:use_case[creating_extensions] | 3953 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3953 |
| use_cases:use_case[setting_default_values] | 3797 |
| command:command | 3712 |
| use_cases:use_case[global_workflow_local_implementation] | 3664 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3583 |
| custom:capture_alias | 3557 |
| help:main_help | 3538 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3519 |
| use_cases:use_case[using_a_project] | 3504 |
| custom:cannot_remove_existing_command | 3450 |
| use_cases:use_case[ipfs_name_publish] | 3446 |
| use_cases:use_case[bash_command_use_option] | 3444 |
| use_cases:use_case[choices] | 3432 |
| use_cases:use_case[podcast_automation] | 3423 |
| use_cases:use_case[using_a_plugin] | 3411 |
| use_cases:use_case[dealing_with_secrets] | 3401 |
| ... | *85 more tests* |
