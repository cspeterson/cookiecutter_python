"[Cookiecutter] is a command-line utility that creates projects from project templates, e.g. creating a Python package project from a Python package project template."

This is my Cookiecutter template for new generic Python CLI projects

# Usage

```sh
cookiecutter https://github.com/cspeterson/cookiecutter_python
```

# What

This template deploys a basic Python CLI project into a fully "working" state  (it succeeds at doing nothing) with all tests passing.

Tests include static analysis by `mypy`, `pylint`, and `black` and units tests using `pytest`.

GitHub workflows are included to test all commits and to publish releases.

[Cookiecutter]: https://pypi.org/project/cookiecutter/
