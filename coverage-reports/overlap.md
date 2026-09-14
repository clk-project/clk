# Test Coverage Overlap Report

## Summary

- **Total tests:** 110
- **Full subsets (100%):** 87
- **High overlap (≥75%):** 4972
- **Significant overlap (≥50%):** 5114

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2986 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2712 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3061 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3061 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3070 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2336 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2336 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2345 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2345 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2336 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2336 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2345 |
| command:dynamic_option | alias:alias_overrides_parameters | 2345 |
| alias:composite_alias | alias:simple_alias_command | 2922 |
| alias:simple_alias_command | alias:composite_alias | 2922 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2336 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2336 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2336 |
| command:dynamic_default_value | command:dynamic_option | 2336 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2336 |
| command:dynamic_default_value_callback | command:dynamic_option | 2336 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2345 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2345 |
| completion:command | completion:completion_with_saved_parameter | 2968 |
| completion:command | completion:dynamic_command | 2968 |
| completion:command | completion:dynamic_group | 2968 |
| completion:command | completion:group | 2968 |
| completion:command | types:complete_date | 2968 |
| completion:command | types:suggestion | 2968 |
| custom:group_python | completion:completion_with_saved_parameter | 2885 |
| completion:dynamic_command | completion:dynamic_group | 3022 |
| completion:dynamic_group | completion:dynamic_command | 3022 |
| completion:group | completion:dynamic_command | 3014 |
| completion:group | completion:dynamic_group | 3014 |
| custom:group_python | custom:simple_python | 2885 |
| custom:group_python | types:date | 2885 |
| custom:group_python | types:default_with_converter | 2885 |
| custom:group_python | types:suggestion | 2885 |
| parameter:simple_parameter | extension:copy_extension | 2712 |
| parameter:simple_parameter | extension:move_extension | 2712 |
| flow:overwrite_flow | flow:extend_flow | 3187 |
| parameter:simple_parameter | parameter:appending_parameters | 2712 |
| parameter:appending_parameters | parameter:using_automatic_options | 2720 |
| parameter:simple_parameter | parameter:config_extension_overrides_global | 2712 |
| parameter:simple_parameter | parameter:parameter_precedence | 2712 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2712 |
| parameter:simple_parameter | parameter:removing_parameters | 2712 |
| parameter:removing_parameters | parameter:using_automatic_options | 2734 |
| parameter:simple_parameter | parameter:replacing_parameters | 2712 |
| parameter:simple_parameter | parameter:using_automatic_options | 2712 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2712 |
| types:default_with_converter | types:date | 2887 |
| types:default_with_converter | types:suggestion | 2887 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3240 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2910 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3183 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3240 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3168 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3247 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2910 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3183 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3168 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[creating_extensions] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2910 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2910 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3183 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3183 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3183 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3183 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3183 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3168 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 2967 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2967 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3240 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3240 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3168 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3168 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3168 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3168 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3168 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3168 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3247 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 90.9% | 99.9% | 2986 | 2715 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.2% | 2986 | 3502 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.1% | 99.9% | 3061 | 2730 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.8% | 99.9% | 3070 | 2730 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.6% | 99.9% | 3078 | 2730 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.3% | 99.9% | 3041 | 3023 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 80.1% | 2922 | 3644 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2922 | 3502 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 80.1% | 2922 | 3644 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2922 | 3502 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.1% | 99.9% | 3065 | 2887 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3065 | 2979 |
| custom:simple_python | types:default_with_converter | 99.4% | 99.9% | 2901 | 2887 |
| extension:copy_extension | parameter:config_extension_overrides_global | 96.5% | 99.9% | 3095 | 2989 |
| extension:copy_extension | parameter:replacing_parameters | 87.7% | 99.9% | 3095 | 2715 |
| extension:move_extension | parameter:config_extension_overrides_global | 96.2% | 99.9% | 3106 | 2989 |
| extension:move_extension | parameter:replacing_parameters | 87.3% | 99.9% | 3106 | 2715 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2720 | 2715 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 2989 | 3033 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 90.8% | 99.9% | 2989 | 2715 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.4% | 99.9% | 3033 | 2715 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.7% | 99.9% | 2991 | 2715 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2734 | 2715 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.3% | 2715 | 2816 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2715 | 2771 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.3% | 2712 | 3502 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.2% | 2910 | 4085 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.8% | 99.9% | 4085 | 3183 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.5% | 99.9% | 3183 | 3168 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.4% | 99.9% | 3427 | 3168 |
| ... | *4855 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4370 |
| use_cases:use_case[creating_extensions] | 4226 |
| use_cases:use_case[bash_command_from_alias] | 4085 |
| use_cases:use_case[self_documentation] | 4074 |
| use_cases:use_case[3D_printing_flow] | 3992 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3984 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3928 |
| use_cases:use_case[setting_default_values] | 3733 |
| command:command | 3674 |
| use_cases:use_case[global_workflow_local_implementation] | 3644 |
| custom:capture_alias | 3552 |
| use_cases:use_case[using_a_project] | 3502 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3490 |
| help:main_help | 3486 |
| use_cases:use_case[alias_to_root] | 3439 |
| use_cases:use_case[bash_command_use_option] | 3427 |
| use_cases:use_case[ipfs_name_publish] | 3421 |
| use_cases:use_case[choices] | 3405 |
| use_cases:use_case[podcast_automation] | 3393 |
| use_cases:use_case[using_a_plugin] | 3392 |
| ... | *90 more tests* |
