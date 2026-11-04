# jaffle_shop: team rules

These rules apply to every change in this repo.

- Column names use full words from the glossary: `customer_id`, `order_id`, `order_date`,
  `total_amount`, `last_name`. Never abbreviate or truncate a column name.
- Never rename or remove a column that a contracted model or an exposure reads. Add the new
  column, migrate consumers, then remove the old column in a later PR.
- Do not commit scratch, test or marker files. Every committed file belongs to the dbt
  project, its docs, or its CI.
- Every model change keeps `models/**/schema.yml` in step: a column renamed in SQL is renamed
  in its schema entry in the same PR.
