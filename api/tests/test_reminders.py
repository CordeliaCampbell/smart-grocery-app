from datetime import date, timedelta


def _make_item(client, name="Milk"):
    return client.post("/items/", json={"name": name}).json()


def test_list_reminders_empty(client):
    assert client.get("/reminders/").json() == []


def test_create_reminder(client):
    item = _make_item(client)
    scheduled = str(date.today() + timedelta(days=5))
    resp = client.post("/reminders/", json={"item_id": item["id"], "scheduled_date": scheduled})
    assert resp.status_code == 201
    data = resp.json()
    assert data["item_id"] == item["id"]
    assert data["scheduled_date"] == scheduled
    assert data["sent"] is False


def test_create_reminder_for_nonexistent_item(client):
    resp = client.post("/reminders/", json={"item_id": 9999, "scheduled_date": str(date.today())})
    assert resp.status_code == 404


def test_mark_reminder_sent(client):
    item = _make_item(client, "Eggs")
    reminder = client.post(
        "/reminders/", json={"item_id": item["id"], "scheduled_date": str(date.today())}
    ).json()
    resp = client.patch(f"/reminders/{reminder['id']}", json={"sent": True})
    assert resp.status_code == 200
    assert resp.json()["sent"] is True


def test_reschedule_reminder(client):
    item = _make_item(client, "Bread")
    reminder = client.post(
        "/reminders/", json={"item_id": item["id"], "scheduled_date": str(date.today())}
    ).json()
    new_date = str(date.today() + timedelta(days=3))
    resp = client.patch(f"/reminders/{reminder['id']}", json={"scheduled_date": new_date})
    assert resp.json()["scheduled_date"] == new_date


def test_delete_reminder(client):
    item = _make_item(client, "Butter")
    reminder = client.post(
        "/reminders/", json={"item_id": item["id"], "scheduled_date": str(date.today())}
    ).json()
    assert client.delete(f"/reminders/{reminder['id']}").status_code == 204


def test_delete_item_cascades_reminders(client):
    item = _make_item(client, "Cheese")
    client.post("/reminders/", json={"item_id": item["id"], "scheduled_date": str(date.today())})
    client.delete(f"/items/{item['id']}")
    # Reminders list should now be empty
    assert client.get("/reminders/").json() == []
