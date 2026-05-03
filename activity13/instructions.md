# Lab Activity: MongoDB Aggregation Pipeline (Filtering & Projection)

## Objective
At the end of this activity, students should be able to:
1. Construct multi-stage aggregation pipelines using `$match`, `$project`, `$sort`, and `$limit`.
2. Apply renaming and field computation within the `$project` stage.
3. Understand the performance implications of stage ordering (filtering early).

---

## Scenario: Smart Fleet Management
You are a Data Engineer for "Nexus Logistics," a company managing a diverse fleet of vehicles ranging from electric scooters to heavy-duty semi-trucks. Your task is to provide specific reports to the Operations Manager to help identify vehicles that need immediate attention.
### Fields:

* **`vin`**: (String) Unique Vehicle Identification Number.
* **`type`**: (String) e.g., "Semi-Truck", "Van", "Electric Scooter".
* **`status`**: (String) e.g., "In Transit", "Maintenance", "Idle".
* **`fuelLevel`**: (Number) Percentage remaining (0–100).
* **`lastServiceDate`**: (Date) When it was last in the shop.
* **`activeAlerts`**: (Array) List of current issues, e.g., `["Low Tire Pressure", "Engine Heat"]`.
* **`isElectric`**: (Boolean) True/False.
* **`location`**: (Object) A GeoJSON object for mapping.



---

## Setup
Connect to your MongoDB instance and import the following documents to initialize the `vehicles` collection:

