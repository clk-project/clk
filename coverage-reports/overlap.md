# Test Coverage Overlap Report

## Summary

- **Total tests:** 109
- **Full subsets (100%):** 87
- **High overlap (≥75%):** 4971
- **Significant overlap (≥50%):** 5114

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 3030 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2759 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3105 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3105 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3114 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2383 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2383 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2392 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2392 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2383 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2383 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2392 |
| command:dynamic_option | alias:alias_overrides_parameters | 2392 |
| alias:composite_alias | alias:simple_alias_command | 2966 |
| alias:simple_alias_command | alias:composite_alias | 2966 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2383 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2383 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2383 |
| command:dynamic_default_value | command:dynamic_option | 2383 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2383 |
| command:dynamic_default_value_callback | command:dynamic_option | 2383 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2392 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2392 |
| completion:command | completion:completion_with_saved_parameter | 3074 |
| completion:command | completion:dynamic_command | 3074 |
| completion:command | completion:dynamic_group | 3074 |
| completion:command | completion:group | 3074 |
| completion:command | types:complete_date | 3074 |
| completion:command | types:suggestion | 3074 |
| custom:group_python | completion:completion_with_saved_parameter | 2991 |
| completion:dynamic_command | completion:dynamic_group | 3128 |
| completion:dynamic_group | completion:dynamic_command | 3128 |
| completion:group | completion:dynamic_command | 3120 |
| completion:group | completion:dynamic_group | 3120 |
| custom:group_python | custom:simple_python | 2991 |
| custom:group_python | types:date | 2991 |
| custom:group_python | types:default_with_converter | 2991 |
| custom:group_python | types:suggestion | 2991 |
| parameter:simple_parameter | extension:copy_extension | 2759 |
| parameter:simple_parameter | extension:move_extension | 2759 |
| flow:overwrite_flow | flow:extend_flow | 3231 |
| parameter:simple_parameter | parameter:appending_parameters | 2759 |
| parameter:appending_parameters | parameter:using_automatic_options | 2767 |
| parameter:simple_parameter | parameter:config_extension_overrides_global | 2759 |
| parameter:simple_parameter | parameter:parameter_precedence | 2759 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2759 |
| parameter:simple_parameter | parameter:removing_parameters | 2759 |
| parameter:removing_parameters | parameter:using_automatic_options | 2781 |
| parameter:simple_parameter | parameter:replacing_parameters | 2759 |
| parameter:simple_parameter | parameter:using_automatic_options | 2759 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2759 |
| types:default_with_converter | types:date | 2993 |
| types:default_with_converter | types:suggestion | 2993 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3351 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 3024 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3297 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3351 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3282 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3361 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 3024 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3297 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3282 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[creating_extensions] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 3024 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3024 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3297 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3297 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3297 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3297 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3297 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3282 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3081 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3081 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3351 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3351 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3282 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3282 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3282 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3282 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3282 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3282 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3361 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.1% | 99.9% | 3030 | 2762 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 83.9% | 3030 | 3607 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3105 | 2777 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.1% | 99.9% | 3114 | 2777 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.9% | 99.9% | 3122 | 2777 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.4% | 99.9% | 3085 | 3067 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 78.9% | 2966 | 3756 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 82.1% | 2966 | 3607 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 78.9% | 2966 | 3756 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 82.1% | 2966 | 3607 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.3% | 99.9% | 3171 | 2993 |
| completion:completion_with_saved_parameter | types:suggestion | 97.2% | 99.9% | 3171 | 3085 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 3007 | 2993 |
| extension:copy_extension | parameter:config_extension_overrides_global | 95.0% | 99.9% | 3219 | 3059 |
| extension:copy_extension | parameter:replacing_parameters | 85.7% | 99.9% | 3219 | 2762 |
| extension:move_extension | parameter:config_extension_overrides_global | 94.6% | 99.9% | 3231 | 3059 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3231 | 2762 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2767 | 2762 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 3059 | 3103 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 90.2% | 99.9% | 3059 | 2762 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.9% | 99.9% | 3103 | 2762 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 3035 | 2762 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2781 | 2762 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2762 | 2863 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2762 | 2818 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 76.4% | 2759 | 3607 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 72.1% | 3024 | 4189 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 78.6% | 99.9% | 4189 | 3297 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.5% | 99.9% | 3297 | 3282 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.8% | 99.9% | 3535 | 3282 |
| ... | *4854 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4505 |
| use_cases:use_case[creating_extensions] | 4350 |
| use_cases:use_case[self_documentation] | 4208 |
| use_cases:use_case[bash_command_from_alias] | 4189 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 4123 |
| use_cases:use_case[3D_printing_flow] | 4103 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 4037 |
| use_cases:use_case[setting_default_values] | 3859 |
| use_cases:use_case[global_workflow_local_implementation] | 3756 |
| command:command | 3746 |
| use_cases:use_case[using_a_project] | 3607 |
| custom:capture_alias | 3601 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3601 |
| help:main_help | 3558 |
| use_cases:use_case[bash_command_use_option] | 3535 |
| use_cases:use_case[ipfs_name_publish] | 3535 |
| use_cases:use_case[choices] | 3519 |
| use_cases:use_case[podcast_automation] | 3504 |
| custom:cannot_remove_existing_command | 3501 |
| use_cases:use_case[using_a_plugin] | 3497 |
| ... | *89 more tests* |
