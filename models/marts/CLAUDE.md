# Marts rules

- Marts select explicit columns from staging models. Every selected column has an alias
  that matches the contract in `models/marts/schema.yml`.
- A contracted mart's output columns change only through a new model version.
