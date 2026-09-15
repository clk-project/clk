# Test Coverage Overlap Report

## Summary

- **Total tests:** 109
- **Full subsets (100%):** 89
- **High overlap (≥75%):** 4875
- **Significant overlap (≥50%):** 5003

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2981 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2707 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3056 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3056 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3065 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2338 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2338 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2347 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2347 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2338 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2338 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2347 |
| command:dynamic_option | alias:alias_overrides_parameters | 2347 |
| alias:composite_alias | alias:simple_alias_command | 2924 |
| alias:simple_alias_command | alias:composite_alias | 2924 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2338 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2338 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2338 |
| command:dynamic_default_value | command:dynamic_option | 2338 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2338 |
| command:dynamic_default_value_callback | command:dynamic_option | 2338 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2347 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2347 |
| completion:command | completion:completion_with_saved_parameter | 2961 |
| completion:command | completion:dynamic_command | 2961 |
| completion:command | completion:dynamic_group | 2961 |
| completion:command | completion:group | 2961 |
| completion:command | types:complete_date | 2961 |
| completion:command | types:suggestion | 2961 |
| custom:group_python | completion:completion_with_saved_parameter | 2881 |
| completion:dynamic_command | completion:dynamic_group | 3015 |
| completion:dynamic_group | completion:dynamic_command | 3015 |
| completion:group | completion:dynamic_command | 3007 |
| completion:group | completion:dynamic_group | 3007 |
| custom:group_python | custom:simple_python | 2881 |
| custom:group_python | types:date | 2881 |
| custom:group_python | types:default_with_converter | 2881 |
| custom:group_python | types:suggestion | 2881 |
| parameter:simple_parameter | extension:copy_extension | 2707 |
| parameter:simple_parameter | extension:move_extension | 2707 |
| flow:overwrite_flow | flow:extend_flow | 3189 |
| parameter:simple_parameter | parameter:config_extension_overrides_global | 2707 |
| parameter:simple_parameter | parameter:parameter_precedence | 2707 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2707 |
| parameter:simple_parameter | parameter:removing_parameters | 2707 |
| parameter:removing_parameters | parameter:using_automatic_options | 2729 |
| parameter:simple_parameter | parameter:replacing_parameters | 2707 |
| parameter:simple_parameter | parameter:using_automatic_options | 2707 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2707 |
| types:default_with_converter | types:date | 2883 |
| types:default_with_converter | types:suggestion | 2883 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3237 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2841 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3179 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3237 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3165 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3244 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2841 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3179 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3165 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[creating_extensions] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[using_a_project] | 2841 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2841 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3179 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3179 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3179 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3179 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[using_a_project] | 3179 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3179 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3165 |
| use_cases:use_case[hello_world] | use_cases:use_case[creating_extensions] | 3165 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 2964 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2964 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3237 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3237 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3165 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3165 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3165 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3165 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3165 |
| use_cases:use_case[hello_world] | use_cases:use_case[using_a_project] | 3165 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3165 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3244 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 90.8% | 99.9% | 2981 | 2710 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.1% | 99.9% | 3056 | 2725 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.8% | 99.9% | 3065 | 2725 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.6% | 99.9% | 3073 | 2725 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.3% | 99.9% | 3043 | 3025 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.4% | 99.9% | 3051 | 2883 |
| completion:completion_with_saved_parameter | types:suggestion | 97.3% | 99.9% | 3051 | 2972 |
| custom:simple_python | types:default_with_converter | 99.4% | 99.9% | 2897 | 2883 |
| extension:copy_extension | parameter:config_extension_overrides_global | 96.6% | 99.9% | 3087 | 2984 |
| extension:copy_extension | parameter:replacing_parameters | 87.7% | 99.9% | 3087 | 2710 |
| extension:move_extension | parameter:config_extension_overrides_global | 96.3% | 99.9% | 3098 | 2984 |
| extension:move_extension | parameter:replacing_parameters | 87.4% | 99.9% | 3098 | 2710 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 2984 | 3028 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 90.8% | 99.9% | 2984 | 2710 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.4% | 99.9% | 3028 | 2710 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.7% | 99.9% | 2986 | 2710 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2729 | 2710 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.6% | 2710 | 2804 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2710 | 2766 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 70.5% | 2841 | 4027 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.5% | 99.9% | 3179 | 3165 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.5% | 99.9% | 3421 | 3165 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | use_cases:use_case[environment_deployment] | 92.8% | 99.9% | 3484 | 3237 |
| use_cases:use_case[global_workflow_local_implementation] | use_cases:use_case[using_a_project] | 99.9% | 94.0% | 3638 | 3869 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.8% | 74.8% | 2981 | 3981 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.8% | 76.9% | 2981 | 3869 |
| alias:can_use_a_flow_in_an_alias | flow:reuse_flow_parameters | 77.8% | 99.8% | 3130 | 2441 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.1% | 3043 | 3195 |
| alias:capture_flow_command | flow:overwrite_flow | 99.8% | 95.3% | 3043 | 3189 |
| alias:capture_partial_flow | flow:extend_flow | 99.8% | 94.5% | 3025 | 3195 |
| ... | *4756 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4358 |
| use_cases:use_case[creating_extensions] | 4330 |
| use_cases:use_case[bash_command_from_alias] | 4027 |
| use_cases:use_case[3D_printing_flow] | 3981 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3972 |
| use_cases:use_case[self_documentation] | 3971 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3912 |
| use_cases:use_case[using_a_project] | 3869 |
| use_cases:use_case[setting_default_values] | 3680 |
| command:command | 3663 |
| use_cases:use_case[global_workflow_local_implementation] | 3638 |
| custom:capture_alias | 3551 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3484 |
| help:main_help | 3475 |
| use_cases:use_case[bash_command_use_option] | 3421 |
| use_cases:use_case[ipfs_name_publish] | 3415 |
| use_cases:use_case[choices] | 3399 |
| use_cases:use_case[podcast_automation] | 3390 |
| use_cases:use_case[using_a_plugin] | 3390 |
| use_cases:use_case[alias_to_root] | 3386 |
| ... | *89 more tests* |
