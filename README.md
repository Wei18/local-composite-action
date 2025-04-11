
# 📦 local-composite-action

A GitHub Action to conveniently reference local Composite Actions!

## ✨ Features

- ✅ Automatically resolves the local composite action path
- ✅ Creates symlinks to support `uses: ./local/path` references
- ✅ Compatible with default GitHub Actions behavior
- ✅ Supports `.yaml` and `.yml`

---

## 🔧 Usage

### Step 1: Add this action to your composite action

```yaml
- name: Resolve local composite action path
  uses: wei18/local-composite-action@main
  with:
    composite_action_path: ${{ github.action_path }}
    composite_action_repository: ${{ github.action_repository }}
```

### Step 2: Use local path to call the composite action

```yaml
- name: Run local composite action
  uses: ./../org/repo/.github/composite-actions/example/just-composite-action
```
> [!IMPORTANT] 
> Adjust the relative path based on the symlink location (typically one level above `$GITHUB_WORKSPACE`).
>
> This version emphasizes that `./../` is required and clarifies why it needs to be used.

---

## 📥 Inputs

| Name                     | Description                                 | Required | Default        |
|--------------------------|---------------------------------------------|----------|----------------|
| `composite_action_path`  | The actual path to the composite action      | ✅       | –              |
| `composite_action_repository` | The repository name in the form of `org/repo` | ✅       | –              |
| `action_filename`        | The filename for the composite action (`.yml` or `.yaml`) | ❌       | `action.yml`   |

---

## 🧪 Example
https://github.com/Wei18/local-composite-action/blob/9ccc99757989905871bacddf88f8a95215bdc9dc/.github/composite-actions/example/action.yml#L1-L17

---

## 💡 Why this?

In GitHub Actions, the `composite` action supports `uses: ./local-path`, but when dealing with monorepos or complex path references, symlinks may not exist, causing failures. This tool helps automatically create the required symlinks, making the references work seamlessly!

---

## 📄 License

MIT © [wei18](https://github.com/wei18)
