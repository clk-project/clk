# Test Duplication Report

**Similarity Threshold:** 30.0%

## Exact Duplicates (Identical Coverage)

Found 3 groups with 4 duplicate tests:


### Group 1 (2 tests):
  - alias:composite_alias
  - alias:simple_alias_command

  **Action**: Keep one test, remove 1 duplicates


### Group 2 (3 tests):
  - command:dynamic_default_value
  - command:dynamic_default_value_callback
  - command:dynamic_default_value_callback_that_depends_on_another_param

  **Action**: Keep one test, remove 2 duplicates


### Group 3 (2 tests):
  - completion:dynamic_command
  - completion:dynamic_group

  **Action**: Keep one test, remove 1 duplicates


## Subset Duplicates

Found 38 tests that are subsets of others (showing top 20 by coverage ratio):


  - `command:dynamic_default_value` is 100.0% covered by `command:dynamic_option`
    **Action**: Consider removing if no unique edge cases


  - `command:dynamic_default_value_callback` is 100.0% covered by `command:dynamic_option`
    **Action**: Consider removing if no unique edge cases


  - `command:dynamic_default_value_callback_that_depends_on_another_param` is 100.0% covered by `command:dynamic_option`
    **Action**: Consider removing if no unique edge cases


  - `custom:group_python` is 99.9% covered by `types:default_with_converter`
    **Action**: Consider removing if no unique edge cases


  - `parameter:simple_parameter` is 99.9% covered by `parameter:replacing_parameters`
    **Action**: Consider removing if no unique edge cases


  - `flow:overwrite_flow` is 99.8% covered by `flow:extend_flow`
    **Action**: Consider removing if no unique edge cases


  - `parameter:simple_parameter` is 99.7% covered by `parameter:appending_parameters`
    **Action**: Consider removing if no unique edge cases


  - `completion:group` is 99.7% covered by `completion:dynamic_command`
    **Action**: Consider removing if no unique edge cases


  - `completion:group` is 99.7% covered by `completion:dynamic_group`
    **Action**: Consider removing if no unique edge cases


  - `alias:alias_conserves_parameters_of_group` is 99.7% covered by `alias:alias_conserves_parameters_of_group_with_exposed_class`
    **Action**: Consider removing if no unique edge cases


  - `types:default_with_converter` is 99.7% covered by `types:date`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 99.7% covered by `types:suggestion`
    **Action**: Consider removing if no unique edge cases


  - `custom:group_python` is 99.6% covered by `types:date`
    **Action**: Consider removing if no unique edge cases


  - `alias:alias_conserves_parameters_of_group` is 99.6% covered by `alias:alias_overrides_parameters`
    **Action**: Consider removing if no unique edge cases


  - `custom:group_python` is 99.5% covered by `custom:simple_python`
    **Action**: Consider removing if no unique edge cases


  - `parameter:simple_parameter` is 99.3% covered by `parameter:removing_parameters`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 99.2% covered by `completion:group`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 98.9% covered by `completion:dynamic_command`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 98.9% covered by `completion:dynamic_group`
    **Action**: Consider removing if no unique edge cases


  - `completion:command` is 98.9% covered by `types:complete_date`
    **Action**: Consider removing if no unique edge cases


  ... and 18 more subset duplicates


## Similar Tests (≥30% overlap)

Found 2211 test pairs with ≥30% similarity (showing top 20):


  - `command:dynamic_default_value` ↔ `command:dynamic_option`: 100.0% similar
    **Action**: Review for potential merge or refactoring


  - `command:dynamic_default_value_callback` ↔ `command:dynamic_option`: 100.0% similar
    **Action**: Review for potential merge or refactoring


  - `command:dynamic_default_value_callback_that_depends_on_another_param` ↔ `command:dynamic_option`: 100.0% similar
    **Action**: Review for potential merge or refactoring


  - `custom:group_python` ↔ `types:default_with_converter`: 99.9% similar
    **Action**: Review for potential merge or refactoring


  - `parameter:replacing_parameters` ↔ `parameter:simple_parameter`: 99.9% similar
    **Action**: Review for potential merge or refactoring


  - `flow:extend_flow` ↔ `flow:overwrite_flow`: 99.8% similar
    **Action**: Review for potential merge or refactoring


  - `alias:alias_conserves_parameters_of_group_with_exposed_class` ↔ `alias:alias_overrides_parameters`: 99.8% similar
    **Action**: Review for potential merge or refactoring


  - `alias:alias_conserves_parameters` ↔ `parameter:parameter_to_alias`: 99.8% similar
    **Action**: Review for potential merge or refactoring


  - `parameter:appending_parameters` ↔ `parameter:simple_parameter`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `completion:dynamic_command` ↔ `completion:group`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `completion:dynamic_group` ↔ `completion:group`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `alias:alias_conserves_parameters_of_group` ↔ `alias:alias_conserves_parameters_of_group_with_exposed_class`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `types:date` ↔ `types:default_with_converter`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `parameter:appending_parameters` ↔ `parameter:replacing_parameters`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `completion:command` ↔ `types:suggestion`: 99.7% similar
    **Action**: Review for potential merge or refactoring


  - `custom:group_python` ↔ `types:date`: 99.6% similar
    **Action**: Review for potential merge or refactoring


  - `alias:alias_conserves_parameters_of_group` ↔ `alias:alias_overrides_parameters`: 99.6% similar
    **Action**: Review for potential merge or refactoring


  - `custom:group_python` ↔ `custom:simple_python`: 99.5% similar
    **Action**: Review for potential merge or refactoring


  - `custom:simple_python` ↔ `types:default_with_converter`: 99.4% similar
    **Action**: Review for potential merge or refactoring


  - `alias:capture_flow_command` ↔ `alias:capture_partial_flow`: 99.3% similar
    **Action**: Review for potential merge or refactoring


  ... and 2191 more similar test pairs


## Summary

- Total tests analyzed: 78
- Exact duplicates: 4 tests can be removed
- Subset duplicates: 38 tests may be redundant
- Similar tests: 2211 pairs need review
