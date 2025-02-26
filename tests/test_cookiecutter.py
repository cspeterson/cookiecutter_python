"""
test
"""

import subprocess

from datetime import datetime

from typing import Any, Dict

import pytest

import pytest_cookies  # type: ignore

NAME: str = "project_name"

CONTEXT: Dict[str, str] = {
    "person_or_organization_name": "person_or_organization_name",
    "person_or_organization_website": "person_or_organization_website",
}


@pytest.fixture(name="bake_result", scope="function")
def fixture_bake_result(cookies: Any) -> pytest_cookies.plugin.Result:
    """
    test
    """
    return cookies.bake(extra_context=CONTEXT)


def test_bake_project(bake_result: pytest_cookies.plugin.Result) -> None:
    """
    test
    """
    # result = cookies.bake(extra_context={"repo_name": NAME})

    assert bake_result.exit_code == 0
    assert bake_result.exception is None

    assert bake_result.project_path.name == NAME
    assert bake_result.project_path.is_dir()


def test_license(bake_result: pytest_cookies.plugin.Result) -> None:
    """
    test
    """
    thisyear: int = datetime.now().year
    with open(bake_result.project_path / "LICENSE", "r", encoding="utf-8") as lic_file:
        top_line: str = lic_file.readline()
    assert str(thisyear) in top_line
    for key in CONTEXT:
        assert key in top_line


def test_tests(bake_result: pytest_cookies.plugin.Result) -> None:
    """
    Verify that this project deploys into a "useable" state with passing tests
    """
    subprocess.run(
        ["make"],
        cwd=bake_result.project_path,
        check=True,
    )
