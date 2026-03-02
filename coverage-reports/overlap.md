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
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2992 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2723 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3178 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3178 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3187 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2486 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2486 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2495 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2496 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2486 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2486 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2495 |
| command:dynamic_option | alias:alias_overrides_parameters | 2496 |
| alias:composite_alias | alias:simple_alias_command | 2928 |
| alias:simple_alias_command | alias:composite_alias | 2928 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2486 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2486 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2486 |
| command:dynamic_default_value | command:dynamic_option | 2486 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2486 |
| command:dynamic_default_value_callback | command:dynamic_option | 2486 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2495 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2496 |
| completion:command | completion:completion_with_saved_parameter | 3036 |
| completion:command | completion:dynamic_command | 3036 |
| completion:command | completion:dynamic_group | 3036 |
| completion:command | completion:group | 3036 |
| completion:command | types:complete_date | 3036 |
| completion:command | types:suggestion | 3036 |
| custom:group_python | completion:completion_with_saved_parameter | 2952 |
| completion:dynamic_command | completion:dynamic_group | 3094 |
| completion:dynamic_group | completion:dynamic_command | 3094 |
| completion:group | completion:dynamic_command | 3086 |
| completion:group | completion:dynamic_group | 3086 |
| custom:group_python | custom:simple_python | 2952 |
| custom:group_python | types:date | 2952 |
| custom:group_python | types:default_with_converter | 2952 |
| custom:group_python | types:suggestion | 2952 |
| parameter:simple_parameter | extension:copy_extension | 2723 |
| parameter:simple_parameter | extension:move_extension | 2723 |
| flow:overwrite_flow | flow:extend_flow | 3306 |
| parameter:simple_parameter | parameter:appending_parameters | 2723 |
| parameter:appending_parameters | parameter:using_automatic_options | 2731 |
| parameter:simple_parameter | parameter:parameter_precedence | 2723 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2723 |
| parameter:simple_parameter | parameter:removing_parameters | 2723 |
| parameter:removing_parameters | parameter:using_automatic_options | 2745 |
| parameter:simple_parameter | parameter:replacing_parameters | 2723 |
| parameter:simple_parameter | parameter:using_automatic_options | 2723 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2723 |
| types:default_with_converter | types:date | 2954 |
| types:default_with_converter | types:suggestion | 2954 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3285 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2969 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3222 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3285 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3194 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3289 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2969 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3222 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3194 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2969 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2969 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3222 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3222 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3222 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3222 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3222 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3194 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3012 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3285 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3285 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3194 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3042 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3194 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3194 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3194 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3194 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3194 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3289 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.0% | 99.9% | 2992 | 2726 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 74.0% | 2992 | 4039 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.0% | 2992 | 3516 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3178 | 2847 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.2% | 99.9% | 3187 | 2847 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3195 | 2847 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2928 | 3676 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2928 | 3516 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2928 | 3676 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2928 | 3516 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3132 | 2954 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3132 | 3046 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.4% | 3190 | 3965 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2968 | 2954 |
| extension:copy_extension | parameter:replacing_parameters | 85.7% | 99.9% | 3177 | 2726 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3189 | 2726 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2731 | 2726 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.9% | 99.9% | 3063 | 2726 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 2997 | 2726 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2745 | 2726 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2726 | 2827 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2726 | 2782 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2726 | 3516 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.4% | 2723 | 2976 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.3% | 2723 | 4039 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2723 | 3516 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.5% | 2969 | 4147 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.6% | 99.9% | 4147 | 3222 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3222 | 3194 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.3% | 99.9% | 3459 | 3194 |
| ... | *4561 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4548 |
| use_cases:use_case[bash_command_from_alias] | 4147 |
| use_cases:use_case[self_documentation] | 4137 |
| use_cases:use_case[3D_printing_flow] | 4039 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3965 |
| use_cases:use_case[creating_extensions] | 3963 |
| use_cases:use_case[setting_default_values] | 3807 |
| command:command | 3718 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3706 |
| use_cases:use_case[global_workflow_local_implementation] | 3676 |
| custom:capture_alias | 3565 |
| help:main_help | 3544 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3529 |
| use_cases:use_case[using_a_project] | 3516 |
| use_cases:use_case[bash_command_use_option] | 3459 |
| custom:cannot_remove_existing_command | 3458 |
| use_cases:use_case[ipfs_name_publish] | 3458 |
| use_cases:use_case[choices] | 3444 |
| use_cases:use_case[podcast_automation] | 3433 |
| use_cases:use_case[using_a_plugin] | 3421 |
| ... | *86 more tests* |
