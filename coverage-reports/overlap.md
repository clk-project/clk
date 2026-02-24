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
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2987 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2718 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3174 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3174 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3183 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2484 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2484 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2493 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2494 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2484 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2484 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2493 |
| command:dynamic_option | alias:alias_overrides_parameters | 2494 |
| alias:composite_alias | alias:simple_alias_command | 2923 |
| alias:simple_alias_command | alias:composite_alias | 2923 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2484 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2484 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2484 |
| command:dynamic_default_value | command:dynamic_option | 2484 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2484 |
| command:dynamic_default_value_callback | command:dynamic_option | 2484 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2493 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2494 |
| completion:command | completion:completion_with_saved_parameter | 3032 |
| completion:command | completion:dynamic_command | 3032 |
| completion:command | completion:dynamic_group | 3032 |
| completion:command | completion:group | 3032 |
| completion:command | types:complete_date | 3032 |
| completion:command | types:suggestion | 3032 |
| custom:group_python | completion:completion_with_saved_parameter | 2948 |
| completion:dynamic_command | completion:dynamic_group | 3090 |
| completion:dynamic_group | completion:dynamic_command | 3090 |
| completion:group | completion:dynamic_command | 3082 |
| completion:group | completion:dynamic_group | 3082 |
| custom:group_python | custom:simple_python | 2948 |
| custom:group_python | types:date | 2948 |
| custom:group_python | types:default_with_converter | 2948 |
| custom:group_python | types:suggestion | 2948 |
| parameter:simple_parameter | extension:copy_extension | 2718 |
| parameter:simple_parameter | extension:move_extension | 2718 |
| flow:overwrite_flow | flow:extend_flow | 3302 |
| parameter:simple_parameter | parameter:appending_parameters | 2718 |
| parameter:appending_parameters | parameter:using_automatic_options | 2726 |
| parameter:simple_parameter | parameter:parameter_precedence | 2718 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2718 |
| parameter:simple_parameter | parameter:removing_parameters | 2718 |
| parameter:removing_parameters | parameter:using_automatic_options | 2740 |
| parameter:simple_parameter | parameter:replacing_parameters | 2718 |
| parameter:simple_parameter | parameter:using_automatic_options | 2718 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2718 |
| types:default_with_converter | types:date | 2950 |
| types:default_with_converter | types:suggestion | 2950 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3281 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2965 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3218 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3281 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3190 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3285 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2965 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3218 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3190 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2965 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2965 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3218 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3218 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3218 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3218 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3218 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3190 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3008 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3281 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3281 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3190 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3038 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3190 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3190 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3190 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3190 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3190 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3285 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.0% | 99.9% | 2987 | 2721 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 73.9% | 2987 | 4035 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.0% | 2987 | 3512 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3174 | 2843 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.2% | 99.9% | 3183 | 2843 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3191 | 2843 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.5% | 2923 | 3672 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2923 | 3512 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.5% | 2923 | 3672 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.2% | 2923 | 3512 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3128 | 2950 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3128 | 3042 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.3% | 3186 | 3961 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2964 | 2950 |
| extension:copy_extension | parameter:replacing_parameters | 85.7% | 99.9% | 3173 | 2721 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3185 | 2721 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2726 | 2721 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.9% | 99.9% | 3058 | 2721 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 2992 | 2721 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2740 | 2721 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2721 | 2822 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2721 | 2777 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2721 | 3512 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.3% | 2718 | 2972 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.3% | 2718 | 4035 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.3% | 2718 | 3512 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.5% | 2965 | 4143 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.6% | 99.9% | 4143 | 3218 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3218 | 3190 |
| use_cases:use_case[bash_command_use_option] | use_cases:use_case[hello_world] | 92.3% | 99.9% | 3455 | 3190 |
| ... | *4561 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4544 |
| use_cases:use_case[bash_command_from_alias] | 4143 |
| use_cases:use_case[self_documentation] | 4133 |
| use_cases:use_case[3D_printing_flow] | 4035 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3961 |
| use_cases:use_case[creating_extensions] | 3959 |
| use_cases:use_case[setting_default_values] | 3803 |
| command:command | 3713 |
| use_cases:use_case[global_workflow_local_implementation] | 3672 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3591 |
| custom:capture_alias | 3560 |
| help:main_help | 3539 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3525 |
| use_cases:use_case[using_a_project] | 3512 |
| use_cases:use_case[bash_command_use_option] | 3455 |
| custom:cannot_remove_existing_command | 3454 |
| use_cases:use_case[ipfs_name_publish] | 3454 |
| use_cases:use_case[choices] | 3440 |
| use_cases:use_case[podcast_automation] | 3429 |
| use_cases:use_case[using_a_plugin] | 3417 |
| ... | *86 more tests* |
