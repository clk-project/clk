---
title: Coverage Reports
---

# Coverage Reports

Coverage reports are automatically generated and committed by CI on each push to main.

## Reports

- [TestIQ Report](./reports/testiq-report.md) - Test duplicate/redundancy analysis
- [Overlap Report](./reports/overlap.md) - Test coverage overlap analysis
- [Line Heat Map](./reports/line-heat.md) - Lines covered by many tests

## Interactive HTML Reports

For interactive HTML reports with filtering and drill-down features, run locally:

```bash
earthly +sanity-check
# Reports saved to output/coverage-reports/
```
