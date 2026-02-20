# Test Coverage Overlap Report

## Summary

- **Total tests:** 106
- **Full subsets (100%):** 81
- **High overlap (≥75%):** 4504
- **Significant overlap (≥50%):** 4737

## Full Subsets (100% overlap)

These tests have coverage completely contained within another test:

| Test | Contained In | Lines |
|------|--------------|-------|
| alias:alias_conserves_parameters | parameter:parameter_to_alias | 3037 |
| parameter:simple_parameter | alias:alias_conserves_parameters | 2768 |
| alias:alias_conserves_parameters_of_group | alias:alias_conserves_parameters_of_group_with_exposed_class | 3118 |
| alias:alias_conserves_parameters_of_group | alias:alias_overrides_parameters | 3118 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | alias:alias_overrides_parameters | 3127 |
| command:dynamic_default_value | alias:alias_conserves_parameters_of_group_with_exposed_class | 2470 |
| command:dynamic_default_value_callback | alias:alias_conserves_parameters_of_group_with_exposed_class | 2470 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_conserves_parameters_of_group_with_exposed_class | 2479 |
| command:dynamic_option | alias:alias_conserves_parameters_of_group_with_exposed_class | 2480 |
| command:dynamic_default_value | alias:alias_overrides_parameters | 2470 |
| command:dynamic_default_value_callback | alias:alias_overrides_parameters | 2470 |
| command:dynamic_default_value_callback_that_depends_on_another_param | alias:alias_overrides_parameters | 2479 |
| command:dynamic_option | alias:alias_overrides_parameters | 2480 |
| alias:composite_alias | alias:simple_alias_command | 2974 |
| alias:simple_alias_command | alias:composite_alias | 2974 |
| command:dynamic_default_value | command:dynamic_default_value_callback | 2470 |
| command:dynamic_default_value_callback | command:dynamic_default_value | 2470 |
| command:dynamic_default_value | command:dynamic_default_value_callback_that_depends_on_another_param | 2470 |
| command:dynamic_default_value | command:dynamic_option | 2470 |
| command:dynamic_default_value_callback | command:dynamic_default_value_callback_that_depends_on_another_param | 2470 |
| command:dynamic_default_value_callback | command:dynamic_option | 2470 |
| command:dynamic_default_value_callback_that_depends_on_another_param | command:dynamic_option | 2479 |
| command:dynamic_option | command:dynamic_default_value_callback_that_depends_on_another_param | 2480 |
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
| parameter:simple_parameter | extension:copy_extension | 2768 |
| parameter:simple_parameter | extension:move_extension | 2768 |
| flow:overwrite_flow | flow:extend_flow | 3257 |
| lib:which | lib:check_output_on_path | 14 |
| lib:flat_map | use_cases:3D_printing_flow | 2 |
| lib:which | lib:safe_check_output_on_path | 14 |
| parameter:simple_parameter | parameter:appending_parameters | 2768 |
| parameter:appending_parameters | parameter:using_automatic_options | 2775 |
| parameter:simple_parameter | parameter:parameter_precedence | 2768 |
| parameter:simple_parameter | parameter:parameter_to_alias | 2768 |
| parameter:simple_parameter | parameter:removing_parameters | 2768 |
| parameter:removing_parameters | parameter:using_automatic_options | 2788 |
| parameter:simple_parameter | parameter:replacing_parameters | 2768 |
| parameter:simple_parameter | parameter:using_automatic_options | 2768 |
| parameter:simple_parameter | parameter_eval:use_value_as_parameter | 2768 |
| types:default_with_converter | types:date | 2899 |
| types:default_with_converter | types:suggestion | 2899 |
| use_cases:environment_deployment | use_cases:3D_printing_flow | 3223 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command | 2906 |
| use_cases:bash_command_import | use_cases:bash_command | 3153 |
| use_cases:hello_world | use_cases:bash_command | 3134 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_import | 2906 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_use_option | 2906 |
| use_cases:bash_command_built_in_lib | use_cases:choices | 2906 |
| use_cases:bash_command_built_in_lib | use_cases:ethereum_local_environment_dev_tool | 2906 |
| use_cases:bash_command_built_in_lib | use_cases:hello_world | 2906 |
| use_cases:bash_command_built_in_lib | use_cases:ipfs_name_publish | 2906 |
| use_cases:bash_command_built_in_lib | use_cases:multi_environment_deployment_tool | 2906 |
| use_cases:bash_command_built_in_lib | use_cases:self_documentation | 2906 |
| use_cases:bash_command_built_in_lib | use_cases:send_sms | 2906 |
| use_cases:bash_command_built_in_lib | use_cases:wrapping_a_cloud_provider_cli | 2906 |
| use_cases:bash_command_import | use_cases:bash_command_use_option | 3153 |
| use_cases:bash_command_import | use_cases:ipfs_name_publish | 3153 |
| use_cases:bash_command_import | use_cases:multi_environment_deployment_tool | 3153 |
| use_cases:bash_command_import | use_cases:send_sms | 3153 |
| use_cases:bash_command_import | use_cases:wrapping_a_cloud_provider_cli | 3153 |
| use_cases:hello_world | use_cases:choices | 3134 |
| use_cases:dynamic_parameters_advanced_use_cases | use_cases:dynamic_parameters_and_exposed_class | 2955 |
| use_cases:environment_deployment | use_cases:ethereum_local_environment_dev_tool | 3223 |
| use_cases:environment_deployment | use_cases:podcast_automation | 3223 |
| use_cases:hello_world | use_cases:ethereum_local_environment_dev_tool | 3134 |
| use_cases:scrapping_the_web | use_cases:ethereum_local_environment_dev_tool | 2985 |
| use_cases:hello_world | use_cases:ipfs_name_publish | 3134 |
| use_cases:hello_world | use_cases:multi_environment_deployment_tool | 3134 |
| use_cases:hello_world | use_cases:send_sms | 3134 |
| use_cases:hello_world | use_cases:wrapping_a_cloud_provider_cli | 3134 |
| use_cases:multi_environment_deployment_tool | use_cases:wrapping_a_cloud_provider_cli | 3215 |

