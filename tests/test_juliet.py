#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Tests for `juliet` package."""

import pytest

from click.testing import CliRunner

from juliet import juliet
from juliet import cli


@pytest.fixture
def response():
    """Sample pytest fixture.

    See more at: http://doc.pytest.org/en/latest/fixture.html
    """
    # import requests
    # return requests.get('https://github.com/audreyr/cookiecutter-pypackage')
    pass


def test_content(response):
    """Sample pytest test function with the pytest fixture as an argument."""
    j = juliet.Julia()
    # let's test a built in function with a single argument
    assert 1.4 < j.function('sqrt', 2.0) < 1.5
    # let's test a built in function with multiple arguments
    #assert j.function('isequal', 1.0, 1.0) == True
    #assert j.function('isequal', 1.0, 2.0) == False

def test_command_line_interface():
    """Test the CLI."""
    runner = CliRunner()
    result = runner.invoke(cli.main)
    assert result.exit_code == 0
    assert 'juliet.cli.main' in result.output
    help_result = runner.invoke(cli.main, ['--help'])
    assert help_result.exit_code == 0
    assert '--help  Show this message and exit.' in help_result.output
