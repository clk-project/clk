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
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3116 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3116 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3125 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2468 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2468 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2477 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2478 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2468 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2468 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2477 |
| command:dynamic_option | alias:alias_overrides_parameters | 2478 |
| alias:composite_alias | alias:simple_alias_command | 2874 |
| alias:simple_alias_command | alias:composite_alias | 2874 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2468 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2468 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2468 |
| command:dynamic_default_value | command:dynamic_option | 2468 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2468 |
| command:dynamic_default_value_callback | command:dynamic_option | 2468 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2477 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2478 |
| completion:command | completion:completion_with_saved_parameter | 2979 |
| completion:command | completion:dynamic_command | 2979 |
| completion:command | completion:dynamic_group | 2979 |
| completion:command | completion:group | 2979 |
| completion:command | types:complete_date | 2979 |
| completion:command | types:suggestion | 2979 |
| custom:group_python | completion:completion_with_saved_parameter | 2896 |
| completion:dynamic_command | completion:dynamic_group | 3021 |
| completion:dynamic_group | completion:dynamic_command | 3021 |
| completion:group | completion:dynamic_command | 3013 |
| completion:group | completion:dynamic_group | 3013 |
| custom:group_python | custom:simple_python | 2896 |
| custom:group_python | types:date | 2896 |
| custom:group_python | types:default_with_converter | 2896 |
| custom:group_python | types:suggestion | 2896 |
| parameter:simple_parameter | extension:copy_extension | 2667 |
| parameter:simple_parameter | extension:move_extension | 2667 |
| flow:overwrite_flow | flow:extend_flow | 3255 |
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
| types:default_with_converter | types:date | 2898 |
| types:default_with_converter | types:suggestion | 2898 |
| use_cases:environment_deployment | use_cases:3D_printing_flow | 3224 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command | 2907 |
| use_cases:bash_command_import | use_cases:bash_command | 3154 |
| use_cases:hello_world | use_cases:bash_command | 3135 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_import | 2907 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_use_option | 2907 |
| use_cases:bash_command_built_in_lib | use_cases:choices | 2907 |
| use_cases:bash_command_built_in_lib | use_cases:ethereum_local_environment_dev_tool | 2907 |
| use_cases:bash_command_built_in_lib | use_cases:hello_world | 2907 |
| use_cases:bash_command_built_in_lib | use_cases:ipfs_name_publish | 2907 |
| use_cases:bash_command_built_in_lib | use_cases:multi_environment_deployment_tool | 2907 |
| use_cases:bash_command_built_in_lib | use_cases:self_documentation | 2907 |
| use_cases:bash_command_built_in_lib | use_cases:send_sms | 2907 |
| use_cases:bash_command_built_in_lib | use_cases:wrapping_a_cloud_provider_cli | 2907 |
| use_cases:bash_command_import | use_cases:bash_command_use_option | 3154 |
| use_cases:bash_command_import | use_cases:ipfs_name_publish | 3154 |
| use_cases:bash_command_import | use_cases:multi_environment_deployment_tool | 3154 |
| use_cases:bash_command_import | use_cases:send_sms | 3154 |
| use_cases:bash_command_import | use_cases:wrapping_a_cloud_provider_cli | 3154 |
| use_cases:hello_world | use_cases:choices | 3135 |
| use_cases:dynamic_parameters_advanced_use_cases | use_cases:dynamic_parameters_and_exposed_class | 2956 |
| use_cases:environment_deployment | use_cases:ethereum_local_environment_dev_tool | 3224 |
| use_cases:environment_deployment | use_cases:podcast_automation | 3224 |
| use_cases:hello_world | use_cases:ethereum_local_environment_dev_tool | 3135 |
| use_cases:scrapping_the_web | use_cases:ethereum_local_environment_dev_tool | 2986 |
| use_cases:hello_world | use_cases:ipfs_name_publish | 3135 |
| use_cases:hello_world | use_cases:multi_environment_deployment_tool | 3135 |
| use_cases:hello_world | use_cases:send_sms | 3135 |
| use_cases:hello_world | use_cases:wrapping_a_cloud_provider_cli | 3135 |
| use_cases:multi_environment_deployment_tool | use_cases:wrapping_a_cloud_provider_cli | 3216 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 90.8% | 99.9% | 2938 | 2670 |
| alias:alias_conserves_parameters | use_cases:3D_printing_flow | 99.9% | 74.2% | 2938 | 3956 |
| alias:alias_conserves_parameters | use_cases:using_a_project | 99.9% | 89.3% | 2938 | 3289 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.8% | 99.9% | 3116 | 2800 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3125 | 2800 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3133 | 2800 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.4% | 99.9% | 3107 | 3089 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.1% | 99.9% | 3075 | 2898 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3075 | 2989 |
| custom:default_help_message_triggers_a_warning | use_cases:ethereum_local_environment_dev_tool | 99.9% | 80.8% | 3138 | 3877 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2912 | 2898 |
| extension:copy_extension | parameter:replacing_parameters | 85.5% | 99.9% | 3120 | 2670 |
| extension:move_extension | parameter:replacing_parameters | 85.2% | 99.9% | 3132 | 2670 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2675 | 2670 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.8% | 99.9% | 3006 | 2670 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.7% | 99.9% | 2943 | 2670 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2689 | 2670 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.5% | 2670 | 2766 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2670 | 2726 |
| parameter:replacing_parameters | use_cases:using_a_project | 99.9% | 81.1% | 2670 | 3289 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.0% | 2667 | 2926 |
| parameter:simple_parameter | use_cases:3D_printing_flow | 99.9% | 67.3% | 2667 | 3956 |
| parameter:simple_parameter | use_cases:using_a_project | 99.9% | 81.0% | 2667 | 3289 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_from_alias | 99.9% | 73.5% | 2907 | 3950 |
| use_cases:bash_command_from_alias | use_cases:bash_command_import | 79.8% | 99.9% | 3950 | 3154 |
| use_cases:bash_command_import | use_cases:hello_world | 99.3% | 99.9% | 3154 | 3135 |
| use_cases:bash_command_use_option | use_cases:hello_world | 95.9% | 99.9% | 3268 | 3135 |
| use_cases:dynamic_parameters_and_exposed_class | use_cases:environment_deployment | 93.4% | 99.9% | 3446 | 3224 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.1% | 3107 | 3261 |
| alias:capture_flow_command | flow:overwrite_flow | 99.8% | 95.3% | 3107 | 3255 |
| ... | *4393 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:self_documentation | 4063 |
| use_cases:3D_printing_flow | 3956 |
| use_cases:bash_command_from_alias | 3950 |
| use_cases:ethereum_local_environment_dev_tool | 3877 |
| use_cases:creating_extensions | 3781 |
| use_cases:setting_default_values | 3743 |
| command:command | 3638 |
| use_cases:wrapping_a_cloud_provider_cli | 3514 |
| custom:capture_alias | 3506 |
| help:main_help | 3471 |
| use_cases:dynamic_parameters_and_exposed_class | 3446 |
| custom:cannot_remove_existing_command | 3401 |
| use_cases:podcast_automation | 3357 |
| use_cases:ipfs_name_publish | 3356 |
| use_cases:choices | 3354 |
| use_cases:dealing_with_secrets | 3350 |
| use_cases:using_a_plugin | 3347 |
| use_cases:send_sms | 3311 |
| flow:dump_flowdeps | 3291 |
| use_cases:using_a_project | 3289 |
| ... | *86 more tests* |
