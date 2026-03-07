# Test Coverage Overlap Report

## Summary

- **Total tests:** 107
- **Full subsets (100%):** 86
- **High overlap (≥75%):** 4773
- **Significant overlap (≥50%):** 4978

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 3009 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2738 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3198 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3198 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3207 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2503 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2503 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2512 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2513 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2503 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2503 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2512 |
| command:dynamic_option | alias:alias_overrides_parameters | 2513 |
| alias:composite_alias | alias:simple_alias_command | 2945 |
| alias:simple_alias_command | alias:composite_alias | 2945 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2503 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2503 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2503 |
| command:dynamic_default_value | command:dynamic_option | 2503 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2503 |
| command:dynamic_default_value_callback | command:dynamic_option | 2503 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2512 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2513 |
| completion:command | completion:completion_with_saved_parameter | 3053 |
| completion:command | completion:dynamic_command | 3053 |
| completion:command | completion:dynamic_group | 3053 |
| completion:command | completion:group | 3053 |
| completion:command | types:complete_date | 3053 |
| completion:command | types:suggestion | 3053 |
| custom:group_python | completion:completion_with_saved_parameter | 2969 |
| completion:dynamic_command | completion:dynamic_group | 3111 |
| completion:dynamic_group | completion:dynamic_command | 3111 |
| completion:group | completion:dynamic_command | 3103 |
| completion:group | completion:dynamic_group | 3103 |
| custom:group_python | custom:simple_python | 2969 |
| custom:group_python | types:date | 2969 |
| custom:group_python | types:default_with_converter | 2969 |
| custom:group_python | types:suggestion | 2969 |
| parameter:simple_parameter | extension:copy_extension | 2738 |
| parameter:simple_parameter | extension:move_extension | 2738 |
| flow:overwrite_flow | flow:extend_flow | 3325 |
| parameter:simple_parameter | parameter:appending_parameters | 2738 |
| parameter:appending_parameters | parameter:using_automatic_options | 2746 |
| parameter:simple_parameter | parameter:parameter_precedence | 2738 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2738 |
| parameter:simple_parameter | parameter:removing_parameters | 2738 |
| parameter:removing_parameters | parameter:using_automatic_options | 2760 |
| parameter:simple_parameter | parameter:replacing_parameters | 2738 |
| parameter:simple_parameter | parameter:using_automatic_options | 2738 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2738 |
| types:default_with_converter | types:date | 2971 |
| types:default_with_converter | types:suggestion | 2971 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3304 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2986 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3240 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3304 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3212 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3307 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2986 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3240 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3212 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2986 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2986 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3240 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3240 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3240 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3240 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3240 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3212 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3029 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3029 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3304 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3304 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3212 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3059 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3212 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3212 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3212 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3212 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3212 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3307 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.0% | 99.9% | 3009 | 2741 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 74.1% | 3009 | 4058 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.1% | 3009 | 3535 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3198 | 2864 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.2% | 99.9% | 3207 | 2864 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3215 | 2864 |
| alias:alias_to_clk | use_cases:use_case[alias_to_root] | 99.9% | 88.7% | 2977 | 3352 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2945 | 3696 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2945 | 3535 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2945 | 3696 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2945 | 3535 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.3% | 99.9% | 3149 | 2971 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3149 | 3063 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.4% | 3208 | 3986 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2985 | 2971 |
| extension:copy_extension | parameter:replacing_parameters | 85.7% | 99.9% | 3197 | 2741 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3209 | 2741 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2746 | 2741 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.9% | 99.9% | 3081 | 2741 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 3014 | 2741 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2760 | 2741 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2741 | 2842 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2741 | 2797 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2741 | 3535 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.3% | 2738 | 2993 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.4% | 2738 | 4058 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2738 | 3535 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.6% | 2986 | 4167 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.7% | 99.9% | 4167 | 3240 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3240 | 3212 |
| ... | *4657 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4457 |
| use_cases:use_case[bash_command_from_alias] | 4167 |
| use_cases:use_case[self_documentation] | 4158 |
| use_cases:use_case[3D_printing_flow] | 4058 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3986 |
| use_cases:use_case[creating_extensions] | 3985 |
| use_cases:use_case[setting_default_values] | 3824 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3734 |
| command:command | 3733 |
| use_cases:use_case[global_workflow_local_implementation] | 3696 |
| custom:capture_alias | 3583 |
| help:main_help | 3559 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3549 |
| use_cases:use_case[using_a_project] | 3535 |
| use_cases:use_case[bash_command_use_option] | 3480 |
| custom:cannot_remove_existing_command | 3479 |
| use_cases:use_case[ipfs_name_publish] | 3476 |
| use_cases:use_case[choices] | 3462 |
| use_cases:use_case[podcast_automation] | 3452 |
| use_cases:use_case[using_a_plugin] | 3440 |
| ... | *87 more tests* |
