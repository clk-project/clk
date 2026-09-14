# Test Coverage Overlap Report

## Summary

- **Total tests:** 109
- **Full subsets (100%):** 87
- **High overlap (≥75%):** 4971
- **Significant overlap (≥50%):** 5113

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2989 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2715 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3064 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3064 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3073 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2339 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2339 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2348 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2348 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2339 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2339 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2348 |
| command:dynamic_option | alias:alias_overrides_parameters | 2348 |
| alias:composite_alias | alias:simple_alias_command | 2925 |
| alias:simple_alias_command | alias:composite_alias | 2925 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2339 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2339 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2339 |
| command:dynamic_default_value | command:dynamic_option | 2339 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2339 |
| command:dynamic_default_value_callback | command:dynamic_option | 2339 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2348 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2348 |
| completion:command | completion:completion_with_saved_parameter | 2977 |
| completion:command | completion:dynamic_command | 2977 |
| completion:command | completion:dynamic_group | 2977 |
| completion:command | completion:group | 2977 |
| completion:command | types:complete_date | 2977 |
| completion:command | types:suggestion | 2977 |
| custom:group_python | completion:completion_with_saved_parameter | 2894 |
| completion:dynamic_command | completion:dynamic_group | 3031 |
| completion:dynamic_group | completion:dynamic_command | 3031 |
| completion:group | completion:dynamic_command | 3023 |
| completion:group | completion:dynamic_group | 3023 |
| custom:group_python | custom:simple_python | 2894 |
| custom:group_python | types:date | 2894 |
| custom:group_python | types:default_with_converter | 2894 |
| custom:group_python | types:suggestion | 2894 |
| parameter:simple_parameter | extension:copy_extension | 2715 |
| parameter:simple_parameter | extension:move_extension | 2715 |
| flow:overwrite_flow | flow:extend_flow | 3190 |
| parameter:simple_parameter | parameter:appending_parameters | 2715 |
| parameter:appending_parameters | parameter:using_automatic_options | 2723 |
| parameter:simple_parameter | parameter:config_extension_overrides_global | 2715 |
| parameter:simple_parameter | parameter:parameter_precedence | 2715 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2715 |
| parameter:simple_parameter | parameter:removing_parameters | 2715 |
| parameter:removing_parameters | parameter:using_automatic_options | 2737 |
| parameter:simple_parameter | parameter:replacing_parameters | 2715 |
| parameter:simple_parameter | parameter:using_automatic_options | 2715 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2715 |
| types:default_with_converter | types:date | 2896 |
| types:default_with_converter | types:suggestion | 2896 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3248 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2918 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3191 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3248 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3176 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3255 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2918 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3191 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3176 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[creating_extensions] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2918 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2918 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3191 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3191 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3191 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3191 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3191 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3176 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 2975 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2975 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3248 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3248 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3176 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3176 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3176 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3176 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3176 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3176 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3255 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 90.9% | 99.9% | 2989 | 2718 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.2% | 2989 | 3504 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.1% | 99.9% | 3064 | 2733 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.8% | 99.9% | 3073 | 2733 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.6% | 99.9% | 3081 | 2733 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.3% | 99.9% | 3044 | 3026 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 80.0% | 2925 | 3652 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.4% | 2925 | 3504 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 80.0% | 2925 | 3652 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.4% | 2925 | 3504 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.1% | 99.9% | 3074 | 2896 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3074 | 2988 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2910 | 2896 |
| extension:copy_extension | parameter:config_extension_overrides_global | 96.5% | 99.9% | 3112 | 3006 |
| extension:copy_extension | parameter:replacing_parameters | 87.3% | 99.9% | 3112 | 2718 |
| extension:move_extension | parameter:config_extension_overrides_global | 96.2% | 99.9% | 3123 | 3006 |
| extension:move_extension | parameter:replacing_parameters | 87.0% | 99.9% | 3123 | 2718 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2723 | 2718 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 3006 | 3050 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 90.4% | 99.9% | 3006 | 2718 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.0% | 99.9% | 3050 | 2718 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.7% | 99.9% | 2994 | 2718 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2737 | 2718 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.3% | 2718 | 2819 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2718 | 2774 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2715 | 3504 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.2% | 2918 | 4093 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.9% | 99.9% | 4093 | 3191 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.5% | 99.9% | 3191 | 3176 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.4% | 99.9% | 3435 | 3176 |
| ... | *4854 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4392 |
| use_cases:use_case[creating_extensions] | 4229 |
| use_cases:use_case[self_documentation] | 4096 |
| use_cases:use_case[bash_command_from_alias] | 4093 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 4006 |
| use_cases:use_case[3D_printing_flow] | 4000 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3936 |
| use_cases:use_case[setting_default_values] | 3752 |
| command:command | 3694 |
| use_cases:use_case[global_workflow_local_implementation] | 3652 |
| custom:capture_alias | 3561 |
| help:main_help | 3506 |
| use_cases:use_case[using_a_project] | 3504 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3498 |
| use_cases:use_case[alias_to_root] | 3441 |
| use_cases:use_case[bash_command_use_option] | 3435 |
| use_cases:use_case[ipfs_name_publish] | 3429 |
| use_cases:use_case[choices] | 3413 |
| use_cases:use_case[podcast_automation] | 3401 |
| custom:cannot_remove_existing_command | 3395 |
| ... | *89 more tests* |
