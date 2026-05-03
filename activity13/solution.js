// Task 1: Emergency Fuel Report
// Vehicles "In Transit" with fuelLevel below 50%
db.vehicles.aggregate([
  {
    $match: {
      status: "In Transit",
      fuelLevel: { $lt: 50 }
    }
  },
  {
    $project: {
      _id: 0,
      vin: 1,
      type: 1,
      fuelLevel: 1
    }
  }
]);

// Task 2: Maintenance Prioritization
// Vehicles in "Maintenance", sorted by lastServiceDate oldest first
db.vehicles.aggregate([
  {
    $match: {
      status: "Maintenance"
    }
  },
  {
    $project: {
      _id: 0,
      vin: 1,
      issues: "$activeAlerts",
      lastServiceDate: 1
    }
  },
  {
    $sort: {
      lastServiceDate: 1
    }
  }
]);

// Task 3: Electric Fleet Geo-Audit
// Electric vehicles with lon and lat extracted from coordinates
db.vehicles.aggregate([
  {
    $match: {
      isElectric: true
    }
  },
  {
    $project: {
      _id: 0,
      vin: 1,
      lon: { $arrayElemAt: ["$location.coordinates", 0] },
      lat: { $arrayElemAt: ["$location.coordinates", 1] }
    }
  }
]);

// Task 4: High-Risk Truck Report
// Semi-Trucks with alertCount and needsUrgentRefuel, top 3 by most alerts
db.vehicles.aggregate([
  {
    $match: {
      type: "Semi-Truck"
    }
  },
  {
    $project: {
      _id: 0,
      vin: 1,
      alertCount: { $size: "$activeAlerts" },
      needsUrgentRefuel: { $lt: ["$fuelLevel", 20] }
    }
  },
  {
    $sort: {
      alertCount: -1
    }
  },
  {
    $limit: 3
  }
]);
