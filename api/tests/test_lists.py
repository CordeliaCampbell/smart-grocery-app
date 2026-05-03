def test_list_grocery_lists_empty(client):
    assert client.get("/lists/").json() == []


def test_create_list(client):
    resp = client.post("/lists/", json={"name": "Weekly Shop", "list_type": "grocery"})
    assert resp.status_code == 201
    data = resp.json()
    assert data["name"] == "Weekly Shop"
    assert data["list_type"] == "grocery"


def test_get_list_detail_empty(client):
    lst = client.post("/lists/", json={"name": "Costco Run"}).json()
    resp = client.get(f"/lists/{lst['id']}")
    assert resp.status_code == 200
    assert resp.json()["list_items"] == []


def test_get_nonexistent_list_returns_404(client):
    assert client.get("/lists/9999").status_code == 404


def test_add_list_item(client):
    lst = client.post("/lists/", json={"name": "Shopping"}).json()
    resp = client.post(f"/lists/{lst['id']}/items", json={"item_name": "Bananas", "quantity": 3})
    assert resp.status_code == 201
    data = resp.json()
    assert data["item_name"] == "Bananas"
    assert data["quantity"] == 3
    assert data["checked"] is False


def test_check_list_item(client):
    lst = client.post("/lists/", json={"name": "My List"}).json()
    item = client.post(f"/lists/{lst['id']}/items", json={"item_name": "Milk"}).json()
    resp = client.patch(f"/lists/{lst['id']}/items/{item['id']}", json={"checked": True})
    assert resp.status_code == 200
    assert resp.json()["checked"] is True


def test_delete_list_item(client):
    lst = client.post("/lists/", json={"name": "My List"}).json()
    item = client.post(f"/lists/{lst['id']}/items", json={"item_name": "Apples"}).json()
    assert client.delete(f"/lists/{lst['id']}/items/{item['id']}").status_code == 204


def test_delete_list_cascades_items(client):
    lst = client.post("/lists/", json={"name": "Temp"}).json()
    client.post(f"/lists/{lst['id']}/items", json={"item_name": "Bread"})
    assert client.delete(f"/lists/{lst['id']}").status_code == 204
    assert client.get(f"/lists/{lst['id']}").status_code == 404


def test_add_item_to_nonexistent_list(client):
    resp = client.post("/lists/9999/items", json={"item_name": "Eggs"})
    assert resp.status_code == 404


def test_list_detail_shows_items(client):
    lst = client.post("/lists/", json={"name": "Full List"}).json()
    client.post(f"/lists/{lst['id']}/items", json={"item_name": "Cheese"})
    client.post(f"/lists/{lst['id']}/items", json={"item_name": "Butter"})
    detail = client.get(f"/lists/{lst['id']}").json()
    assert len(detail["list_items"]) == 2
