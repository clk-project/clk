# Test Duplication Report

**Similarity Threshold:** 30.0%

## Exact Duplicates (Identical Coverage)

Found 1 groups with 1 duplicate tests:


### Group 1 (2 tests):
  - command:dynamic_default_value
  - command:dynamic_default_value_callback

  **Action**: Keep one test, remove 1 duplicates


## Subset Duplicates

Found 20 tests that are subsets of others (showing top 20 by coverage ratio):


  - `custom:group_python` is 99.9% covered by `types:default_with_converter`
    **Action**: Consider removing if no unique edge cases


  - `completion:group` is 99.7% covered by `completion:dynamic_group`
    **Action**: Consider removing if no unique edge cases


  - `alias:alias_conserves_parameters_of_group` is 99.7% covered by `alias:alias_conserves_parameters_of_group_with_exposed_class`
    **Action**: Consider removing if no unique edge cases


  - `types:default_with_converter` is 99.7% covered by `types:date`
    **Action**: Consider removing if no unique edge cases


  - `command:dynamic_default_value` is 99.6% covered by `command:dynamic_default_value_callback_that_depends_on_another_param`
    **Action**: Consider removing if no unique edge cases


  - `command:dynamic_default_value_callback` is 99.6% covered by `command:dynamic_default_value_callback_that_depends_on_another_param`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 99.6% covered by `types:suggestion`
    **Action**: Consider removing if no unique edge cases


  - `custom:group_python` is 99.6% covered by `types:date`
    **Action**: Consider removing if no unique edge cases


  - `alias:alias_conserves_parameters_of_group` is 99.4% covered by `alias:alias_overrides_parameters`
    **Action**: Consider removing if no unique edge cases


  - `custom:group_python` is 99.4% covered by `custom:simple_python`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 98.8% covered by `types:complete_date`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 98.1% covered by `completion:group`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 97.8% covered by `completion:dynamic_group`
    **Action**: Consider removing if no unique edge cases


  - `parameter:removing_parameters` is 97.3% covered by `parameter:using_automatic_options`
    **Action**: Consider removing if no unique edge cases


  - `types:default_with_converter` is 96.9% covered by `types:suggestion`
    **Action**: Consider removing if no unique edge cases


  - `custom:group_python` is 96.8% covered by `types:suggestion`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 92.5% covered by `completion:completion_with_saved_parameter`
    **Action**: Consider removing if no unique edge cases


  - `command:dynamic_default_value_callback_that_depends_on_another_param` is 76.5% covered by `alias:alias_conserves_parameters_of_group_with_exposed_class`
    **Action**: Consider removing if no unique edge cases


  - `command:dynamic_default_value` is 76.2% covered by `alias:alias_conserves_parameters_of_group_with_exposed_class`
    **Action**: Consider removing if no unique edge cases


  - `command:dynamic_default_value_callback` is 76.2% covered by `alias:alias_conserves_parameters_of_group_with_exposed_class`
    **Action**: Consider removing if no unique edge cases


## Similar Tests (≥30% overlap)

Found 4012 test pairs with ≥30% similarity (showing top 20):


  - `custom:group_python` ↔ `types:default_with_converter`: 99.9% similar
    **Action**: Review for potential merge or refactoring


  - `completion:dynamic_group` ↔ `completion:group`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `alias:alias_conserves_parameters_of_group` ↔ `alias:alias_conserves_parameters_of_group_with_exposed_class`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `alias:alias_conserves_parameters_of_group_with_exposed_class` ↔ `alias:alias_overrides_parameters`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `types:date` ↔ `types:default_with_converter`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `command:dynamic_default_value` ↔ `command:dynamic_default_value_callback_that_depends_on_another_param`: 99.6% similar
    **Action**: Review for potential merge or refactoring


  - `command:dynamic_default_value_callback` ↔ `command:dynamic_default_value_callback_that_depends_on_another_param`: 99.6% similar
    **Action**: Review for potential merge or refactoring


  - `completion:command` ↔ `types:suggestion`: 99.6% similar
    **Action**: Review for potential merge or refactoring


  - `custom:group_python` ↔ `types:date`: 99.6% similar
    **Action**: Review for potential merge or refactoring


  - `alias:alias_conserves_parameters_of_group` ↔ `alias:alias_overrides_parameters`: 99.4% similar
    **Action**: Review for potential merge or refactoring


  - `custom:group_python` ↔ `custom:simple_python`: 99.4% similar
    **Action**: Review for potential merge or refactoring


  - `custom:simple_python` ↔ `types:default_with_converter`: 99.3% similar
    **Action**: Review for potential merge or refactoring


  - `alias:capture_flow_command` ↔ `alias:capture_partial_flow`: 99.3% similar
    **Action**: Review for potential merge or refactoring


  - `extension:copy_extension` ↔ `extension:move_extension`: 99.2% similar
    **Action**: Review for potential merge or refactoring


  - `parameter:removing_parameters` ↔ `parameter:replacing_parameters`: 99.2% similar
    **Action**: Review for potential merge or refactoring


  - `flow:flow_in_aliases` ↔ `flow:flow_not_captured_if_consumed`: 99.0% similar
    **Action**: Review for potential merge or refactoring


  - `custom:simple_python` ↔ `types:date`: 99.0% similar
    **Action**: Review for potential merge or refactoring


  - `completion:command` ↔ `types:complete_date`: 98.8% similar
    **Action**: Review for potential merge or refactoring


  - `parameter:editing_parameters` ↔ `parameter:replacing_parameters`: 98.6% similar
    **Action**: Review for potential merge or refactoring


  - `types:complete_date` ↔ `types:suggestion`: 98.5% similar
    **Action**: Review for potential merge or refactoring


  ... and 3992 more similar test pairs


## Summary

- Total tests analyzed: 102
- Exact duplicates: 1 tests can be removed
- Subset duplicates: 20 tests may be redundant
- Similar tests: 4012 pairs need review