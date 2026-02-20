# Test Coverage Overlap Report

## Summary

- **Total tests:** 104
- **Full subsets (100%):** 78
- **High overlap (≥75%):** 4480
- **Significant overlap (≥50%):** 4676

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2940 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2669 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3120 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3120 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3129 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2472 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2472 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2481 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2482 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2472 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2472 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2481 |
| command:dynamic_option | alias:alias_overrides_parameters | 2482 |
| alias:composite_alias | alias:simple_alias_command | 2876 |
| alias:simple_alias_command | alias:composite_alias | 2876 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2472 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2472 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2472 |
| command:dynamic_default_value | command:dynamic_option | 2472 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2472 |
| command:dynamic_default_value_callback | command:dynamic_option | 2472 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2481 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2482 |
| completion:command | completion:completion_with_saved_parameter | 2983 |
| completion:command | completion:dynamic_command | 2983 |
| completion:command | completion:dynamic_group | 2983 |
| completion:command | completion:group | 2983 |
| completion:command | types:complete_date | 2983 |
| completion:command | types:suggestion | 2983 |
| custom:group_python | completion:completion_with_saved_parameter | 2900 |
| completion:dynamic_command | completion:dynamic_group | 3025 |
| completion:dynamic_group | completion:dynamic_command | 3025 |
| completion:group | completion:dynamic_command | 3017 |
| completion:group | completion:dynamic_group | 3017 |
| custom:group_python | custom:simple_python | 2900 |
| custom:group_python | types:date | 2900 |
| custom:group_python | types:default_with_converter | 2900 |
| custom:group_python | types:suggestion | 2900 |
| parameter:simple_parameter | extension:copy_extension | 2669 |
| parameter:simple_parameter | extension:move_extension | 2669 |
| flow:overwrite_flow | flow:extend_flow | 3259 |
| parameter:simple_parameter | parameter:appending_parameters | 2669 |
| parameter:appending_parameters | parameter:using_automatic_options | 2677 |
| parameter:simple_parameter | parameter:parameter_precedence | 2669 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2669 |
| parameter:simple_parameter | parameter:removing_parameters | 2669 |
| parameter:removing_parameters | parameter:using_automatic_options | 2691 |
| parameter:simple_parameter | parameter:replacing_parameters | 2669 |
| parameter:simple_parameter | parameter:using_automatic_options | 2669 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2669 |
| types:default_with_converter | types:date | 2902 |
| types:default_with_converter | types:suggestion | 2902 |
| use_cases:environment_deployment | use_cases:3D_printing_flow | 3231 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command | 2912 |
| use_cases:bash_command_import | use_cases:bash_command | 3163 |
| use_cases:hello_world | use_cases:bash_command | 3143 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_import | 2912 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_use_option | 2912 |
| use_cases:bash_command_built_in_lib | use_cases:choices | 2912 |
| use_cases:bash_command_built_in_lib | use_cases:ethereum_local_environment_dev_tool | 2912 |
| use_cases:bash_command_built_in_lib | use_cases:hello_world | 2912 |
| use_cases:bash_command_built_in_lib | use_cases:ipfs_name_publish | 2912 |
| use_cases:bash_command_built_in_lib | use_cases:multi_environment_deployment_tool | 2912 |
| use_cases:bash_command_built_in_lib | use_cases:self_documentation | 2912 |
| use_cases:bash_command_built_in_lib | use_cases:send_sms | 2912 |
| use_cases:bash_command_built_in_lib | use_cases:wrapping_a_cloud_provider_cli | 2912 |
| use_cases:bash_command_import | use_cases:bash_command_use_option | 3163 |
| use_cases:bash_command_import | use_cases:ipfs_name_publish | 3163 |
| use_cases:bash_command_import | use_cases:multi_environment_deployment_tool | 3163 |
| use_cases:bash_command_import | use_cases:send_sms | 3163 |
| use_cases:bash_command_import | use_cases:wrapping_a_cloud_provider_cli | 3163 |
| use_cases:hello_world | use_cases:choices | 3143 |
| use_cases:dynamic_parameters_advanced_use_cases | use_cases:dynamic_parameters_and_exposed_class | 2963 |
| use_cases:environment_deployment | use_cases:ethereum_local_environment_dev_tool | 3231 |
| use_cases:environment_deployment | use_cases:podcast_automation | 3231 |
| use_cases:hello_world | use_cases:ethereum_local_environment_dev_tool | 3143 |
| use_cases:scrapping_the_web | use_cases:ethereum_local_environment_dev_tool | 2993 |
| use_cases:hello_world | use_cases:ipfs_name_publish | 3143 |
| use_cases:hello_world | use_cases:multi_environment_deployment_tool | 3143 |
| use_cases:hello_world | use_cases:send_sms | 3143 |
| use_cases:hello_world | use_cases:wrapping_a_cloud_provider_cli | 3143 |
| use_cases:multi_environment_deployment_tool | use_cases:wrapping_a_cloud_provider_cli | 3225 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 90.8% | 99.9% | 2940 | 2672 |
| alias:alias_conserves_parameters | use_cases:3D_printing_flow | 99.9% | 74.1% | 2940 | 3963 |
| alias:alias_conserves_parameters | use_cases:using_a_project | 99.9% | 85.9% | 2940 | 3421 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.8% | 99.9% | 3120 | 2804 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3129 | 2804 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3137 | 2804 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.4% | 99.9% | 3111 | 3093 |
| alias:composite_alias | use_cases:using_a_project | 99.9% | 84.0% | 2876 | 3421 |
| alias:simple_alias_command | use_cases:using_a_project | 99.9% | 84.0% | 2876 | 3421 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3079 | 2902 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3079 | 2993 |
| custom:default_help_message_triggers_a_warning | use_cases:ethereum_local_environment_dev_tool | 99.9% | 80.6% | 3141 | 3893 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2916 | 2902 |
| extension:copy_extension | parameter:replacing_parameters | 85.5% | 99.9% | 3124 | 2672 |
| extension:move_extension | parameter:replacing_parameters | 85.1% | 99.9% | 3136 | 2672 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2677 | 2672 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.8% | 99.9% | 3008 | 2672 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.7% | 99.9% | 2945 | 2672 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2691 | 2672 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.5% | 2672 | 2768 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2672 | 2728 |
| parameter:replacing_parameters | use_cases:using_a_project | 99.9% | 78.0% | 2672 | 3421 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.0% | 2669 | 2930 |
| parameter:simple_parameter | use_cases:3D_printing_flow | 99.9% | 67.2% | 2669 | 3963 |
| parameter:simple_parameter | use_cases:using_a_project | 99.9% | 78.0% | 2669 | 3421 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_from_alias | 99.9% | 73.5% | 2912 | 3959 |
| use_cases:bash_command_from_alias | use_cases:bash_command_import | 79.8% | 99.9% | 3959 | 3163 |
| use_cases:bash_command_import | use_cases:hello_world | 99.3% | 99.9% | 3163 | 3143 |
| use_cases:bash_command_use_option | use_cases:hello_world | 95.8% | 99.9% | 3277 | 3143 |
| use_cases:dynamic_parameters_and_exposed_class | use_cases:environment_deployment | 93.5% | 99.9% | 3453 | 3231 |
| ... | *4372 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:self_documentation | 4079 |
| use_cases:3D_printing_flow | 3963 |
| use_cases:bash_command_from_alias | 3959 |
| use_cases:ethereum_local_environment_dev_tool | 3893 |
| use_cases:creating_extensions | 3788 |
| use_cases:setting_default_values | 3750 |
| command:command | 3640 |
| use_cases:wrapping_a_cloud_provider_cli | 3530 |
| custom:capture_alias | 3507 |
| help:main_help | 3473 |
| use_cases:dynamic_parameters_and_exposed_class | 3453 |
| use_cases:using_a_project | 3421 |
| custom:cannot_remove_existing_command | 3404 |
| use_cases:ipfs_name_publish | 3365 |
| use_cases:podcast_automation | 3364 |
| use_cases:choices | 3363 |
| use_cases:dealing_with_secrets | 3357 |
| use_cases:using_a_plugin | 3354 |
| use_cases:send_sms | 3320 |
| flow:dump_flowdeps | 3295 |
| ... | *84 more tests* |