```json
[
  { "vin": "VIN1001A7F2B", "type": "Semi-Truck", "status": "In Transit", "fuelLevel": 82, "lastServiceDate": "2026-01-15T00:00:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-118.2437, 34.0522] } },
  { "vin": "VIN1002G9H4J", "type": "Van", "status": "Maintenance", "fuelLevel": 15, "lastServiceDate": "2026-04-10T00:00:00Z", "activeAlerts": ["Oil Change Required", "Brake Pad Wear"], "isElectric": false, "location": { "type": "Point", "coordinates": [-122.4194, 37.7749] } },
  { "vin": "VIN1003K2L9M", "type": "Electric Scooter", "status": "Idle", "fuelLevel": 98, "lastServiceDate": "2026-03-20T00:00:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-73.9352, 40.7306] } },
  { "vin": "VIN1004P0Q5R", "type": "Semi-Truck", "status": "In Transit", "fuelLevel": 45, "lastServiceDate": "2025-12-01T00:00:00Z", "activeAlerts": ["Low Tire Pressure"], "isElectric": false, "location": { "type": "Point", "coordinates": [-87.6298, 41.8781] } },
  { "vin": "VIN1005X8Y2Z", "type": "Box Truck", "status": "Charging", "fuelLevel": 62, "lastServiceDate": "2026-02-14T09:00:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-115.1398, 36.1699] } },
  { "vin": "VIN1006B1C4D", "type": "Delivery Drone", "status": "Idle", "fuelLevel": 88, "lastServiceDate": "2026-04-01T12:30:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-122.3321, 47.6062] } },
  { "vin": "VIN1007E3F6G", "type": "Van", "status": "In Transit", "fuelLevel": 55, "lastServiceDate": "2025-11-20T14:15:00Z", "activeAlerts": ["Sensor Error"], "isElectric": false, "location": { "type": "Point", "coordinates": [-80.1918, 25.7617] } },
  { "vin": "VIN1008H5J8K", "type": "Electric Scooter", "status": "Charging", "fuelLevel": 12, "lastServiceDate": "2026-04-22T08:00:00Z", "activeAlerts": ["Battery Degradation"], "isElectric": true, "location": { "type": "Point", "coordinates": [-112.0740, 33.4484] } },
  { "vin": "VIN1009L7M0N", "type": "Box Truck", "status": "In Transit", "fuelLevel": 70, "lastServiceDate": "2026-01-05T11:00:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-95.3698, 29.7604] } },
  { "vin": "VIN1010P2Q4R", "type": "Semi-Truck", "status": "Maintenance", "fuelLevel": 5, "lastServiceDate": "2026-04-25T16:45:00Z", "activeAlerts": ["Brake Pad Wear"], "isElectric": false, "location": { "type": "Point", "coordinates": [-104.9903, 39.7392] } },
  { "vin": "VIN1011S6T8U", "type": "Delivery Drone", "status": "In Transit", "fuelLevel": 40, "lastServiceDate": "2026-03-12T10:00:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-90.0715, 29.9511] } },
  { "vin": "VIN1012V0W2X", "type": "Van", "status": "Idle", "fuelLevel": 100, "lastServiceDate": "2026-04-18T09:30:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-71.0589, 42.3601] } },
  { "vin": "VIN1013Z4A6B", "type": "Electric Scooter", "status": "Idle", "fuelLevel": 75, "lastServiceDate": "2026-02-28T14:00:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-84.3880, 33.7490] } },
  { "vin": "VIN1014C8D0E", "type": "Box Truck", "status": "In Transit", "fuelLevel": 33, "lastServiceDate": "2026-01-30T13:20:00Z", "activeAlerts": ["Low Tire Pressure"], "isElectric": false, "location": { "type": "Point", "coordinates": [-77.0369, 38.9072] } },
  { "vin": "VIN1015F2G4H", "type": "Semi-Truck", "status": "In Transit", "fuelLevel": 91, "lastServiceDate": "2026-03-05T17:00:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-117.1611, 32.7157] } },
  { "vin": "VIN1016J6K8L", "type": "Van", "status": "Charging", "fuelLevel": 22, "lastServiceDate": "2026-04-20T11:45:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-122.6765, 45.5231] } },
  { "vin": "VIN1017M0N2P", "type": "Delivery Drone", "status": "In Transit", "fuelLevel": 65, "lastServiceDate": "2026-04-15T15:30:00Z", "activeAlerts": ["Sensor Error"], "isElectric": true, "location": { "type": "Point", "coordinates": [-75.1652, 39.9526] } },
  { "vin": "VIN1018Q4R6S", "type": "Electric Scooter", "status": "Maintenance", "fuelLevel": 0, "lastServiceDate": "2026-04-26T10:15:00Z", "activeAlerts": ["Battery Degradation"], "isElectric": true, "location": { "type": "Point", "coordinates": [-82.9988, 39.9612] } },
  { "vin": "VIN1019T8U0V", "type": "Box Truck", "status": "Idle", "fuelLevel": 50, "lastServiceDate": "2025-12-25T08:00:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-97.7431, 30.2672] } },
  { "vin": "VIN1020X2Y4Z", "type": "Semi-Truck", "status": "In Transit", "fuelLevel": 77, "lastServiceDate": "2026-02-10T12:00:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-81.6557, 30.3322] } },
  { "vin": "VIN1021A6B8C", "type": "Van", "status": "In Transit", "fuelLevel": 48, "lastServiceDate": "2026-03-18T09:00:00Z", "activeAlerts": ["Oil Change Required"], "isElectric": false, "location": { "type": "Point", "coordinates": [-111.8910, 40.7608] } },
  { "vin": "VIN1022D0E2F", "type": "Delivery Drone", "status": "Idle", "fuelLevel": 94, "lastServiceDate": "2026-04-05T14:20:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-78.6382, 35.7796] } },
  { "vin": "VIN1023G4H6J", "type": "Electric Scooter", "status": "Charging", "fuelLevel": 30, "lastServiceDate": "2026-04-24T13:40:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-121.8863, 37.3382] } },
  { "vin": "VIN1024K8L0M", "type": "Box Truck", "status": "Maintenance", "fuelLevel": 18, "lastServiceDate": "2026-04-12T11:10:00Z", "activeAlerts": ["Brake Pad Wear"], "isElectric": false, "location": { "type": "Point", "coordinates": [-83.0458, 42.3314] } },
  { "vin": "VIN1025N2P4Q", "type": "Semi-Truck", "status": "In Transit", "fuelLevel": 66, "lastServiceDate": "2026-01-20T16:00:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-96.7970, 32.7767] } },
  { "vin": "VIN1026R6S8T", "type": "Van", "status": "Idle", "fuelLevel": 85, "lastServiceDate": "2026-03-30T10:30:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-86.1581, 39.7684] } },
  { "vin": "VIN1027U0V2W", "type": "Delivery Drone", "status": "In Transit", "fuelLevel": 52, "lastServiceDate": "2026-04-19T09:15:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-76.6122, 39.2904] } },
  { "vin": "VIN1028X4Y6Z", "type": "Electric Scooter", "status": "Idle", "fuelLevel": 60, "lastServiceDate": "2026-02-15T15:50:00Z", "activeAlerts": ["Battery Degradation"], "isElectric": true, "location": { "type": "Point", "coordinates": [-92.2896, 34.7465] } },
  { "vin": "VIN1029B8C0D", "type": "Box Truck", "status": "In Transit", "fuelLevel": 25, "lastServiceDate": "2026-04-02T13:00:00Z", "activeAlerts": ["Low Tire Pressure"], "isElectric": true, "location": { "type": "Point", "coordinates": [-106.6504, 35.0844] } },
  { "vin": "VIN1030E2F4G", "type": "Semi-Truck", "status": "Maintenance", "fuelLevel": 10, "lastServiceDate": "2026-04-26T14:20:00Z", "activeAlerts": ["Oil Change Required"], "isElectric": false, "location": { "type": "Point", "coordinates": [-80.8431, 35.2271] } },
  { "vin": "VIN1031H6J8K", "type": "Van", "status": "In Transit", "fuelLevel": 72, "lastServiceDate": "2026-01-10T12:00:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-110.9747, 32.2226] } },
  { "vin": "VIN1032L0M2N", "type": "Delivery Drone", "status": "Charging", "fuelLevel": 15, "lastServiceDate": "2026-04-23T11:00:00Z", "activeAlerts": ["Sensor Error"], "isElectric": true, "location": { "type": "Point", "coordinates": [-73.7562, 42.6526] } },
  { "vin": "VIN1033P4Q6R", "type": "Electric Scooter", "status": "In Transit", "fuelLevel": 43, "lastServiceDate": "2026-03-25T16:30:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-122.3917, 37.7394] } },
  { "vin": "VIN1034S8T0U", "type": "Box Truck", "status": "Idle", "fuelLevel": 95, "lastServiceDate": "2026-04-14T08:45:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-87.9065, 43.0389] } },
  { "vin": "VIN1035V2W4X", "type": "Semi-Truck", "status": "In Transit", "fuelLevel": 58, "lastServiceDate": "2025-11-30T10:00:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-90.1994, 38.6270] } },
  { "vin": "VIN1036Z6A8B", "type": "Van", "status": "Maintenance", "fuelLevel": 3, "lastServiceDate": "2026-04-27T09:00:00Z", "activeAlerts": ["Brake Pad Wear", "Sensor Error"], "isElectric": false, "location": { "type": "Point", "coordinates": [-77.4360, 37.5407] } },
  { "vin": "VIN1037C0D2E", "type": "Delivery Drone", "status": "Idle", "fuelLevel": 81, "lastServiceDate": "2026-02-20T14:10:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-81.6748, 41.4993] } },
  { "vin": "VIN1038F4G6H", "type": "Electric Scooter", "status": "In Transit", "fuelLevel": 67, "lastServiceDate": "2026-03-15T11:20:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-117.8265, 33.6846] } },
  { "vin": "VIN1039J8K0L", "type": "Box Truck", "status": "Charging", "fuelLevel": 40, "lastServiceDate": "2026-04-18T15:00:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-74.0776, 40.7282] } },
  { "vin": "VIN1040M2N4P", "type": "Semi-Truck", "status": "In Transit", "fuelLevel": 89, "lastServiceDate": "2026-01-25T13:40:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-97.3308, 32.7555] } },
  { "vin": "VIN1041R6S8T", "type": "Van", "status": "Idle", "fuelLevel": 54, "lastServiceDate": "2026-03-08T10:15:00Z", "activeAlerts": ["Low Tire Pressure"], "isElectric": false, "location": { "type": "Point", "coordinates": [-82.4578, 27.9506] } },
  { "vin": "VIN1042U0V2W", "type": "Delivery Drone", "status": "Maintenance", "fuelLevel": 12, "lastServiceDate": "2026-04-20T16:20:00Z", "activeAlerts": ["Battery Degradation"], "isElectric": true, "location": { "type": "Point", "coordinates": [-80.2442, 36.0998] } },
  { "vin": "VIN1043X4Y6Z", "type": "Electric Scooter", "status": "In Transit", "fuelLevel": 88, "lastServiceDate": "2026-04-05T12:00:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-118.4912, 34.0195] } },
  { "vin": "VIN1044B8C0D", "type": "Box Truck", "status": "In Transit", "fuelLevel": 39, "lastServiceDate": "2026-01-12T08:30:00Z", "activeAlerts": ["Oil Change Required"], "isElectric": false, "location": { "type": "Point", "coordinates": [-84.5120, 39.1031] } },
  { "vin": "VIN1045E2F4G", "type": "Semi-Truck", "status": "Idle", "fuelLevel": 100, "lastServiceDate": "2026-04-22T14:45:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-92.2896, 34.7465] } },
  { "vin": "VIN1046H6J8K", "type": "Van", "status": "Charging", "fuelLevel": 56, "lastServiceDate": "2026-03-22T11:00:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-71.4128, 41.8240] } },
  { "vin": "VIN1047L0M2N", "type": "Delivery Drone", "status": "In Transit", "fuelLevel": 31, "lastServiceDate": "2026-04-10T15:20:00Z", "activeAlerts": [], "isElectric": true, "location": { "type": "Point", "coordinates": [-87.6298, 41.8781] } },
  { "vin": "VIN1048P4Q6R", "type": "Electric Scooter", "status": "Maintenance", "fuelLevel": 8, "lastServiceDate": "2026-04-25T13:10:00Z", "activeAlerts": ["Sensor Error"], "isElectric": true, "location": { "type": "Point", "coordinates": [-112.0740, 33.4484] } },
  { "vin": "VIN1049S8T0U", "type": "Box Truck", "status": "In Transit", "fuelLevel": 76, "lastServiceDate": "2026-02-01T09:50:00Z", "activeAlerts": [], "isElectric": false, "location": { "type": "Point", "coordinates": [-122.3321, 47.6062] } },
  { "vin": "VIN1050V2W4X", "type": "Semi-Truck", "status": "In Transit", "fuelLevel": 42, "lastServiceDate": "2025-12-15T16:00:00Z", "activeAlerts": ["Brake Pad Wear"], "isElectric": false, "location": { "type": "Point", "coordinates": [-73.9352, 40.7306] } }
]
```

