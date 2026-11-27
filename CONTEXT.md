# Context

Domain language for foundry and the specimens grown from it. Status: draft.

The repository still uses the older term **layer** (`layers/`, `LAYER.md`, `register_layer.rb`). A layer is a trait. The rename is not done yet.

## Glossary

| Term | Meaning |
|------|---------|
| **Trait** | A unit of change, described in `TRAIT.md`. Its id is the foundry commit SHA that introduced it. A trait is either behavioural or a medium trait. |
| **Behavioural trait** | A trait that works in any medium, for example `session`. Its specs are tech-agnostic. |
| **Medium trait** | A trait that only exists in one medium, for example Standard Ruby linting or `routing_and_service_architecture`. Shared by every specimen in that medium, whatever its strain. Its specs may be specific to the medium. |
| **Medium** | The runtime or stack a specimen grows in, for example Ruby on Rails or Go. A medium has its own pathway of medium traits. |
| **Spec** | An integration or end-to-end test of a trait, driven over HTTP or a browser, with a bias towards security. A trait has many specs. |
| **Key spec** | The one end-to-end happy-path spec of a trait. Mutants of other traits run against it. |
| **Pathway** | The transitive upstream and downstream dependencies between traits. A parent is upstream of its children. |
| **Strain** | A named set of behavioural traits in foundry. It includes every trait upstream of its members. A strain has no medium, so it can grow in any medium. |
| **Catalogue** | Foundry: holds traits, specs, strains and media. |
| **Specimen** | A repository grown from one strain in one medium, for example `rails-template`. Grown one expression at a time, upstream first, starting with the medium traits. Its git history records the growth. |
| **Expression** | One trait as built in a specimen. A specimen has exactly one expression per trait in its strain and per trait of its medium. An expression has many blobs and many mutants. |
| **Blob** | One file of an expression, identified by git blob SHA and path. |
| **Mutant** | A change to one expression, at one locus, that must fail a target spec. Mutants live in the specimen repository. |
| **Locus** | Where a mutant changes code: one blob of its expression, plus start and end line:char. Points to the diff between the blob and the mutant. |
| **Screen** | One CI run of a specimen commit. Records many observations. Lives in the specimen repository. |
| **Observation** | One spec run under one mutant, or under the unmutated baseline: passed or failed. |
| **Phenotype** | All observations of one mutant. Derived, not stored. |

## Rules

- **Valid spec.** Every spec passes on the baseline, and at least one mutant fails it.
- **Independence.** A mutant of trait A fails its target spec, and passes the key spec of every trait not downstream of A: upstream traits and traits outside A's pathway alike. Only key specs are checked, to keep screens affordable. A mutant that breaks a non-key spec of such a trait can go unnoticed; this trade-off is accepted.
- **Complete strain.** A strain contains every trait upstream of its members.
- **Portable strain.** A behavioural trait never has a medium trait as a parent. A specimen grows its medium traits first, and its behavioural expressions build on them, so the same strain can grow in any medium.
- **Medium pathway.** A medium trait may only have parents in the same medium.
- **Complete specimen.** A specimen has one expression per trait in its strain and its medium, no more and no fewer.
- **Iterative growth.** A specimen is grown, not built in one shot. Each step adds one expression and its mutants, medium traits first and then in pathway order, and its screen passes before the next step starts.

## Model

```mermaid
flowchart LR
    subgraph foundry["foundry (catalogue)"]
        T["TRAIT<br/>id: commit sha<br/>name, parents<br/>kind: behavioural or medium<br/>TRAIT.md"]
        S["SPEC<br/>id, trait_id<br/>integration / e2e<br/>security flag, key flag<br/>(key = one e2e happy path per trait)<br/>HTTP or browser driver"]
        ST["STRAIN<br/>name<br/>set of behavioural traits"]
        MD["MEDIUM<br/>name, e.g. Ruby on Rails, Go<br/>set of medium traits"]
        T -->|"upstream of (pathway, transitive)"| T
        T -->|"specified by (1..many)"| S
        ST -->|"includes many"| T
        MD -->|"includes many"| T
    end

    subgraph repo["specimen repo (e.g. rails-template)"]
        R["SPECIMEN<br/>repo, commit sha"]
        E["EXPRESSION<br/>one per trait in strain + medium"]
        B["BLOB<br/>blob sha, path"]
        M["MUTANT<br/>id, target spec_id"]
        L["LOCUS<br/>id, blob sha<br/>start line:char<br/>end line:char"]
        D["DIFF<br/>original blob → mutant"]
        SC["SCREEN (CI run)<br/>specimen commit, run id"]
        O["OBSERVATION<br/>spec × mutant or baseline<br/>passed?"]
        R -->|"has one per trait"| E
        E -->|"has many"| B
        E -->|"has many"| M
        M -->|"mutates at"| L
        L -->|"in one"| B
        L -->|"points to"| D
        R -->|"screened by"| SC
        SC -->|"records many"| O
        M -->|"observed in"| O
    end

    R -->|"grown from"| ST
    R -->|"grown in"| MD
    E -->|"expresses"| T
    M -->|"must fail target spec"| S
    M -.->|"must pass key spec of every trait not downstream"| S
    S -->|"observed in"| O
```
