import unittest

from tools.select_ios_simulator import select_simulator


class SelectIosSimulatorTest(unittest.TestCase):
    def test_existing_device_prefers_representative_iphone_on_latest_runtime(self) -> None:
        devices_payload = {
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.iOS-18-2": [
                    {"isAvailable": True, "name": "iPhone 12", "udid": "older-phone"},
                    {"isAvailable": True, "name": "iPhone 15", "udid": "preferred-phone"},
                ],
                "com.apple.CoreSimulator.SimRuntime.iOS-17-5": [
                    {"isAvailable": True, "name": "iPhone 16", "udid": "old-runtime-phone"},
                ],
            }
        }
        runtimes_payload = {
            "runtimes": [
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.iOS-17-5",
                    "isAvailable": True,
                    "platform": "iOS",
                    "version": "17.5",
                },
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.iOS-18-2",
                    "isAvailable": True,
                    "platform": "iOS",
                    "version": "18.2",
                },
            ]
        }
        device_types_payload = {"devicetypes": []}

        self.assertEqual(
            select_simulator(devices_payload, runtimes_payload, device_types_payload),
            (
                "existing",
                "preferred-phone",
                "iPhone 15",
                "com.apple.CoreSimulator.SimRuntime.iOS-18-2",
            ),
        )

    def test_existing_device_ignores_non_iphone_entries(self) -> None:
        devices_payload = {
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.iOS-18-2": [
                    {"isAvailable": True, "name": "iPad Air 13-inch", "udid": "ipad-air"},
                    {"isAvailable": True, "name": "iPhone 14", "udid": "iphone-14"},
                ]
            }
        }
        runtimes_payload = {
            "runtimes": [
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.iOS-18-2",
                    "isAvailable": True,
                    "platform": "iOS",
                    "version": "18.2",
                }
            ]
        }
        device_types_payload = {"devicetypes": []}

        self.assertEqual(
            select_simulator(devices_payload, runtimes_payload, device_types_payload),
            (
                "existing",
                "iphone-14",
                "iPhone 14",
                "com.apple.CoreSimulator.SimRuntime.iOS-18-2",
            ),
        )

    def test_created_device_prefers_representative_iphone_type(self) -> None:
        devices_payload = {"devices": {}}
        runtimes_payload = {
            "runtimes": [
                {
                    "identifier": "com.apple.CoreSimulator.SimRuntime.iOS-18-2",
                    "isAvailable": True,
                    "platform": "iOS",
                    "version": "18.2",
                }
            ]
        }
        device_types_payload = {
            "devicetypes": [
                {
                    "name": "iPad Air 13-inch",
                    "identifier": "com.apple.CoreSimulator.SimDeviceType.iPad-Air-13-inch",
                    "productFamily": "iPad",
                    "minRuntimeVersion": 0,
                    "maxRuntimeVersion": 4294967295,
                },
                {
                    "name": "iPhone 13",
                    "identifier": "com.apple.CoreSimulator.SimDeviceType.iPhone-13",
                    "productFamily": "iPhone",
                    "minRuntimeVersion": 0,
                    "maxRuntimeVersion": 4294967295,
                },
                {
                    "name": "iPhone 15",
                    "identifier": "com.apple.CoreSimulator.SimDeviceType.iPhone-15",
                    "productFamily": "iPhone",
                    "minRuntimeVersion": 0,
                    "maxRuntimeVersion": 4294967295,
                },
            ]
        }

        self.assertEqual(
            select_simulator(devices_payload, runtimes_payload, device_types_payload),
            (
                "create",
                "com.apple.CoreSimulator.SimRuntime.iOS-18-2",
                "com.apple.CoreSimulator.SimDeviceType.iPhone-15",
                "iPhone 15",
            ),
        )


if __name__ == "__main__":
    unittest.main()
