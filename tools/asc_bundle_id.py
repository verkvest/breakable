#!/usr/bin/env python3
"""Register the iOS bundle id with App Store Connect if it does not exist yet.

The App Store Connect *app* record cannot be created with this API. Upload
will say so clearly when that record is still missing.
"""

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

import jwt


def token() -> str:
    key_id = os.environ["APPSTORE_API_KEY_ID"]
    issuer = os.environ["APPSTORE_API_ISSUER_ID"]
    key_path = os.environ["APPSTORE_API_KEY_PATH"]
    private_key = open(key_path, "r", encoding="utf-8").read()
    now = int(time.time())
    return jwt.encode(
        {"iss": issuer, "iat": now, "exp": now + 19 * 60, "aud": "appstoreconnect-v1"},
        private_key,
        algorithm="ES256",
        headers={"kid": key_id, "typ": "JWT"},
    )


def request(method: str, url: str, bearer: str, body=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", "Bearer " + bearer)
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.status, json.loads(resp.read().decode() or "{}")
    except urllib.error.HTTPError as exc:
        payload = exc.read().decode()
        try:
            parsed = json.loads(payload) if payload else {}
        except json.JSONDecodeError:
            parsed = {"raw": payload[:500]}
        return exc.code, parsed


def main() -> None:
    bundle = os.environ.get("BUNDLE_ID", "es.verkvest.clinkwell")
    name = os.environ.get("BUNDLE_NAME", "Clinkwell")
    bearer = token()
    query = urllib.parse.urlencode({"filter[identifier]": bundle})
    status, payload = request("GET", "https://api.appstoreconnect.apple.com/v1/bundleIds?" + query, bearer)
    if status != 200:
        print(f"::error::App Store Connect bundle id lookup failed ({status})")
        print(json.dumps(payload)[:800])
        sys.exit(1)
    if payload.get("data"):
        print(f"bundle id {bundle} already registered")
        return
    status, payload = request(
        "POST",
        "https://api.appstoreconnect.apple.com/v1/bundleIds",
        bearer,
        {
            "data": {
                "type": "bundleIds",
                "attributes": {
                    "name": name,
                    "identifier": bundle,
                    "platform": "IOS",
                },
            }
        },
    )
    if status in (201, 409):
        print(f"bundle id {bundle} registered ({status})")
        return
    # A duplicate identifier often comes back as 409. Some accounts return 400
    # with an ENTITY_ERROR that the identifier is already in use.
    errors = payload.get("errors") or []
    detail = " ".join(str(item.get("detail", "")) for item in errors)
    if "already" in detail.lower() or "exists" in detail.lower():
        print(f"bundle id {bundle} already registered")
        return
    print(f"::error::Could not register bundle id {bundle} ({status})")
    print(detail or json.dumps(payload)[:800])
    sys.exit(1)


if __name__ == "__main__":
    main()
