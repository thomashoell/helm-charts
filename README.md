# Quick start

Helm charts for my own tools. Add the repository with:

```bash
helm repo add thomashoell https://thomashoell.github.io/helm-charts/
helm repo update
helm search repo thomashoell
```

Every release is also pushed to GHCR as an OCI artifact:

```bash
helm install sunspec-exporter oci://ghcr.io/thomashoell/charts/sunspec-exporter --version <version>
```

New chart: let the release workflow do the first push. A package pushed by hand starts **private** on GHCR
(visibility can't be changed via API or Tofu) – then once in the package settings: Manage Actions access →
`thomashoell/helm-charts` (Write), Change visibility → Public.

# Available Helm charts

| Chart | Description |
| --- | --- |
| [sunspec-exporter](charts/sunspec-exporter) | [Prometheus exporter for SunSpec/Modbus PV inverters](https://github.com/thomashoell/sunspec-exporter) |

# Releases

Same pipeline as [dreitier/helm-charts](https://github.com/dreitier/helm-charts):

- PRs are squash-merged; the PR title (Conventional Commit, checked by `pr-title.yaml`) becomes the commit
  message on `main`.
- `release.yaml` runs semantic-release per chart (only commits touching `charts/<chart>/`): `feat` → minor,
  `fix` → patch, `!`/`BREAKING CHANGE` → major. It bumps `version` in `Chart.yaml`, syncs `appVersion` from
  `image.tag` in `values.yaml` (other path: annotation `thomashoell.github.io/app-version-from`), updates
  `CHANGELOG.md`, tags `<chart>-<version>` and pushes with the GitHub App `thomashoell-release-bot` (the only
  actor allowed to push to `main`).
- chart-releaser packages unreleased versions, creates the GitHub release and updates `index.yaml` on `gh-pages`.
- Dependabot keeps image tags, chart dependencies, actions and pre-commit hooks up to date – except
  sunspec-exporter: its release workflow sends a `repository_dispatch` (`sunspec-exporter-released`), and
  `update-sunspec-exporter.yaml` opens/updates the PR `update/sunspec-exporter` that bumps `image.tag`
  (patch → `fix`, minor → `feat`, major → `feat!`). Run it by hand via *Actions → Update sunspec-exporter*.

Local checks: `pip install pre-commit && pre-commit install`, `pre-commit run --all-files`.
