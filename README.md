
# 📦 local-composite-action

A GitHub Action to conveniently reference local actions!

## ✨ Features

- ✅ Automatically resolves the local composite action path
- ✅ Creates symlinks to support `uses: ./local/path` references
- ✅ Compatible with default GitHub Actions behavior

---

## 🔧 Usage

```yaml
name: Your composite action

runs:
  using: 'composite'
  steps:
    - uses: wei18/local-composite-action@v1
    
    - name: Run local your composite action
      uses: ./../org/repo/.github/composite-actions/example/just-composite-action

    - name: Run local your second composite action
      uses: ./../org/repo/.github/composite-actions/example/another-composite-action
```

> [!IMPORTANT] 
> Adjust the relative path based on the symlink location (typically one level above `$GITHUB_WORKSPACE`).
>
> This version emphasizes that `./../` is required and clarifies why it needs to be used.

---

## 📥 Inputs

| Name                | Description                                   | Default                         |
|---------------------|-----------------------------------------------|---------------------------------|
| `action_path`       | The actual path to the composite action       | ${{ github.action_path }}       |
| `action_repository` | The repository name in the form of `org/repo` | ${{ github.action_repository }} |

---

## 💡 Why this?

In GitHub Actions, the `composite` action supports `uses: ./local-path`, but when dealing with monorepos or complex path references, symlinks may not exist, causing failures. This tool helps automatically create the required symlinks, making the references work seamlessly!

---

## 📄 License

MIT © [wei18](https://github.com/wei18)
