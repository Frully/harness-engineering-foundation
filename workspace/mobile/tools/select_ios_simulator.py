#!/usr/bin/env python3

import json
import pathlib
import sys

PREFERRED_IPHONES = [
    "iPhone 16",
    "iPhone 15",
    "iPhone 14",
    "iPhone 13",
    "iPhone SE",
]


def version_key(value: str) -> tuple[int, ...]:
    parts = []
    for item in value.split("."):
        try:
            parts.append(int(item))
        except ValueError:
            parts.append(0)
    return tuple(parts)


def runtime_version_number(version: str) -> int:
    parts = [int(item) for item in version.split(".")]
    while len(parts) < 3:
        parts.append(0)
    return (parts[0] << 16) | (parts[1] << 8) | parts[2]


def preferred_rank(name: str) -> tuple[int, str]:
    for index, preferred in enumerate(PREFERRED_IPHONES):
        if preferred in name:
            return (index, name)
    return (len(PREFERRED_IPHONES), name)


def available_runtimes(runtimes_payload: dict) -> list[dict]:
    runtimes = [
        runtime
        for runtime in runtimes_payload.get("runtimes", [])
        if runtime.get("isAvailable") and runtime.get("platform") == "iOS"
    ]
    runtimes.sort(key=lambda item: version_key(item.get("version", "0")), reverse=True)
    return runtimes


def choose_existing_simulator(devices_payload: dict, runtimes: list[dict]) -> tuple[str, str, str] | None:
    devices_by_runtime = devices_payload.get("devices", {})

    for runtime in runtimes:
        iphone_devices = []
        for device in devices_by_runtime.get(runtime["identifier"], []):
            if not device.get("isAvailable"):
                continue
            name = device.get("name", "")
            if "iPhone" not in name:
                continue
            iphone_devices.append((preferred_rank(name), device["udid"], name))

        if iphone_devices:
            _, udid, name = sorted(iphone_devices)[0]
            return (udid, name, runtime["identifier"])

    return None


def choose_simulator_to_create(device_types_payload: dict, runtimes: list[dict]) -> tuple[str, str, str] | None:
    iphone_types = [
        device_type
        for device_type in device_types_payload.get("devicetypes", [])
        if device_type.get("productFamily") == "iPhone"
    ]

    for runtime in runtimes:
        runtime_number = runtime_version_number(runtime["version"])
        compatible_types = []
        for device_type in iphone_types:
            min_version = int(device_type.get("minRuntimeVersion", 0))
            max_version = int(device_type.get("maxRuntimeVersion", 2**32 - 1))
            if runtime_number < min_version or runtime_number > max_version:
                continue
            compatible_types.append(device_type)

        if compatible_types:
            compatible_types.sort(key=lambda item: preferred_rank(item.get("name", "")))
            chosen = compatible_types[0]
            return (
                runtime["identifier"],
                chosen["identifier"],
                chosen["name"],
            )

    return None


def select_simulator(
    devices_payload: dict,
    runtimes_payload: dict,
    device_types_payload: dict,
) -> tuple[str, str, str, str]:
    runtimes = available_runtimes(runtimes_payload)
    if not runtimes:
        raise SystemExit("no available iOS simulator runtime found")

    existing = choose_existing_simulator(devices_payload, runtimes)
    if existing is not None:
        udid, name, runtime_id = existing
        return ("existing", udid, name, runtime_id)

    created = choose_simulator_to_create(device_types_payload, runtimes)
    if created is not None:
        runtime_id, device_type_id, device_name = created
        return ("create", runtime_id, device_type_id, device_name)

    raise SystemExit("no compatible iPhone simulator device type found for available runtimes")


def main(argv: list[str]) -> int:
    devices_payload = json.loads(pathlib.Path(argv[1]).read_text())
    runtimes_payload = json.loads(pathlib.Path(argv[2]).read_text())
    device_types_payload = json.loads(pathlib.Path(argv[3]).read_text())

    selection = select_simulator(devices_payload, runtimes_payload, device_types_payload)
    print("\t".join(selection))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
