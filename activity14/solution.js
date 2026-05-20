// Activity 14: MongoDB Aggregation Framework (Grouping & Summarization)

// Task 1: Branch Performance Summary
db.sales.aggregate([
  {
    $group: {
      _id: "$branch",
      totalRevenue: { $sum: "$total" },
      averageRating: { $avg: "$rating" },
      transactionCount: { $sum: 1 }
    }
  }
]);

// Task 2: Product Line Insights (Min/Max/Avg)
db.sales.aggregate([
  {
    $group: {
      _id: "$productLine",
      minUnitPrice: { $min: "$unitPrice" },
      maxUnitPrice: { $max: "$unitPrice" },
      avgQuantity: { $avg: "$quantity" }
    }
  }
]);

// Task 3: Demographic & Branch Analysis (Multiple Fields)
db.sales.aggregate([
  {
    $group: {
      _id: { b: "$branch", g: "$gender" },
      totalSales: { $sum: "$total" }
    }
  }
]);

// Task 4: Loyalty Program Deep Dive (Push/AddToSet)
db.sales.aggregate([
  { $match: { customerType: "Member" } },
  {
    $group: {
      _id: "$city",
      uniqueProductLines: { $addToSet: "$productLine" },
      allPaymentMethods: { $push: "$payment" }
    }
  }
]);

// Task 5: Global Company Totals
db.sales.aggregate([
  {
    $group: {
      _id: null,
      totalRevenue: { $sum: "$total" },
      totalQuantity: { $sum: "$quantity" }
    }
  }
]);
