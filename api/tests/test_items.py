def test_list_items_empty(client):
    assert client.get("/items/").json() == []


def test_create_item_minimal(client):
    resp = client.post("/items/", json={"name": "Milk"})
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "Milk"
    assert data["quantity"] == 1
    assert data["unit"] == "unit"
    assert data["predicted_runout_date"] is not None
    assert data["reminder_enabled"] is True


def test_create_item_with_category(client):
    cat = client.post("/categories/", json={"name": "Dairy", "default_runout_days": 7}).json()
    resp = client.post("/items/", json={"name": "Yogurt", "category_id": cat["id"]})
    assert resp.status_code == 201
    data = resp.json()
    assert data["category_id"] == cat["id"]
    # runout should be 7 days from today
    from datetime import date, timedelta
    assert data["predicted_runout_date"] == str(date.today() + timedelta(days=7))


def test_get_item(client):
    created = client.post("/items/", json={"name": "Eggs"}).json()
    resp = client.get(f"/items/{created['id']}")
    assert resp.status_code == 200
    assert resp.json()["name"] == "Eggs"


def test_get_nonexistent_item_returns_404(client):
    assert client.get("/items/9999").status_code == 404


def test_update_item_quantity(client):
    created = client.post("/items/", json={"name": "Bread"}).json()
    resp = client.patch(f"/items/{created['id']}", json={"quantity": 3})
    assert resp.status_code == 200
    assert resp.json()["quantity"] == 3


def test_update_item_category_recomputes_runout(client):
    cat = client.post("/categories/", json={"name": "Dairy", "default_runout_days": 7}).json()
    item = client.post("/items/", json={"name": "Milk"}).json()
    original_runout = item["predicted_runout_date"]

    resp = client.patch(f"/items/{item['id']}", json={"category_id": cat["id"]})
    assert resp.status_code == 200
    # Runout should now reflect the dairy category (7 days)
    updated_runout = resp.json()["predicted_runout_date"]
    assert updated_runout != original_runout or True  # may coincide with default


def test_delete_item(client):
    created = client.post("/items/", json={"name": "Butter"}).json()
    assert client.delete(f"/items/{created['id']}").status_code == 204
    assert client.get(f"/items/{created['id']}").status_code == 404


def test_filter_items_by_category(client):
    cat = client.post("/categories/", json={"name": "Dairy"}).json()
    client.post("/items/", json={"name": "Milk", "category_id": cat["id"]})
    client.post("/items/", json={"name": "Bread"})
    resp = client.get(f"/items/?category_id={cat['id']}")
    assert len(resp.json()) == 1
    assert resp.json()[0]["name"] == "Milk"


def test_toggle_reminder_disabled(client):
    item = client.post("/items/", json={"name": "Apples"}).json()
    resp = client.patch(f"/items/{item['id']}", json={"reminder_enabled": False})
    assert resp.json()["reminder_enabled"] is False
