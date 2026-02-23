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
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 2955 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2686 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3140 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3140 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3149 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2477 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2477 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2486 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2487 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2477 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2477 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2486 |
| command:dynamic_option | alias:alias_overrides_parameters | 2487 |
| alias:composite_alias | alias:simple_alias_command | 2891 |
| alias:simple_alias_command | alias:composite_alias | 2891 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2477 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2477 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2477 |
| command:dynamic_default_value | command:dynamic_option | 2477 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2477 |
| command:dynamic_default_value_callback | command:dynamic_option | 2477 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2486 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2487 |
| completion:command | completion:completion_with_saved_parameter | 2997 |
| completion:command | completion:dynamic_command | 2997 |
| completion:command | completion:dynamic_group | 2997 |
| completion:command | completion:group | 2997 |
| completion:command | types:complete_date | 2997 |
| completion:command | types:suggestion | 2997 |
| custom:group_python | completion:completion_with_saved_parameter | 2914 |
| completion:dynamic_command | completion:dynamic_group | 3055 |
| completion:dynamic_group | completion:dynamic_command | 3055 |
| completion:group | completion:dynamic_command | 3047 |
| completion:group | completion:dynamic_group | 3047 |
| custom:group_python | custom:simple_python | 2914 |
| custom:group_python | types:date | 2914 |
| custom:group_python | types:default_with_converter | 2914 |
| custom:group_python | types:suggestion | 2914 |
| parameter:simple_parameter | extension:copy_extension | 2686 |
| parameter:simple_parameter | extension:move_extension | 2686 |
| flow:overwrite_flow | flow:extend_flow | 3268 |
| parameter:simple_parameter | parameter:appending_parameters | 2686 |
| parameter:appending_parameters | parameter:using_automatic_options | 2694 |
| parameter:simple_parameter | parameter:parameter_precedence | 2686 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2686 |
| parameter:simple_parameter | parameter:removing_parameters | 2686 |
| parameter:removing_parameters | parameter:using_automatic_options | 2708 |
| parameter:simple_parameter | parameter:replacing_parameters | 2686 |
| parameter:simple_parameter | parameter:using_automatic_options | 2686 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2686 |
| types:default_with_converter | types:date | 2916 |
| types:default_with_converter | types:suggestion | 2916 |
| use_cases:environment_deployment | use_cases:3D_printing_flow | 3242 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command | 2928 |
| use_cases:bash_command_import | use_cases:bash_command | 3177 |
| use_cases:hello_world | use_cases:bash_command | 3150 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_import | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_use_option | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:choices | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:ethereum_local_environment_dev_tool | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:hello_world | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:ipfs_name_publish | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:multi_environment_deployment_tool | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:self_documentation | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:send_sms | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:wrapping_a_cloud_provider_cli | 2928 |
| use_cases:bash_command_import | use_cases:bash_command_use_option | 3177 |
| use_cases:bash_command_import | use_cases:ipfs_name_publish | 3177 |
| use_cases:bash_command_import | use_cases:multi_environment_deployment_tool | 3177 |
| use_cases:bash_command_import | use_cases:send_sms | 3177 |
| use_cases:bash_command_import | use_cases:wrapping_a_cloud_provider_cli | 3177 |
| use_cases:hello_world | use_cases:choices | 3150 |
| use_cases:dynamic_parameters_advanced_use_cases | use_cases:dynamic_parameters_and_exposed_class | 2970 |
| use_cases:environment_deployment | use_cases:ethereum_local_environment_dev_tool | 3242 |
| use_cases:environment_deployment | use_cases:podcast_automation | 3242 |
| use_cases:hello_world | use_cases:ethereum_local_environment_dev_tool | 3150 |
| use_cases:scrapping_the_web | use_cases:ethereum_local_environment_dev_tool | 3000 |
| use_cases:hello_world | use_cases:ipfs_name_publish | 3150 |
| use_cases:hello_world | use_cases:multi_environment_deployment_tool | 3150 |
| use_cases:hello_world | use_cases:send_sms | 3150 |
| use_cases:hello_world | use_cases:wrapping_a_cloud_provider_cli | 3150 |
| use_cases:multi_environment_deployment_tool | use_cases:wrapping_a_cloud_provider_cli | 3244 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 90.9% | 99.9% | 2955 | 2689 |
| alias:alias_conserves_parameters | use_cases:3D_printing_flow | 99.9% | 73.9% | 2955 | 3994 |
| alias:alias_conserves_parameters | use_cases:using_a_project | 99.9% | 85.7% | 2955 | 3447 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.4% | 99.9% | 3140 | 2809 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.1% | 99.9% | 3149 | 2809 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 88.9% | 99.9% | 3157 | 2809 |
| alias:composite_alias | use_cases:using_a_project | 99.9% | 83.8% | 2891 | 3447 |
| alias:simple_alias_command | use_cases:using_a_project | 99.9% | 83.8% | 2891 | 3447 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.2% | 99.9% | 3093 | 2916 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3093 | 3007 |
| custom:default_help_message_triggers_a_warning | use_cases:ethereum_local_environment_dev_tool | 99.9% | 80.3% | 3149 | 3915 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2930 | 2916 |
| extension:copy_extension | parameter:replacing_parameters | 85.6% | 99.9% | 3138 | 2689 |
| extension:move_extension | parameter:replacing_parameters | 85.3% | 99.9% | 3150 | 2689 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2694 | 2689 |
| parameter:parameter_precedence | parameter:replacing_parameters | 88.8% | 99.9% | 3025 | 2689 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 90.8% | 99.9% | 2960 | 2689 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.2% | 99.9% | 2708 | 2689 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.5% | 2689 | 2785 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 97.9% | 2689 | 2745 |
| parameter:replacing_parameters | use_cases:using_a_project | 99.9% | 77.9% | 2689 | 3447 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 91.4% | 2686 | 2935 |
| parameter:simple_parameter | use_cases:3D_printing_flow | 99.9% | 67.2% | 2686 | 3994 |
| parameter:simple_parameter | use_cases:using_a_project | 99.9% | 77.9% | 2686 | 3447 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_from_alias | 99.9% | 73.2% | 2928 | 3995 |
| use_cases:bash_command_from_alias | use_cases:bash_command_import | 79.4% | 99.9% | 3995 | 3177 |
| use_cases:bash_command_import | use_cases:hello_world | 99.1% | 99.9% | 3177 | 3150 |
| use_cases:bash_command_use_option | use_cases:hello_world | 95.7% | 99.9% | 3291 | 3150 |
| use_cases:dynamic_parameters_and_exposed_class | use_cases:environment_deployment | 93.0% | 99.9% | 3482 | 3242 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.0% | 3114 | 3274 |
| ... | *4372 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:self_documentation | 4087 |
| use_cases:bash_command_from_alias | 3995 |
| use_cases:3D_printing_flow | 3994 |
| use_cases:ethereum_local_environment_dev_tool | 3915 |
| use_cases:creating_extensions | 3808 |
| use_cases:setting_default_values | 3762 |
| command:command | 3680 |
| use_cases:wrapping_a_cloud_provider_cli | 3547 |
| custom:capture_alias | 3522 |
| help:main_help | 3506 |
| use_cases:dynamic_parameters_and_exposed_class | 3482 |
| use_cases:using_a_project | 3447 |
| custom:cannot_remove_existing_command | 3416 |
| use_cases:ipfs_name_publish | 3408 |
| use_cases:choices | 3394 |
| use_cases:podcast_automation | 3391 |
| use_cases:using_a_plugin | 3376 |
| use_cases:dealing_with_secrets | 3364 |
| use_cases:send_sms | 3358 |
| flow:dump_flowdeps | 3313 |
| ... | *84 more tests* |