---

## Instructions
Write the MongoDB Aggregation queries for the following requirements. Ensure you use the **Aggregation Pipeline** (`db.collection.aggregate([])`) and not standard `find()`.

### Task 1: Emergency Fuel Report
The Operations Team needs a list of all vehicles (regardless of type) that are currently **"In Transit"** and have a **fuelLevel below 50%**.
*   **Stage 1:** Filter for status and fuel level.
*   **Stage 2:** Project only the `vin`, `type`, and `fuelLevel`. Hide the `_id`.

### Task 2: Maintenance Prioritization
Identify vehicles that are in **"Maintenance"**.
*   **Stage 1:** Match vehicles in maintenance.
*   **Stage 2:** Project the `vin`, rename `activeAlerts` to `issues`, and show the `lastServiceDate`.
*   **Stage 3:** Sort by `lastServiceDate` (Oldest first) to see which has been waiting the longest.

### Task 3: Electric Fleet Geo-Audit
The manager wants to check the location of all **Electric** vehicles.
*   **Stage 1:** Match electric vehicles.
*   **Stage 2:** Project the `vin` and create two new fields: `lon` and `lat` by extracting them from the `location.coordinates` array. 
    *   *Hint: Remember array indexing in projection, e.g., `"$location.coordinates"`; 
        `key: { $arrayElemAt: ["$key.anotherKey", 0] }`,
       *
*   **Stage 3:** Hide the `location` and `_id` fields.

### Task 4: The Mastery Challenge (Multi-Stage Complexity)
Generate a "High-Risk Truck Report" with the following requirements:
1.  Find all **"Semi-Truck"** vehicles.
2.  Calculate a new field called `alertCount` which is the size/length of the `activeAlerts` array.
3.  Calculate a field called `needsUrgentRefuel` which is a boolean (true if `fuelLevel` < 20).
4.  Show only the `vin`, `alertCount`, and `needsUrgentRefuel`.
5.  Sort the results so the truck with the **most alerts** appears first.
6.  Limit the result to the top 3 high-risk trucks.

---

## Submission
Save your queries in a file named `solution.js`. Add screenshot of output into a spearate file `output.md`. Sumve under `activity13` directory.