> [!NOTE]
> **This is a fork, extended as the demo target for [dbt-sentinel](https://github.com/jashansadioura32/dbt-sentinel).**
> It is the repo dbt-sentinel raises pull requests against. See
> [Extensions for dbt-sentinel](#extensions-for-dbt-sentinel) below for what was added and why.

> [!IMPORTANT]
> This repo is no longer actively maintained. It’s been preserved for continuity and free access. The Jaffle Shop has lived a rich life as dbt’s demo project, but has been superseded by two newer repositories: [`jaffle-shop`](https://github.com/dbt-labs/jaffle-shop), the premier demo project for dbt Cloud, and [`jaffle_shop_duckdb`](https://github.com/dbt-labs/jaffle_shop_duckdb) which supports working locally via DuckDB for those without access to a cloud warehouse. You’re welcome to continue using this repo as an open source resource, just know it will not be actively maintained moving forward.

## Testing dbt project: `jaffle_shop`

`jaffle_shop` is a fictional ecommerce store. This dbt project transforms raw data from an app database into a customers and orders model ready for analytics.

### What is this repo?
What this repo _is_:
- A self-contained playground dbt project, useful for testing out scripts, and communicating some of the core dbt concepts.

What this repo _is not_:
- A tutorial — check out the [Getting Started Tutorial](https://docs.getdbt.com/tutorial/setting-up) for that. Notably, this repo contains some anti-patterns to make it self-contained, namely the use of seeds instead of sources.
- A demonstration of best practices — check out the [dbt Learn Demo](https://github.com/dbt-labs/dbt-learn-demo) repo instead. We want to keep this project as simple as possible. As such, we chose not to implement:
    - our standard file naming patterns (which make more sense on larger projects, rather than this five-model project)
    - a pull request flow
    - CI/CD integrations
- A demonstration of using dbt for a high-complex project, or a demo of advanced features (e.g. macros, packages, hooks, operations) — we're just trying to keep things simple here!

### What's in this repo?
This repo contains [seeds](https://docs.getdbt.com/docs/building-a-dbt-project/seeds) that includes some (fake) raw data from a fictional app.

The raw data consists of customers, orders, and payments, with the following entity-relationship diagram:

![Jaffle Shop ERD](/etc/jaffle_shop_erd.png)


### Running this project
To get up and running with this project:
1. Install dbt using [these instructions](https://docs.getdbt.com/docs/installation).

2. Clone this repository.

3. Change into the `jaffle_shop` directory from the command line:
```bash
$ cd jaffle_shop
```

4. Set up a profile called `jaffle_shop` to connect to a data warehouse by following [these instructions](https://docs.getdbt.com/docs/configure-your-profile). If you have access to a data warehouse, you can use those credentials – we recommend setting your [target schema](https://docs.getdbt.com/docs/configure-your-profile#section-populating-your-profile) to be a new schema (dbt will create the schema for you, as long as you have the right privileges). If you don't have access to an existing data warehouse, you can also setup a local postgres database and connect to it in your profile.

5. Ensure your profile is setup correctly from the command line:
```bash
$ dbt debug
```

6. Load the CSVs with the demo data set. This materializes the CSVs as tables in your target schema. Note that a typical dbt project **does not require this step** since dbt assumes your raw data is already in your warehouse.
```bash
$ dbt seed
```

7. Run the models:
```bash
$ dbt run
```

> **NOTE:** If this steps fails, it might mean that you need to make small changes to the SQL in the models folder to adjust for the flavor of SQL of your target database. Definitely consider this if you are using a community-contributed adapter.

8. Test the output of the models:
```bash
$ dbt test
```

9. Generate documentation for the project:
```bash
$ dbt docs generate
```

10. View the documentation for the project:
```bash
$ dbt docs serve
```

### What is a jaffle?
A jaffle is a toasted sandwich with crimped, sealed edges. Invented in Bondi in 1949, the humble jaffle is an Australian classic. The sealed edges allow jaffle-eaters to enjoy liquid fillings inside the sandwich, which reach temperatures close to the core of the earth during cooking. Often consumed at home after a night out, the most classic filling is tinned spaghetti, while my personal favourite is leftover beef stew with melted cheese.

---
For more information on dbt:
- Read the [introduction to dbt](https://docs.getdbt.com/docs/introduction).
- Read the [dbt viewpoint](https://docs.getdbt.com/docs/about/viewpoint).
- Join the [dbt community](http://community.getdbt.com/).
---

---

## Extensions for dbt-sentinel

Upstream `jaffle_shop` is five models with no marts, no exposures and no contracts, so
it never exercises the signals dbt-sentinel scores on. This fork adds the missing
surface:

| Added | Why |
|---|---|
| `models/marts/fct_order_payments.sql` | An **incremental, contracted** model. Contract enforcement and `unique_key` edits are the highest-severity structural changes. |
| `models/marts/rpt_customer_revenue.sql` | A reporting model with `access: public`, giving the graph a public-access node. |
| `models/exposures.yml` | Three exposures with named owners. `BlastRadius.exposures` is the loudest severity signal and had nothing to read without them. |
| `models/staging/sources.yml` | Declares real sources so source-column changes resolve to a node. |
| `models/staging/stg_raw_events.sql` | A staging model with PII-ish columns, for the `pii-tagging` policy rule. |
| `profiles.yml` | Local DuckDB profile, so the project builds with no warehouse credentials. |

### Why `target/manifest.json` is committed

dbt-sentinel reads the model graph from the compiled manifest. Its CI-artifact download
is not implemented yet, so a manifest committed on the base branch is the only source it
can currently resolve. `.gitignore` excludes `target/*` by contents and re-includes this
one file.

**Regenerate it after any model change, or the blast radius is computed against a stale
graph:**

```bash
DBT_PROFILES_DIR=. dbt compile
git add target/manifest.json
```

### Build it locally

```bash
pip install dbt-core dbt-duckdb
DBT_PROFILES_DIR=. dbt seed
DBT_PROFILES_DIR=. dbt build     # 37 pass, 0 errors
DBT_PROFILES_DIR=. dbt compile   # regenerates target/manifest.json
```

### Run dbt-sentinel against a change

```bash
git diff main...HEAD | python -m dbt_sentinel   --manifest target/manifest.json --diff - --explain --fail-on high
```

Renaming `customer_id` in `models/staging/stg_orders.sql` should report HIGH, 7
downstream nodes, 1 contracted model and 3 exposures.