## High Overlap (≥75%)

| Test A | Test B | A→B % | B→A % | Lines A | Lines B |
|--------|--------|-------|-------|---------|---------|
| alias:alias_conserves_parameters | parameter:replacing_parameters | 91.1% | 99.9% | 3037 | 2770 |
| alias:alias_conserves_parameters_of_group | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.8% | 99.9% | 3118 | 2802 |
| alias:alias_conserves_parameters_of_group_with_exposed_class | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.5% | 99.9% | 3127 | 2802 |
| alias:alias_overrides_parameters | command:invoked_commands_still_work_even_though_they_are_no_customizable | 89.3% | 99.9% | 3135 | 2802 |
| alias:capture_flow_command | alias:capture_partial_flow | 99.4% | 99.9% | 3109 | 3091 |
| completion:completion_with_saved_parameter | types:default_with_converter | 94.1% | 99.9% | 3076 | 2899 |
| completion:completion_with_saved_parameter | types:suggestion | 97.1% | 99.9% | 3076 | 2990 |
| custom:default_help_message_triggers_a_warning | use_cases:ethereum_local_environment_dev_tool | 99.9% | 80.8% | 3136 | 3876 |
| custom:simple_python | types:default_with_converter | 99.5% | 99.9% | 2913 | 2899 |
| extension:copy_extension | parameter:replacing_parameters | 88.7% | 99.9% | 3120 | 2770 |
| extension:move_extension | parameter:replacing_parameters | 88.6% | 99.9% | 3125 | 2770 |
| parameter:appending_parameters | parameter:replacing_parameters | 99.7% | 99.9% | 2775 | 2770 |
| parameter:parameter_precedence | parameter:replacing_parameters | 89.1% | 99.9% | 3106 | 2770 |
| parameter:parameter_to_alias | parameter:replacing_parameters | 91.0% | 99.9% | 3042 | 2770 |
| parameter:removing_parameters | parameter:replacing_parameters | 99.3% | 99.9% | 2788 | 2770 |
| parameter:replacing_parameters | parameter:using_automatic_options | 99.9% | 96.6% | 2770 | 2865 |
| parameter:replacing_parameters | parameter_eval:use_value_as_parameter | 99.9% | 98.0% | 2770 | 2825 |
| parameter:simple_parameter | run:can_edit_parameters | 99.9% | 94.4% | 2768 | 2928 |
| use_cases:bash_command_built_in_lib | use_cases:bash_command_from_alias | 99.9% | 73.5% | 2906 | 3949 |
| use_cases:bash_command_from_alias | use_cases:bash_command_import | 79.8% | 99.9% | 3949 | 3153 |
| use_cases:bash_command_import | use_cases:hello_world | 99.3% | 99.9% | 3153 | 3134 |
| use_cases:bash_command_use_option | use_cases:hello_world | 95.9% | 99.9% | 3267 | 3134 |
| use_cases:dynamic_parameters_and_exposed_class | use_cases:environment_deployment | 93.4% | 99.9% | 3445 | 3223 |
| alias:alias_conserves_parameters | use_cases:3D_printing_flow | 99.8% | 76.6% | 3037 | 3955 |
| alias:alias_conserves_parameters | use_cases:using_a_project | 99.8% | 92.2% | 3037 | 3288 |
| alias:capture_flow_command | flow:extend_flow | 99.8% | 95.1% | 3109 | 3263 |
| alias:capture_flow_command | flow:overwrite_flow | 99.8% | 95.3% | 3109 | 3257 |
| alias:capture_partial_flow | flow:extend_flow | 99.8% | 94.5% | 3091 | 3263 |
| alias:capture_partial_flow | flow:overwrite_flow | 99.8% | 94.7% | 3091 | 3257 |
| cache:cache | use_cases:ethereum_local_environment_dev_tool | 99.8% | 62.0% | 2411 | 3876 |
| ... | *4393 more* | | | | |

## Test Sizes

| Test | Lines Covered |
|------|---------------|
| use_cases:self_documentation | 4062 |
| use_cases:3D_printing_flow | 3955 |
| use_cases:bash_command_from_alias | 3949 |
| use_cases:ethereum_local_environment_dev_tool | 3876 |
| command:command | 3789 |
| use_cases:creating_extensions | 3780 |
| use_cases:setting_default_values | 3742 |
| help:main_help | 3640 |
| custom:capture_alias | 3596 |
| use_cases:wrapping_a_cloud_provider_cli | 3513 |
| use_cases:dynamic_parameters_and_exposed_class | 3445 |
| custom:cannot_remove_existing_command | 3400 |
| use_cases:podcast_automation | 3356 |
| use_cases:ipfs_name_publish | 3355 |
| use_cases:choices | 3353 |
| use_cases:dealing_with_secrets | 3349 |
| use_cases:using_a_plugin | 3346 |
| use_cases:send_sms | 3310 |
| flow:dump_flowdeps | 3293 |
| use_cases:using_a_project | 3288 |
| ... | *86 more tests* |
