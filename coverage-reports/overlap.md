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
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2997 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2728 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3184 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3184 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3193 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2492 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2492 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2501 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2502 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2492 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2492 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2501 |
| command:dynamic_option | alias:alias_overrides_parameters | 2502 |
| alias:composite_alias | alias:simple_alias_command | 2933 |
| alias:simple_alias_command | alias:composite_alias | 2933 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2492 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2492 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2492 |
| command:dynamic_default_value | command:dynamic_option | 2492 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2492 |
| command:dynamic_default_value_callback | command:dynamic_option | 2492 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2501 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2502 |
| completion:command | completion:completion_with_saved_parameter | 3042 |
| completion:command | completion:dynamic_command | 3042 |
| completion:command | completion:dynamic_group | 3042 |
| completion:command | completion:group | 3042 |
| completion:command | types:complete_date | 3042 |
| completion:command | types:suggestion | 3042 |
| custom:group_python | completion:completion_with_saved_parameter | 2958 |
| completion:dynamic_command | completion:dynamic_group | 3100 |
| completion:dynamic_group | completion:dynamic_command | 3100 |
| completion:group | completion:dynamic_command | 3092 |
| completion:group | completion:dynamic_group | 3092 |
| custom:group_python | custom:simple_python | 2958 |
| custom:group_python | types:date | 2958 |
| custom:group_python | types:default_with_converter | 2958 |
| custom:group_python | types:suggestion | 2958 |
| parameter:simple_parameter | extension:copy_extension | 2728 |
| parameter:simple_parameter | extension:move_extension | 2728 |
| flow:overwrite_flow | flow:extend_flow | 3312 |
| parameter:simple_parameter | parameter:appending_parameters | 2728 |
| parameter:appending_parameters | parameter:using_automatic_options | 2736 |
| parameter:simple_parameter | parameter:parameter_precedence | 2728 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2728 |
| parameter:simple_parameter | parameter:removing_parameters | 2728 |
| parameter:removing_parameters | parameter:using_automatic_options | 2750 |
| parameter:simple_parameter | parameter:replacing_parameters | 2728 |
| parameter:simple_parameter | parameter:using_automatic_options | 2728 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2728 |
| types:default_with_converter | types:date | 2960 |
| types:default_with_converter | types:suggestion | 2960 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3291 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2975 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3229 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3291 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3201 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3296 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2975 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3229 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3201 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2975 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2975 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3229 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3229 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3229 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3229 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3229 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3201 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3018 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3291 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3291 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3201 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3048 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3201 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3201 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3201 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3201 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3201 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3296 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.1% | 99.9% | 2997 | 2731 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 74.0% | 2997 | 4045 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.0% | 2997 | 3522 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3184 | 2853 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3193 | 2853 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3201 | 2853 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2933 | 3683 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2933 | 3522 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2933 | 3683 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2933 | 3522 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3138 | 2960 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3138 | 3052 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.4% | 3197 | 3972 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2974 | 2960 |
| extension:copy_extension | parameter:replacing_parameters | 85.7% | 99.9% | 3183 | 2731 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3195 | 2731 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2736 | 2731 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.0% | 99.9% | 3068 | 2731 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 3002 | 2731 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2750 | 2731 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2731 | 2832 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2731 | 2787 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2731 | 3522 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.3% | 2728 | 2982 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.3% | 2728 | 4045 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2728 | 3522 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.5% | 2975 | 4154 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.7% | 99.9% | 4154 | 3229 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3229 | 3201 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.2% | 99.9% | 3469 | 3201 |
| ... | *4561 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4555 |
| use_cases:use_case[bash_command_from_alias] | 4154 |
| use_cases:use_case[self_documentation] | 4144 |
| use_cases:use_case[3D_printing_flow] | 4045 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3972 |
| use_cases:use_case[creating_extensions] | 3969 |
| use_cases:use_case[setting_default_values] | 3813 |
| command:command | 3723 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3713 |
| use_cases:use_case[global_workflow_local_implementation] | 3683 |
| custom:capture_alias | 3571 |
| help:main_help | 3549 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3535 |
| use_cases:use_case[using_a_project] | 3522 |
| use_cases:use_case[bash_command_use_option] | 3469 |
| custom:cannot_remove_existing_command | 3465 |
| use_cases:use_case[ipfs_name_publish] | 3465 |
| use_cases:use_case[choices] | 3451 |
| use_cases:use_case[podcast_automation] | 3439 |
| use_cases:use_case[using_a_plugin] | 3427 |
| ... | *86 more tests* |
