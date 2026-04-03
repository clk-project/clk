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
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3219 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3219 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3228 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2524 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2524 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2533 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2534 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2524 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2524 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2533 |
| command:dynamic_option | alias:alias_overrides_parameters | 2534 |
| alias:composite_alias | alias:simple_alias_command | 2967 |
| alias:simple_alias_command | alias:composite_alias | 2967 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2524 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2524 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2524 |
| command:dynamic_default_value | command:dynamic_option | 2524 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2524 |
| command:dynamic_default_value_callback | command:dynamic_option | 2524 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2533 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2534 |
| completion:command | completion:completion_with_saved_parameter | 3074 |
| completion:command | completion:dynamic_command | 3074 |
| completion:command | completion:dynamic_group | 3074 |
| completion:command | completion:group | 3074 |
| completion:command | types:complete_date | 3074 |
| completion:command | types:suggestion | 3074 |
| custom:group_python | completion:completion_with_saved_parameter | 2991 |
| completion:dynamic_command | completion:dynamic_group | 3132 |
| completion:dynamic_group | completion:dynamic_command | 3132 |
| completion:group | completion:dynamic_command | 3124 |
| completion:group | completion:dynamic_group | 3124 |
| custom:group_python | custom:simple_python | 2991 |
| custom:group_python | types:date | 2991 |
| custom:group_python | types:default_with_converter | 2991 |
| custom:group_python | types:suggestion | 2991 |
| parameter:simple_parameter | extension:copy_extension | 2760 |
| parameter:simple_parameter | extension:move_extension | 2760 |
| flow:overwrite_flow | flow:extend_flow | 3346 |
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
| types:default_with_converter | types:date | 2993 |
| types:default_with_converter | types:suggestion | 2993 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3353 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 3023 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3287 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3353 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3249 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3355 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 3023 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3287 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3249 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 3023 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3023 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3287 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3287 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3287 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3287 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3287 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3249 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3077 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3077 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3353 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3353 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3249 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3249 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3249 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3249 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3249 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3249 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3355 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.1% | 99.9% | 3031 | 2763 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 84.2% | 3031 | 3595 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3219 | 2885 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3228 | 2885 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.1% | 99.9% | 3236 | 2885 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.1% | 2967 | 3744 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 82.4% | 2967 | 3595 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.1% | 2967 | 3744 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 82.4% | 2967 | 3595 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.3% | 99.9% | 3171 | 2993 |
| completion:completion_with_saved_parameter | types:suggestion | 97.2% | 99.9% | 3171 | 3085 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 3007 | 2993 |
| extension:copy_extension | parameter:config_extension_overrides_global | 95.0% | 99.9% | 3219 | 3060 |
| extension:copy_extension | parameter:replacing_parameters | 85.8% | 99.9% | 3219 | 2763 |
| extension:move_extension | parameter:config_extension_overrides_global | 94.6% | 99.9% | 3231 | 3060 |
| extension:move_extension | parameter:replacing_parameters | 85.5% | 99.9% | 3231 | 2763 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2768 | 2763 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 3060 | 3104 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 90.2% | 99.9% | 3060 | 2763 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.9% | 99.9% | 3104 | 2763 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 3036 | 2763 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2782 | 2763 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2763 | 2864 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2763 | 2819 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.4% | 2760 | 3014 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 76.7% | 2760 | 3595 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.6% | 3023 | 4215 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.9% | 99.9% | 4215 | 3287 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 98.8% | 99.9% | 3287 | 3249 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.1% | 99.9% | 3527 | 3249 |
| ... | *4854 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4506 |
| use_cases:use_case[bash_command_from_alias] | 4215 |
| use_cases:use_case[self_documentation] | 4207 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 4121 |
| use_cases:use_case[3D_printing_flow] | 4107 |
| use_cases:use_case[creating_extensions] | 4035 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 4019 |
| use_cases:use_case[setting_default_values] | 3873 |
| command:command | 3755 |
| use_cases:use_case[global_workflow_local_implementation] | 3744 |
| custom:capture_alias | 3605 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3598 |
| use_cases:use_case[using_a_project] | 3595 |
| help:main_help | 3579 |
| use_cases:use_case[bash_command_use_option] | 3527 |
| use_cases:use_case[ipfs_name_publish] | 3523 |
| use_cases:use_case[choices] | 3511 |
| custom:cannot_remove_existing_command | 3501 |
| use_cases:use_case[podcast_automation] | 3501 |
| use_cases:use_case[using_a_plugin] | 3492 |
| ... | *89 more tests* |
