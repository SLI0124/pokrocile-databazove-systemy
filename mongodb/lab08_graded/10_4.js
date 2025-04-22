const names = db.moviedb.aggregate([
    { $group: { _id: "$name", count: { $sum: 1 } } },
    { $match: { count: { $gt: 1 } } }
  ]).toArray();
  
  names.forEach(({ _id: name }) => {
    const docs = db.moviedb.find({ name }).toArray();
    const largestDoc = docs.reduce((a, b) => 
      JSON.stringify(a).length > JSON.stringify(b).length ? a : b
    );
    db.moviedb.deleteMany({ 
      name, 
      _id: { $ne: largestDoc._id } 
    });
  });
