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
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 3004 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2733 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3192 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3192 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3201 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2497 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2497 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2506 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2507 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2497 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2497 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2506 |
| command:dynamic_option | alias:alias_overrides_parameters | 2507 |
| alias:composite_alias | alias:simple_alias_command | 2940 |
| alias:simple_alias_command | alias:composite_alias | 2940 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2497 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2497 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2497 |
| command:dynamic_default_value | command:dynamic_option | 2497 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2497 |
| command:dynamic_default_value_callback | command:dynamic_option | 2497 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2506 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2507 |
| completion:command | completion:completion_with_saved_parameter | 3047 |
| completion:command | completion:dynamic_command | 3047 |
| completion:command | completion:dynamic_group | 3047 |
| completion:command | completion:group | 3047 |
| completion:command | types:complete_date | 3047 |
| completion:command | types:suggestion | 3047 |
| custom:group_python | completion:completion_with_saved_parameter | 2963 |
| completion:dynamic_command | completion:dynamic_group | 3105 |
| completion:dynamic_group | completion:dynamic_command | 3105 |
| completion:group | completion:dynamic_command | 3097 |
| completion:group | completion:dynamic_group | 3097 |
| custom:group_python | custom:simple_python | 2963 |
| custom:group_python | types:date | 2963 |
| custom:group_python | types:default_with_converter | 2963 |
| custom:group_python | types:suggestion | 2963 |
| parameter:simple_parameter | extension:copy_extension | 2733 |
| parameter:simple_parameter | extension:move_extension | 2733 |
| flow:overwrite_flow | flow:extend_flow | 3319 |
| parameter:simple_parameter | parameter:appending_parameters | 2733 |
| parameter:appending_parameters | parameter:using_automatic_options | 2741 |
| parameter:simple_parameter | parameter:parameter_precedence | 2733 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2733 |
| parameter:simple_parameter | parameter:removing_parameters | 2733 |
| parameter:removing_parameters | parameter:using_automatic_options | 2755 |
| parameter:simple_parameter | parameter:replacing_parameters | 2733 |
| parameter:simple_parameter | parameter:using_automatic_options | 2733 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2733 |
| types:default_with_converter | types:date | 2965 |
| types:default_with_converter | types:suggestion | 2965 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3298 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2980 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3234 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3298 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3206 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3301 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2980 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3234 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3206 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2980 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2980 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3234 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3234 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3234 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3234 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3234 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3206 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3023 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3023 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3298 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3298 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3206 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3053 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3206 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3206 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3206 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3206 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3206 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3301 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.0% | 99.9% | 3004 | 2736 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 74.0% | 3004 | 4052 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.1% | 3004 | 3529 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.4% | 99.9% | 3192 | 2858 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.2% | 99.9% | 3201 | 2858 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3209 | 2858 |
| alias:alias_to_clk | use_cases:use_case[alias_to_root] | 99.9% | 88.7% | 2972 | 3346 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2940 | 3690 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2940 | 3529 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2940 | 3690 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2940 | 3529 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3143 | 2965 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3143 | 3057 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.4% | 3202 | 3980 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2979 | 2965 |
| extension:copy_extension | parameter:replacing_parameters | 85.8% | 99.9% | 3188 | 2736 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3200 | 2736 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2741 | 2736 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.0% | 99.9% | 3073 | 2736 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 3009 | 2736 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2755 | 2736 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2736 | 2837 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2736 | 2792 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2736 | 3529 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.4% | 2733 | 2987 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.3% | 2733 | 4052 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2733 | 3529 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.5% | 2980 | 4161 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.6% | 99.9% | 4161 | 3234 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3234 | 3206 |
| ... | *4657 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4562 |
| use_cases:use_case[bash_command_from_alias] | 4161 |
| use_cases:use_case[self_documentation] | 4149 |
| use_cases:use_case[3D_printing_flow] | 4052 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3980 |
| use_cases:use_case[creating_extensions] | 3976 |
| use_cases:use_case[setting_default_values] | 3818 |
| command:command | 3728 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3728 |
| use_cases:use_case[global_workflow_local_implementation] | 3690 |
| custom:capture_alias | 3578 |
| help:main_help | 3554 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3543 |
| use_cases:use_case[using_a_project] | 3529 |
| use_cases:use_case[bash_command_use_option] | 3474 |
| custom:cannot_remove_existing_command | 3470 |
| use_cases:use_case[ipfs_name_publish] | 3470 |
| use_cases:use_case[choices] | 3456 |
| use_cases:use_case[podcast_automation] | 3446 |
| use_cases:use_case[using_a_plugin] | 3434 |
| ... | *87 more tests* |
