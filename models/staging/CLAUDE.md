# Staging rules

- Staging models only rename and cast source columns. No joins, no aggregation.
- Each staging model keeps its primary key tested with `unique` and `not_null`.
- Do not leave debug comments (for example `-- testing`) in committed SQL.
