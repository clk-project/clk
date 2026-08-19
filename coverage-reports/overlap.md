# Test Coverage Overlap Report

## Summary

- **Total tests:** 109
- **Full subsets (100%):** 87
- **High overlap (≥75%):** 4971
- **Significant overlap (≥50%):** 5134

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 3035 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2764 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3110 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3110 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3119 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2387 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2387 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2396 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2396 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2387 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2387 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2396 |
| command:dynamic_option | alias:alias_overrides_parameters | 2396 |
| alias:composite_alias | alias:simple_alias_command | 2971 |
| alias:simple_alias_command | alias:composite_alias | 2971 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2387 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2387 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2387 |
| command:dynamic_default_value | command:dynamic_option | 2387 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2387 |
| command:dynamic_default_value_callback | command:dynamic_option | 2387 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2396 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2396 |
| completion:command | completion:completion_with_saved_parameter | 3077 |
| completion:command | completion:dynamic_command | 3077 |
| completion:command | completion:dynamic_group | 3077 |
| completion:command | completion:group | 3077 |
| completion:command | types:complete_date | 3077 |
| completion:command | types:suggestion | 3077 |
| custom:group_python | completion:completion_with_saved_parameter | 2994 |
| completion:dynamic_command | completion:dynamic_group | 3131 |
| completion:dynamic_group | completion:dynamic_command | 3131 |
| completion:group | completion:dynamic_command | 3123 |
| completion:group | completion:dynamic_group | 3123 |
| custom:group_python | custom:simple_python | 2994 |
| custom:group_python | types:date | 2994 |
| custom:group_python | types:default_with_converter | 2994 |
| custom:group_python | types:suggestion | 2994 |
| parameter:simple_parameter | extension:copy_extension | 2764 |
| parameter:simple_parameter | extension:move_extension | 2764 |
| flow:overwrite_flow | flow:extend_flow | 3236 |
| parameter:simple_parameter | parameter:appending_parameters | 2764 |
| parameter:appending_parameters | parameter:using_automatic_options | 2772 |
| parameter:simple_parameter | parameter:config_extension_overrides_global | 2764 |
| parameter:simple_parameter | parameter:parameter_precedence | 2764 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2764 |
| parameter:simple_parameter | parameter:removing_parameters | 2764 |
| parameter:removing_parameters | parameter:using_automatic_options | 2786 |
| parameter:simple_parameter | parameter:replacing_parameters | 2764 |
| parameter:simple_parameter | parameter:using_automatic_options | 2764 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2764 |
| types:default_with_converter | types:date | 2996 |
| types:default_with_converter | types:suggestion | 2996 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3351 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 3024 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3291 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3351 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3250 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3355 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 3024 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3291 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3250 |
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
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3291 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3291 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3291 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3291 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3291 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3250 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3081 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3081 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3351 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3351 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3250 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3250 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3250 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3250 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3250 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3250 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3355 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.1% | 99.9% | 3035 | 2767 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 84.2% | 3035 | 3600 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.4% | 99.9% | 3110 | 2782 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.1% | 99.9% | 3119 | 2782 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.9% | 99.9% | 3127 | 2782 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.4% | 99.9% | 3090 | 3072 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.1% | 2971 | 3749 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 82.4% | 2971 | 3600 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.1% | 2971 | 3749 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 82.4% | 2971 | 3600 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.3% | 99.9% | 3174 | 2996 |
| completion:completion_with_saved_parameter | types:suggestion | 97.2% | 99.9% | 3174 | 3088 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 3010 | 2996 |
| extension:copy_extension | parameter:config_extension_overrides_global | 95.0% | 99.9% | 3222 | 3064 |
| extension:copy_extension | parameter:replacing_parameters | 85.8% | 99.9% | 3222 | 2767 |
| extension:move_extension | parameter:config_extension_overrides_global | 94.7% | 99.9% | 3234 | 3064 |
| extension:move_extension | parameter:replacing_parameters | 85.5% | 99.9% | 3234 | 2767 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2772 | 2767 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 3064 | 3108 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 90.2% | 99.9% | 3064 | 2767 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.0% | 99.9% | 3108 | 2767 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 91.0% | 99.9% | 3040 | 2767 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2786 | 2767 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2767 | 2868 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2767 | 2823 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 76.7% | 2764 | 3600 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.7% | 3024 | 4216 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 78.0% | 99.9% | 4216 | 3291 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 98.7% | 99.9% | 3291 | 3250 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 91.9% | 99.9% | 3536 | 3250 |
| ... | *4854 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4508 |
| use_cases:use_case[creating_extensions] | 4318 |
| use_cases:use_case[bash_command_from_alias] | 4216 |
| use_cases:use_case[self_documentation] | 4208 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 4126 |
| use_cases:use_case[3D_printing_flow] | 4103 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 4017 |
| use_cases:use_case[setting_default_values] | 3882 |
| command:command | 3751 |
| use_cases:use_case[global_workflow_local_implementation] | 3749 |
| custom:capture_alias | 3606 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3601 |
| use_cases:use_case[using_a_project] | 3600 |
| help:main_help | 3572 |
| use_cases:use_case[bash_command_use_option] | 3536 |
| use_cases:use_case[ipfs_name_publish] | 3529 |
| use_cases:use_case[choices] | 3513 |
| custom:cannot_remove_existing_command | 3504 |
| use_cases:use_case[podcast_automation] | 3504 |
| use_cases:use_case[using_a_plugin] | 3497 |
| ... | *89 more tests* |
