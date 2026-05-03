from datetime import date, timedelta

from api.prediction import CATEGORY_RUNOUT_DAYS, DEFAULT_RUNOUT_DAYS, predict_runout_date


def test_known_categories():
    base = date(2024, 1, 1)
    for category, days in CATEGORY_RUNOUT_DAYS.items():
        result = predict_runout_date(category, base)
        assert result == base + timedelta(days=days), f"Failed for category: {category}"


def test_unknown_category_uses_default():
    base = date(2024, 1, 1)
    assert predict_runout_date("mystery item", base) == base + timedelta(days=DEFAULT_RUNOUT_DAYS)


def test_none_category_uses_default():
    base = date(2024, 1, 1)
    assert predict_runout_date(None, base) == base + timedelta(days=DEFAULT_RUNOUT_DAYS)


def test_case_insensitive():
    base = date(2024, 6, 15)
    assert predict_runout_date("DAIRY", base) == predict_runout_date("dairy", base)
    assert predict_runout_date("Produce", base) == predict_runout_date("produce", base)


def test_default_base_date_is_today():
    result = predict_runout_date("dairy")
    expected = date.today() + timedelta(days=CATEGORY_RUNOUT_DAYS["dairy"])
    assert result == expected


def test_empty_string_category_uses_default():
    base = date(2024, 1, 1)
    assert predict_runout_date("", base) == base + timedelta(days=DEFAULT_RUNOUT_DAYS)
