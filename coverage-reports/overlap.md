# Test Coverage Overlap Report

## Summary

- **Total tests:** 101
- **Full subsets (100%):** 22
- **High overlap (≥75%):** 3951
- **Significant overlap (≥50%):** 4081

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3073 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3073 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3082 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2355 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2364 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2355 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2364 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2355 |
| completion:command | completion:completion_with_saved_parameter | 2845 |
| completion:command | completion:dynamic_group | 2845 |
| completion:command | completion:group | 2845 |
| completion:command | types:complete_date | 2845 |
| completion:command | types:suggestion | 2845 |
| custom:group_python | completion:completion_with_saved_parameter | 2765 |
| completion:group | completion:dynamic_group | 2899 |
| custom:group_python | custom:simple_python | 2765 |
| custom:group_python | types:date | 2765 |
| custom:group_python | types:default_with_converter | 2765 |
| custom:group_python | types:suggestion | 2765 |
| parameter:removing_parameters | parameter:using_automatic_options | 2755 |
| types:default_with_converter | types:date | 2767 |
| types:default_with_converter | types:suggestion | 2767 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.4% | 99.9% | 3073 | 2751 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.2% | 99.9% | 3082 | 2751 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.9% | 99.9% | 3090 | 2751 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.3% | 99.9% | 3068 | 3050 |
| completion:completion_with_saved_parameter | types:default_with_converter | 89.9% | 99.9% | 3074 | 2767 |
| completion:completion_with_saved_parameter | types:suggestion | 92.8% | 99.9% | 3074 | 2856 |
| custom:simple_python | types:default_with_converter | 99.4% | 99.9% | 2781 | 2767 |
| extension:copy_extension | parameter:config_extension_overrides_global | 96.1% | 99.9% | 3119 | 2998 |
| extension:copy_extension | parameter:replacing_parameters | 87.7% | 99.9% | 3119 | 2736 |
| extension:move_extension | parameter:config_extension_overrides_global | 95.8% | 99.9% | 3128 | 2998 |
| extension:move_extension | parameter:replacing_parameters | 87.4% | 99.9% | 3128 | 2736 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 2998 | 3042 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 91.2% | 99.9% | 2998 | 2736 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.9% | 99.9% | 3042 | 2736 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 91.0% | 99.9% | 3004 | 2736 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2755 | 2736 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.6% | 2736 | 2830 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 98.2% | 2736 | 2785 |
| use_cases:use_case[3D_printing_flow] | use_cases:use_case[controlling_the_audio] | 61.3% | 99.9% | 4607 | 2829 |
| use_cases:use_case[calling_my_mcp_server] | use_cases:use_case[controlling_the_audio] | 68.6% | 99.9% | 4122 | 2829 |
| use_cases:use_case[choices] | use_cases:use_case[controlling_the_audio] | 85.5% | 99.9% | 3305 | 2829 |
| use_cases:use_case[controlling_the_audio] | use_cases:use_case[python_command] | 99.9% | 90.6% | 2829 | 3121 |
| use_cases:use_case[controlling_the_audio] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 99.9% | 68.2% | 2829 | 4143 |
| use_cases:use_case[global_workflow_local_implementation] | use_cases:use_case[using_a_project] | 99.9% | 88.6% | 3606 | 4065 |
| alias:can_use_a_flow_in_an_alias | flow:reuse_flow_parameters | 77.9% | 99.8% | 3150 | 2458 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.1% | 3068 | 3220 |
| alias:capture_partial_flow | flow:extend_flow | 99.8% | 94.5% | 3050 | 3220 |
| alias:capture_partial_flow | use_cases:use_case[3D_printing_flow] | 99.8% | 66.1% | 3050 | 4607 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.8% | 81.5% | 2943 | 3606 |
| alias:simple_alias_command | use_cases:use_case[podcast_automation] | 99.8% | 78.2% | 2943 | 3758 |
| ... | *3899 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[3D_printing_flow] | 4607 |
| use_cases:use_case[creating_extensions] | 4487 |
| use_cases:use_case[backing_up_documents] | 4319 |
| use_cases:use_case[controlling_my_music] | 4190 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 4143 |
| use_cases:use_case[calling_my_mcp_server] | 4122 |
| use_cases:use_case[using_a_project] | 4065 |
| use_cases:use_case[self_documentation] | 3977 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3871 |
| use_cases:use_case[podcast_automation] | 3758 |
| command:command | 3648 |
| use_cases:use_case[global_workflow_local_implementation] | 3606 |
| use_cases:use_case[setting_default_values] | 3604 |
| use_cases:use_case[using_a_plugin] | 3581 |
| custom:capture_alias | 3536 |
| use_cases:use_case[checking_my_server] | 3512 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3477 |
| use_cases:use_case[alias_to_root] | 3456 |
| help:main_help | 3422 |
| use_cases:use_case[bash_command_use_option] | 3377 |
| ... | *81 more tests* |
