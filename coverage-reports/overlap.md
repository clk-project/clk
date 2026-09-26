# Test Coverage Overlap Report

## Summary

- **Total tests:** 101
- **Full subsets (100%):** 22
- **High overlap (≥75%):** 3950
- **Significant overlap (≥50%):** 4081

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3065 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3065 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3074 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2343 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2352 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2343 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2352 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2343 |
| completion:command | completion:completion_with_saved_parameter | 2833 |
| completion:command | completion:dynamic_group | 2833 |
| completion:command | completion:group | 2833 |
| completion:command | types:complete_date | 2833 |
| completion:command | types:suggestion | 2833 |
| custom:group_python | completion:completion_with_saved_parameter | 2753 |
| completion:group | completion:dynamic_group | 2887 |
| custom:group_python | custom:simple_python | 2753 |
| custom:group_python | types:date | 2753 |
| custom:group_python | types:default_with_converter | 2753 |
| custom:group_python | types:suggestion | 2753 |
| parameter:removing_parameters | parameter:using_automatic_options | 2743 |
| types:default_with_converter | types:date | 2755 |
| types:default_with_converter | types:suggestion | 2755 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3065 | 2739 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.0% | 99.9% | 3074 | 2739 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.8% | 99.9% | 3082 | 2739 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.3% | 99.9% | 3060 | 3042 |
| completion:completion_with_saved_parameter | types:default_with_converter | 89.9% | 99.9% | 3062 | 2755 |
| completion:completion_with_saved_parameter | types:suggestion | 92.7% | 99.9% | 3062 | 2844 |
| custom:simple_python | types:default_with_converter | 99.4% | 99.9% | 2769 | 2755 |
| extension:copy_extension | parameter:config_extension_overrides_global | 96.0% | 99.9% | 3107 | 2986 |
| extension:copy_extension | parameter:replacing_parameters | 87.6% | 99.9% | 3107 | 2724 |
| extension:move_extension | parameter:config_extension_overrides_global | 95.8% | 99.9% | 3116 | 2986 |
| extension:move_extension | parameter:replacing_parameters | 87.4% | 99.9% | 3116 | 2724 |
| parameter:config_extension_overrides_global | parameter:parameter_precedence | 99.9% | 98.5% | 2986 | 3030 |
| parameter:config_extension_overrides_global | parameter:replacing_parameters | 91.2% | 99.9% | 2986 | 2724 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.8% | 99.9% | 3030 | 2724 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.9% | 99.9% | 2996 | 2724 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2743 | 2724 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.6% | 2724 | 2818 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 98.2% | 2724 | 2773 |
| use_cases:use_case[3D_printing_flow] | use_cases:use_case[controlling_the_audio] | 61.2% | 99.9% | 4599 | 2817 |
| use_cases:use_case[calling_my_mcp_server] | use_cases:use_case[controlling_the_audio] | 68.3% | 99.9% | 4118 | 2817 |
| use_cases:use_case[choices] | use_cases:use_case[controlling_the_audio] | 85.4% | 99.9% | 3295 | 2817 |
| use_cases:use_case[controlling_the_audio] | use_cases:use_case[python_command] | 99.9% | 90.5% | 2817 | 3110 |
| use_cases:use_case[controlling_the_audio] | use_cases:use_case[wrapping_a_cloud_provider_cli] | 99.9% | 68.1% | 2817 | 4134 |
| use_cases:use_case[global_workflow_local_implementation] | use_cases:use_case[using_a_project] | 99.9% | 88.5% | 3600 | 4063 |
| alias:can_use_a_flow_in_an_alias | flow:reuse_flow_parameters | 77.7% | 99.8% | 3142 | 2446 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.1% | 3060 | 3212 |
| alias:capture_partial_flow | flow:extend_flow | 99.8% | 94.5% | 3042 | 3212 |
| alias:capture_partial_flow | use_cases:use_case[3D_printing_flow] | 99.8% | 66.0% | 3042 | 4599 |
| alias:simple_alias_command | use_cases:use_case[global_workflow_local_implementation] | 99.8% | 81.4% | 2935 | 3600 |
| alias:simple_alias_command | use_cases:use_case[podcast_automation] | 99.8% | 78.1% | 2935 | 3753 |
| ... | *3898 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:use_case[3D_printing_flow] | 4599 |
| use_cases:use_case[creating_extensions] | 4480 |
| use_cases:use_case[backing_up_documents] | 4310 |
| use_cases:use_case[controlling_my_music] | 4187 |
| use_cases:use_case[wrapping_a_cloud_provider_cli] | 4134 |
| use_cases:use_case[calling_my_mcp_server] | 4118 |
| use_cases:use_case[using_a_project] | 4063 |
| use_cases:use_case[self_documentation] | 3971 |
| use_cases:use_case[ethereum_local_environment_dev_tool] | 3867 |
| use_cases:use_case[podcast_automation] | 3753 |
| command:command | 3640 |
| use_cases:use_case[global_workflow_local_implementation] | 3600 |
| use_cases:use_case[setting_default_values] | 3596 |
| use_cases:use_case[using_a_plugin] | 3574 |
| custom:capture_alias | 3532 |
| use_cases:use_case[checking_my_server] | 3503 |
| use_cases:use_case[dynamic_parameters_and_exposed_class] | 3470 |
| use_cases:use_case[alias_to_root] | 3450 |
| help:main_help | 3414 |
| use_cases:use_case[bash_command_use_option] | 3376 |
| ... | *81 more tests* |
