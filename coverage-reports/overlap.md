# Test Coverage Overlap Report

## Summary

- **Total tests:** 109
- **Full subsets (100%):** 86
- **High overlap (≥75%):** 4970
- **Significant overlap (≥50%):** 5177

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 3031 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2760 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3218 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3218 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3227 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2523 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2523 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2532 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2533 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2523 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2523 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2532 |
| command:dynamic_option | alias:alias_overrides_parameters | 2533 |
| alias:composite_alias | alias:simple_alias_command | 2967 |
| alias:simple_alias_command | alias:composite_alias | 2967 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2523 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2523 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2523 |
| command:dynamic_default_value | command:dynamic_option | 2523 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2523 |
| command:dynamic_default_value_callback | command:dynamic_option | 2523 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2532 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2533 |
| completion:command | completion:completion_with_saved_parameter | 3073 |
| completion:command | completion:dynamic_command | 3073 |
| completion:command | completion:dynamic_group | 3073 |
| completion:command | completion:group | 3073 |
| completion:command | types:complete_date | 3073 |
| completion:command | types:suggestion | 3073 |
| custom:group_python | completion:completion_with_saved_parameter | 2990 |
| completion:dynamic_command | completion:dynamic_group | 3131 |
| completion:dynamic_group | completion:dynamic_command | 3131 |
| completion:group | completion:dynamic_command | 3123 |
| completion:group | completion:dynamic_group | 3123 |
| custom:group_python | custom:simple_python | 2990 |
| custom:group_python | types:date | 2990 |
| custom:group_python | types:default_with_converter | 2990 |
| custom:group_python | types:suggestion | 2990 |
| parameter:simple_parameter | extension:copy_extension | 2760 |
| parameter:simple_parameter | extension:move_extension | 2760 |
| flow:overwrite_flow | flow:extend_flow | 3345 |
| parameter:simple_parameter | parameter:appending_parameters | 2760 |
| parameter:appending_parameters | parameter:using_automatic_options | 2768 |
| parameter:simple_parameter | parameter:config_extension_overrides_global | 2760 |
| parameter:simple_parameter | parameter:parameter_precedence | 2760 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2760 |
| parameter:simple_parameter | parameter:removing_parameters | 2760 |
| parameter:removing_parameters | parameter:using_automatic_options | 2782 |
| parameter:simple_parameter | parameter:replacing_parameters | 2760 |
| parameter:simple_parameter | parameter:using_automatic_options | 2760 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2760 |
| types:default_with_converter | types:date | 2992 |
| types:default_with_converter | types:suggestion | 2992 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3351 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 3021 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3285 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3351 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3247 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3353 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 3021 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3285 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3247 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 3021 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3021 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3285 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3285 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3285 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3285 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3285 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3247 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3075 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3075 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3351 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3351 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3247 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3247 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3247 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3247 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3247 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3247 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3353 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.1% | 99.9% | 3031 | 2763 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 84.2% | 3031 | 3593 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3218 | 2884 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3227 | 2884 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.1% | 99.9% | 3235 | 2884 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.2% | 2967 | 3742 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 82.5% | 2967 | 3593 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.2% | 2967 | 3742 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 82.5% | 2967 | 3593 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.3% | 99.9% | 3170 | 2992 |
| completion:completion_with_saved_parameter | types:suggestion | 97.2% | 99.9% | 3170 | 3084 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 3006 | 2992 |
| extension:copy_extension | parameter:config_extension_overrides_global | 95.0% | 99.9% | 3218 | 3060 |
| extension:copy_extension | parameter:replacing_parameters | 85.8% | 99.9% | 3218 | 2763 |
| extension:move_extension | parameter:config_extension_overrides_global | 94.7% | 99.9% | 3230 | 3060 |
| extension:move_extension | parameter:replacing_parameters | 85.5% | 99.9% | 3230 | 2763 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2768 | 2763 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 3060 | 3104 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 90.2% | 99.9% | 3060 | 2763 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.9% | 99.9% | 3104 | 2763 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 3036 | 2763 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2782 | 2763 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2763 | 2864 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2763 | 2819 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.5% | 2760 | 3013 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 76.7% | 2760 | 3593 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.6% | 3021 | 4213 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.9% | 99.9% | 4213 | 3285 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 98.8% | 99.9% | 3285 | 3247 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.1% | 99.9% | 3525 | 3247 |
| ... | *4854 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4504 |
| use_cases:use_case[bash_command_from_alias] | 4213 |
| use_cases:use_case[self_documentation] | 4205 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 4119 |
| use_cases:use_case[3D_printing_flow] | 4105 |
| use_cases:use_case[creating_extensions] | 4033 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 4017 |
| use_cases:use_case[setting_default_values] | 3871 |
| command:command | 3755 |
| use_cases:use_case[global_workflow_local_implementation] | 3742 |
| custom:capture_alias | 3605 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3596 |
| use_cases:use_case[using_a_project] | 3593 |
| help:main_help | 3579 |
| use_cases:use_case[bash_command_use_option] | 3525 |
| use_cases:use_case[ipfs_name_publish] | 3521 |
| use_cases:use_case[choices] | 3509 |
| custom:cannot_remove_existing_command | 3500 |
| use_cases:use_case[podcast_automation] | 3499 |
| use_cases:use_case[using_a_plugin] | 3490 |
| ... | *89 more tests* |
