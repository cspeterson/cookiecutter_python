"""End-to-end tests"""

import pytest  # type:ignore

import {{cookiecutter.project_name}}.__main__ as program  # type:ignore


def test_main() -> None:
    """Test"""
    with pytest.raises(SystemExit):
        program.main()
