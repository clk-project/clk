# Test Coverage Overlap Report

## Summary

- **Total tests:** 106
- **Full subsets (100%):** 81
- **High overlap (≥75%):** 4504
- **Significant overlap (≥50%):** 4699

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2938 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2667 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3117 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3117 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3126 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2469 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2469 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2478 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2479 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2469 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2469 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2478 |
| command:dynamic_option | alias:alias_overrides_parameters | 2479 |
| alias:composite_alias | alias:simple_alias_command | 2874 |
| alias:simple_alias_command | alias:composite_alias | 2874 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2469 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2469 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2469 |
| command:dynamic_default_value | command:dynamic_option | 2469 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2469 |
| command:dynamic_default_value_callback | command:dynamic_option | 2469 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2478 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2479 |
| completion:command | completion:completion_with_saved_parameter | 2980 |
| completion:command | completion:dynamic_command | 2980 |
| completion:command | completion:dynamic_group | 2980 |
| completion:command | completion:group | 2980 |
| completion:command | types:complete_date | 2980 |
| completion:command | types:suggestion | 2980 |
| custom:group_python | completion:completion_with_saved_parameter | 2897 |
| completion:dynamic_command | completion:dynamic_group | 3022 |
| completion:dynamic_group | completion:dynamic_command | 3022 |
| completion:group | completion:dynamic_command | 3014 |
| completion:group | completion:dynamic_group | 3014 |
| custom:group_python | custom:simple_python | 2897 |
| custom:group_python | types:date | 2897 |
| custom:group_python | types:default_with_converter | 2897 |
| custom:group_python | types:suggestion | 2897 |
| parameter:simple_parameter | extension:copy_extension | 2667 |
| parameter:simple_parameter | extension:move_extension | 2667 |
| flow:overwrite_flow | flow:extend_flow | 3256 |
| lib:which | lib:check_output_on_path | 14 |
| lib:flat_map | use_cases:3D_printing_flow | 2 |
| lib:which | lib:safe_check_output_on_path | 14 |
| parameter:simple_parameter | parameter:appending_parameters | 2667 |
| parameter:appending_parameters | parameter:using_automatic_options | 2675 |
| parameter:simple_parameter | parameter:parameter_precedence | 2667 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2667 |
| parameter:simple_parameter | parameter:removing_parameters | 2667 |
| parameter:removing_parameters | parameter:using_automatic_options | 2689 |
| parameter:simple_parameter | parameter:replacing_parameters | 2667 |
| parameter:simple_parameter | parameter:using_automatic_options | 2667 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2667 |
| types:default_with_converter | types:date | 2899 |
| types:default_with_converter | types:suggestion | 2899 |
| use_cases:environment_deployment | use_cases:3D_printing_flow | 3225 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command | 2908 |
| use_cases:bash_command_import | use_cases:bash_command | 3155 |
| use_cases:hello_world | use_cases:bash_command | 3136 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_import | 2908 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_use_option | 2908 |
| use_cases:bash_command_built_in_lib | use_cases:choices | 2908 |
| use_cases:bash_command_built_in_lib | use_cases:ethereum_local_environment_dev_tool | 2908 |
| use_cases:bash_command_built_in_lib | use_cases:hello_world | 2908 |
| use_cases:bash_command_built_in_lib | use_cases:ipfs_name_publish | 2908 |
| use_cases:bash_command_built_in_lib | use_cases:multi_environment_deployment_tool | 2908 |
| use_cases:bash_command_built_in_lib | use_cases:self_documentation | 2908 |
| use_cases:bash_command_built_in_lib | use_cases:send_sms | 2908 |
| use_cases:bash_command_built_in_lib | use_cases:wrapping_a_cloud_provider_cli | 2908 |
| use_cases:bash_command_import | use_cases:bash_command_use_option | 3155 |
| use_cases:bash_command_import | use_cases:ipfs_name_publish | 3155 |
| use_cases:bash_command_import | use_cases:multi_environment_deployment_tool | 3155 |
| use_cases:bash_command_import | use_cases:send_sms | 3155 |
| use_cases:bash_command_import | use_cases:wrapping_a_cloud_provider_cli | 3155 |
| use_cases:hello_world | use_cases:choices | 3136 |
| use_cases:dynamic_parameters_advanced_use_cases | use_cases:dynamic_parameters_and_exposed_class | 2957 |
| use_cases:environment_deployment | use_cases:ethereum_local_environment_dev_tool | 3225 |
| use_cases:environment_deployment | use_cases:podcast_automation | 3225 |
| use_cases:hello_world | use_cases:ethereum_local_environment_dev_tool | 3136 |
| use_cases:scrapping_the_web | use_cases:ethereum_local_environment_dev_tool | 2987 |
| use_cases:hello_world | use_cases:ipfs_name_publish | 3136 |
| use_cases:hello_world | use_cases:multi_environment_deployment_tool | 3136 |
| use_cases:hello_world | use_cases:send_sms | 3136 |
| use_cases:hello_world | use_cases:wrapping_a_cloud_provider_cli | 3136 |
| use_cases:multi_environment_deployment_tool | use_cases:wrapping_a_cloud_provider_cli | 3217 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 90.8% | 99.9% | 2938 | 2670 |
| alias:alias_conserves_parameters | use_cases:3D_printing_flow | 99.9% | 74.1% | 2938 | 3957 |
| alias:alias_conserves_parameters | use_cases:using_a_project | 99.9% | 89.2% | 2938 | 3290 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.8% | 99.9% | 3117 | 2801 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3126 | 2801 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3134 | 2801 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.4% | 99.9% | 3108 | 3090 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.1% | 99.9% | 3076 | 2899 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3076 | 2990 |
| custom:default_help_message_triggers_a_warning | use_cases:ethereum_local_environment_dev_tool | 99.9% | 80.8% | 3139 | 3878 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2913 | 2899 |
| extension:copy_extension | parameter:replacing_parameters | 85.5% | 99.9% | 3121 | 2670 |
| extension:move_extension | parameter:replacing_parameters | 85.2% | 99.9% | 3133 | 2670 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2675 | 2670 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.8% | 99.9% | 3006 | 2670 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.7% | 99.9% | 2943 | 2670 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2689 | 2670 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.5% | 2670 | 2766 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2670 | 2726 |
| parameter:replacing_parameters | use_cases:using_a_project | 99.9% | 81.0% | 2670 | 3290 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.0% | 2667 | 2927 |
| parameter:simple_parameter | use_cases:3D_printing_flow | 99.9% | 67.3% | 2667 | 3957 |
| parameter:simple_parameter | use_cases:using_a_project | 99.9% | 81.0% | 2667 | 3290 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_from_alias | 99.9% | 73.5% | 2908 | 3951 |
| use_cases:bash_command_from_alias | use_cases:bash_command_import | 79.8% | 99.9% | 3951 | 3155 |
| use_cases:bash_command_import | use_cases:hello_world | 99.3% | 99.9% | 3155 | 3136 |
| use_cases:bash_command_use_option | use_cases:hello_world | 95.9% | 99.9% | 3269 | 3136 |
| use_cases:dynamic_parameters_and_exposed_class | use_cases:environment_deployment | 93.4% | 99.9% | 3447 | 3225 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.1% | 3108 | 3262 |
| alias:capture_flow_command | flow:overwrite_flow | 99.8% | 95.3% | 3108 | 3256 |
| ... | *4393 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:self_documentation | 4064 |
| use_cases:3D_printing_flow | 3957 |
| use_cases:bash_command_from_alias | 3951 |
| use_cases:ethereum_local_environment_dev_tool | 3878 |
| use_cases:creating_extensions | 3782 |
| use_cases:setting_default_values | 3744 |
| command:command | 3638 |
| use_cases:wrapping_a_cloud_provider_cli | 3515 |
| custom:capture_alias | 3506 |
| help:main_help | 3471 |
| use_cases:dynamic_parameters_and_exposed_class | 3447 |
| custom:cannot_remove_existing_command | 3402 |
| use_cases:podcast_automation | 3358 |
| use_cases:ipfs_name_publish | 3357 |
| use_cases:choices | 3355 |
| use_cases:dealing_with_secrets | 3351 |
| use_cases:using_a_plugin | 3348 |
| use_cases:send_sms | 3312 |
| flow:dump_flowdeps | 3292 |
| use_cases:using_a_project | 3290 |
| ... | *86 more tests* |
