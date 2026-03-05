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
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 3005 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2734 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3193 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3193 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3202 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2498 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2498 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2507 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2508 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2498 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2498 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2507 |
| command:dynamic_option | alias:alias_overrides_parameters | 2508 |
| alias:composite_alias | alias:simple_alias_command | 2941 |
| alias:simple_alias_command | alias:composite_alias | 2941 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2498 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2498 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2498 |
| command:dynamic_default_value | command:dynamic_option | 2498 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2498 |
| command:dynamic_default_value_callback | command:dynamic_option | 2498 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2507 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2508 |
| completion:command | completion:completion_with_saved_parameter | 3048 |
| completion:command | completion:dynamic_command | 3048 |
| completion:command | completion:dynamic_group | 3048 |
| completion:command | completion:group | 3048 |
| completion:command | types:complete_date | 3048 |
| completion:command | types:suggestion | 3048 |
| custom:group_python | completion:completion_with_saved_parameter | 2964 |
| completion:dynamic_command | completion:dynamic_group | 3106 |
| completion:dynamic_group | completion:dynamic_command | 3106 |
| completion:group | completion:dynamic_command | 3098 |
| completion:group | completion:dynamic_group | 3098 |
| custom:group_python | custom:simple_python | 2964 |
| custom:group_python | types:date | 2964 |
| custom:group_python | types:default_with_converter | 2964 |
| custom:group_python | types:suggestion | 2964 |
| parameter:simple_parameter | extension:copy_extension | 2734 |
| parameter:simple_parameter | extension:move_extension | 2734 |
| flow:overwrite_flow | flow:extend_flow | 3320 |
| parameter:simple_parameter | parameter:appending_parameters | 2734 |
| parameter:appending_parameters | parameter:using_automatic_options | 2742 |
| parameter:simple_parameter | parameter:parameter_precedence | 2734 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2734 |
| parameter:simple_parameter | parameter:removing_parameters | 2734 |
| parameter:removing_parameters | parameter:using_automatic_options | 2756 |
| parameter:simple_parameter | parameter:replacing_parameters | 2734 |
| parameter:simple_parameter | parameter:using_automatic_options | 2734 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2734 |
| types:default_with_converter | types:date | 2966 |
| types:default_with_converter | types:suggestion | 2966 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[3D_printing_flow] | 3299 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[backing_up_documents] | 2981 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[backing_up_documents] | 3235 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[backing_up_documents] | 3299 |
| use_cases:use_case[hello_world] | use_cases:use_case[backing_up_documents] | 3207 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[backing_up_documents] | 3302 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command] | 2981 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command] | 3235 |
| use_cases:use_case[hello_world] | use_cases:use_case[bash_command] | 3207 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_import] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_use_option] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[choices] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ethereum_local_environment_dev_tool] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[global_workflow_local_implementation] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[hello_world] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[ipfs_name_publish] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[multi_environment_deployment_tool] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[self_documentation] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[send_sms] | 2981 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 2981 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[bash_command_use_option] | 3235 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[ipfs_name_publish] | 3235 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[multi_environment_deployment_tool] | 3235 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[send_sms] | 3235 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3235 |
| use_cases:use_case[hello_world] | use_cases:use_case[choices] | 3207 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[dynamic_parameters_and_exposed_class] | 3024 |
| use_cases:use_case[dynamic_parameters_advanced_use_cases] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3024 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3299 |
| use_cases:use_case[environment_deployment] | use_cases:use_case[podcast_automation] | 3299 |
| use_cases:use_case[hello_world] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3207 |
| use_cases:use_case[scrapping_the_web] | use_cases:use_case[ethereum_local_environment_dev_tool] | 3054 |
| use_cases:use_case[hello_world] | use_cases:use_case[global_workflow_local_implementation] | 3207 |
| use_cases:use_case[hello_world] | use_cases:use_case[ipfs_name_publish] | 3207 |
| use_cases:use_case[hello_world] | use_cases:use_case[multi_environment_deployment_tool] | 3207 |
| use_cases:use_case[hello_world] | use_cases:use_case[send_sms] | 3207 |
| use_cases:use_case[hello_world] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3207 |
| use_cases:use_case[multi_environment_deployment_tool] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 3302 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.0% | 99.9% | 3005 | 2737 |
| alias:alias_conserves_parameters | use_cases:use_case[3D_printing_flow] | 99.9% | 74.0% | 3005 | 4053 |
| alias:alias_conserves_parameters | use_cases:use_case[using_a_project] | 99.9% | 85.1% | 3005 | 3530 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.4% | 99.9% | 3193 | 2859 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.2% | 99.9% | 3202 | 2859 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3210 | 2859 |
| alias:alias_to_clk | use_cases:use_case[alias_to_root] | 99.9% | 88.7% | 2973 | 3347 |
| alias:composite_alias | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2941 | 3691 |
| alias:composite_alias | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2941 | 3530 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.9% | 79.6% | 2941 | 3691 |
| alias:simple_alias_command | use_cases:use_case[using_a_project] | 99.9% | 83.3% | 2941 | 3530 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3144 | 2966 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3144 | 3058 |
| custom:default_help_message_triggers_a_warning | use_cases:use_case[ethereum_local_environment_dev_tool] | 99.9% | 80.4% | 3203 | 3981 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2980 | 2966 |
| extension:copy_extension | parameter:replacing_parameters | 85.8% | 99.9% | 3189 | 2737 |
| extension:move_extension | parameter:replacing_parameters | 85.4% | 99.9% | 3201 | 2737 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2742 | 2737 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.0% | 99.9% | 3074 | 2737 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 3010 | 2737 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2756 | 2737 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.4% | 2737 | 2838 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2737 | 2793 |
| parameter:replacing_parameters | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2737 | 3530 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.4% | 2734 | 2988 |
| parameter:simple_parameter | use_cases:use_case[3D_printing_flow] | 99.9% | 67.4% | 2734 | 4053 |
| parameter:simple_parameter | use_cases:use_case[using_a_project] | 99.9% | 77.4% | 2734 | 3530 |
| use_cases:use_case[bash_command_built_in_lib] | use_cases:use_case[bash_command_from_alias] | 99.9% | 71.6% | 2981 | 4162 |
| use_cases:use_case[bash_command_from_alias] | use_cases:use_case[bash_command_import] | 77.7% | 99.9% | 4162 | 3235 |
| use_cases:use_case[bash_command_import] | use_cases:use_case[hello_world] | 99.1% | 99.9% | 3235 | 3207 |
| ... | *4657 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[backing_up_documents] | 4563 |
| use_cases:use_case[bash_command_from_alias] | 4162 |
| use_cases:use_case[self_documentation] | 4150 |
| use_cases:use_case[3D_printing_flow] | 4053 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3981 |
| use_cases:use_case[creating_extensions] | 3977 |
| use_cases:use_case[setting_default_values] | 3819 |
| command:command | 3729 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 3729 |
| use_cases:use_case[global_workflow_local_implementation] | 3691 |
| custom:capture_alias | 3579 |
| help:main_help | 3555 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3544 |
| use_cases:use_case[using_a_project] | 3530 |
| use_cases:use_case[bash_command_use_option] | 3475 |
| custom:cannot_remove_existing_command | 3471 |
| use_cases:use_case[ipfs_name_publish] | 3471 |
| use_cases:use_case[choices] | 3457 |
| use_cases:use_case[podcast_automation] | 3447 |
| use_cases:use_case[using_a_plugin] | 3435 |
| ... | *87 more tests* |
