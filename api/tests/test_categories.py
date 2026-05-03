def test_list_categories_empty(client):
    resp = client.get("/categories/")
    assert resp.status_code == 200
    assert resp.json() == []


def test_create_category(client):
    resp = client.post("/categories/", json={"name": "Dairy", "default_runout_days": 7, "icon": "🥛"})
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "Dairy"
    assert data["default_runout_days"] == 7
    assert data["icon"] == "🥛"
    assert "id" in data


def test_create_category_defaults(client):
    resp = client.post("/categories/", json={"name": "Other"})
    assert resp.status_code == 201
    assert resp.json()["default_runout_days"] == 14


def test_duplicate_category_returns_409(client):
    client.post("/categories/", json={"name": "Dairy"})
    resp = client.post("/categories/", json={"name": "Dairy"})
    assert resp.status_code == 409


def test_get_category(client):
    created = client.post("/categories/", json={"name": "Produce"}).json()
    resp = client.get(f"/categories/{created['id']}")
    assert resp.status_code == 200
    assert resp.json()["name"] == "Produce"


def test_get_nonexistent_category_returns_404(client):
    assert client.get("/categories/9999").status_code == 404


def test_list_multiple_categories(client):
    client.post("/categories/", json={"name": "Dairy"})
    client.post("/categories/", json={"name": "Produce"})
    resp = client.get("/categories/")
    assert len(resp.json()) == 2
