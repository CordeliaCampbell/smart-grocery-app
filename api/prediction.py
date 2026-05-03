from datetime import date, timedelta
from typing import Dict, Optional

# Days until predicted runout, keyed by lowercase category name.
CATEGORY_RUNOUT_DAYS: Dict[str, int] = {
    "produce": 5,
    "dairy": 7,
    "eggs": 12,
    "frozen": 30,
    "snacks": 14,
    "beverages": 14,
    "cleaning": 28,
    "laundry": 28,
    "paper products": 21,
    "skincare": 45,
    "haircare": 45,
    "medicine": 60,
    "pet food": 21,
    "pantry": 30,
}

DEFAULT_RUNOUT_DAYS = 14


def predict_runout_date(
    category_name: Optional[str],
    added_date: Optional[date] = None,
) -> date:
    """Return the estimated runout date for an item.

    Args:
        category_name: The item's category (case-insensitive). Uses the default
                       fallback if None or unrecognised.
        added_date: Base date for the calculation. Defaults to today.
    """
    base = added_date or date.today()
    days = DEFAULT_RUNOUT_DAYS
    if category_name:
        days = CATEGORY_RUNOUT_DAYS.get(category_name.lower(), DEFAULT_RUNOUT_DAYS)
    return base + timedelta(days=days)
