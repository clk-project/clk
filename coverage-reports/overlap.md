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
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3183 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3183 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3192 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2491 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2491 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2500 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2501 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2491 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2491 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2500 |
| command:dynamic_option | alias:alias_overrides_parameters | 2501 |
| alias:composite_alias | alias:simple_alias_command | 2933 |
| alias:simple_alias_command | alias:composite_alias | 2933 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2491 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2491 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2491 |
| command:dynamic_default_value | command:dynamic_option | 2491 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2491 |
| command:dynamic_default_value_callback | command:dynamic_option | 2491 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2500 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2501 |
| completion:command | completion:completion_with_saved_parameter | 3041 |
| completion:command | completion:dynamic_command | 3041 |
| completion:command | completion:dynamic_group | 3041 |
| completion:command | completion:group | 3041 |
| completion:command | types:complete_date | 3041 |
| completion:command | types:suggestion | 3041 |
| custom:group_python | completion:completion_with_saved_parameter | 2957 |
| completion:dynamic_command | completion:dynamic_group | 3099 |
| completion:dynamic_group | completion:dynamic_command | 3099 |
| completion:group | completion:dynamic_command | 3091 |
| completion:group | completion:dynamic_group | 3091 |
| custom:group_python | custom:simple_python | 2957 |
| custom:group_python | types:date | 2957 |
| custom:group_python | types:default_with_converter | 2957 |
| custom:group_python | types:suggestion | 2957 |
| parameter:simple_parameter | extension:copy_extension | 2728 |
| parameter:simple_parameter | extension:move_extension | 2728 |
| flow:overwrite_flow | flow:extend_flow | 3311 |
| parameter:simple_parameter | parameter:appending_parameters | 2728 |
| parameter:appending_parameters | parameter:using_automatic_options | 2736 |
| parameter:simple_parameter | parameter:parameter_precedence | 2728 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2728 |
| parameter:simple_parameter | parameter:removing_parameters | 2728 |
| parameter:removing_parameters | parameter:using_automatic_options | 2750 |
| parameter:simple_parameter | parameter:replacing_parameters | 2728 |
| parameter:simple_parameter | parameter:using_automatic_options | 2728 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2728 |
| types:default_with_converter | types:date | 2959 |
| types:default_with_converter | types:suggestion | 2959 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3290 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2974 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3228 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3290 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3200 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3295 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2974 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3228 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3200 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2974 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2974 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3228 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3228 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3228 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3228 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3228 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3200 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3017 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3290 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3290 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3200 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3047 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3200 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3200 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3200 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3200 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3200 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3295 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.1% | 99.9% | 2997 | 2731 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 74.0% | 2997 | 4044 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.1% | 2997 | 3521 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3183 | 2852 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3192 | 2852 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3200 | 2852 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2933 | 3682 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2933 | 3521 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2933 | 3682 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2933 | 3521 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3137 | 2959 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3137 | 3051 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.4% | 3196 | 3971 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2973 | 2959 |
| extension:copy_extension | parameter:replacing_parameters | 85.8% | 99.9% | 3182 | 2731 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3194 | 2731 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2736 | 2731 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.0% | 99.9% | 3068 | 2731 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 3002 | 2731 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2750 | 2731 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2731 | 2832 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2731 | 2787 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2731 | 3521 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.4% | 2728 | 2981 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.4% | 2728 | 4044 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2728 | 3521 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.5% | 2974 | 4153 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.7% | 99.9% | 4153 | 3228 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3228 | 3200 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.2% | 99.9% | 3468 | 3200 |
| ... | *4561 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4554 |
| use_cases:use_case[bash_command_from_alias] | 4153 |
| use_cases:use_case[self_documentation] | 4143 |
| use_cases:use_case[3D_printing_flow] | 4044 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3971 |
| use_cases:use_case[creating_extensions] | 3968 |
| use_cases:use_case[setting_default_values] | 3812 |
| command:command | 3723 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3712 |
| use_cases:use_case[global_workflow_local_implementation] | 3682 |
| custom:capture_alias | 3571 |
| help:main_help | 3549 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3534 |
| use_cases:use_case[using_a_project] | 3521 |
| use_cases:use_case[bash_command_use_option] | 3468 |
| custom:cannot_remove_existing_command | 3464 |
| use_cases:use_case[ipfs_name_publish] | 3464 |
| use_cases:use_case[choices] | 3450 |
| use_cases:use_case[podcast_automation] | 3438 |
| use_cases:use_case[using_a_plugin] | 3426 |
| ... | *86 more tests* |
