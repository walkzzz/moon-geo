// Raster2 白盒测试

///|
test "raster2 basic" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 5, 10)
  assert_eq(r.cell_count(), 50)
  let ((min_x, max_y), (max_x, min_y)) = r.bounds()
  assert_true(@util.dbl_approx_eq(min_x, 0.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(max_y, 100.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(max_x, 50.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(min_y, 0.0, 1.0e-10))
}

///|
test "raster2 cell_to_world" {
  let r = Raster2::new(100.0, 200.0, 10.0, 10.0, 10, 10)
  let (x, y) = r.cell_to_world(0, 0)
  assert_true(@util.dbl_approx_eq(x, 100.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(y, 200.0, 1.0e-10))
  let (x2, y2) = r.cell_to_world(5, 3)
  assert_true(@util.dbl_approx_eq(x2, 150.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(y2, 170.0, 1.0e-10))
}

///|
test "raster2 cell_center_to_world" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 10, 10)
  let (x, y) = r.cell_center_to_world(0, 0)
  assert_true(@util.dbl_approx_eq(x, 5.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(y, 95.0, 1.0e-10))
  let (x2, y2) = r.cell_center_to_world(5, 5)
  assert_true(@util.dbl_approx_eq(x2, 55.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(y2, 45.0, 1.0e-10))
}

///|
test "raster2 world_to_cell" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 10, 10)
  let (col, row) = r.world_to_cell(5.0, 95.0)
  assert_eq(col, 0)
  assert_eq(row, 0)
  let (col2, row2) = r.world_to_cell(55.0, 45.0)
  assert_eq(col2, 5)
  assert_eq(row2, 5)
}

///|
test "raster2 cell_to_world world_to_cell roundtrip" {
  let r = Raster2::new(100.0, 200.0, 10.0, 10.0, 20, 20)
  for col in 0..<20 {
    for row in 0..<20 {
      let (x, y) = r.cell_center_to_world(col, row)
      let (c2, r2) = r.world_to_cell(x, y)
      assert_eq(c2, col)
      assert_eq(r2, row)
    }
  }
}

///|
test "raster2 cell_in_bounds" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 5, 10)
  assert_true(r.cell_in_bounds(0, 0))
  assert_true(r.cell_in_bounds(4, 9))
  assert_false(r.cell_in_bounds(5, 0))
  assert_false(r.cell_in_bounds(0, 10))
  assert_false(r.cell_in_bounds(-1, 0))
}

///|
test "raster2 contains" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 5, 10)
  assert_true(r.contains(5.0, 50.0))
  assert_true(r.contains(0.0, 100.0))
  assert_false(r.contains(100.0, 0.0))
}

///|
test "raster2 cell_polygon" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 10, 10)
  let poly = r.cell_polygon(2, 3)
  assert_eq(poly.length(), 4)
  assert_true(@util.dbl_approx_eq(poly[0].0, 20.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(poly[0].1, 70.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(poly[2].0, 30.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(poly[2].1, 60.0, 1.0e-10))
}

///|
test "raster2 rasterize_point" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 10, 10)
  match r.rasterize_point(55.0, 45.0) {
    Some((col, row)) => {
      assert_eq(col, 5)
      assert_eq(row, 5)
    }
    None => assert_true(false)
  }
  assert_true(r.rasterize_point(200.0, 200.0) is None)
}

///|
test "raster2 rasterize_line horizontal" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 20, 20)
  let cells = r.rasterize_line(5.0, 50.0, 95.0, 50.0)
  assert_true(cells.length() >= 9)
  for (col, row) in cells {
    assert_eq(row, 5)
  }
}

///|
test "raster2 rasterize_line vertical" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 20, 20)
  let cells = r.rasterize_line(50.0, 5.0, 50.0, 95.0)
  assert_true(cells.length() >= 9)
  for (col, row) in cells {
    assert_eq(col, 5)
  }
}

///|
test "raster2 rasterize_line diagonal" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 20, 20)
  let cells = r.rasterize_line(5.0, 95.0, 95.0, 5.0)
  assert_true(cells.length() >= 9)
  let first = cells[0]
  let last = cells[cells.length() - 1]
  assert_eq(first.0, 0)
  assert_eq(last.0, 9)
}

///|
test "raster2 rasterize_line single point" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 20, 20)
  let cells = r.rasterize_line(55.0, 45.0, 55.0, 45.0)
  assert_eq(cells.length(), 1)
}

///|
test "raster2 cells_to_polygons" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 5, 5)
  let mask = [
    [true, false, false, false, false],
    [false, true, false, false, false],
    [false, false, true, false, false],
  ]
  let polys = r.cells_to_polygons(mask)
  assert_eq(polys.length(), 3)
  for poly in polys {
    assert_eq(poly.length(), 4)
  }
}

///|
test "raster2 cells_to_polygons empty" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 5, 5)
  let mask = [
    [false, false, false, false, false],
    [false, false, false, false, false],
  ]
  let polys = r.cells_to_polygons(mask)
  assert_eq(polys.length(), 0)
}

///|
test "raster2 rasterize_polygon square" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 10, 10)
  let coords = [
    (25.0, 75.0),
    (75.0, 75.0),
    (75.0, 25.0),
    (25.0, 25.0),
    (25.0, 75.0),
  ]
  let cells = r.rasterize_polygon(coords)
  assert_true(cells.length() >= 16)
  for (col, row) in cells {
    assert_true(col >= 2 && col <= 7)
    assert_true(row >= 2 && row <= 7)
  }
}

///|
test "raster2 rasterize_polygon small" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 10, 10)
  let coords = [
    (15.0, 85.0),
    (25.0, 85.0),
    (25.0, 75.0),
    (15.0, 75.0),
    (15.0, 85.0),
  ]
  let cells = r.rasterize_polygon(coords)
  assert_true(cells.length() >= 1)
}

///|
test "raster2 rasterize_polygon degenerate" {
  let r = Raster2::new(0.0, 100.0, 10.0, 10.0, 10, 10)
  let coords = [(50.0, 50.0), (60.0, 50.0)]
  let cells = r.rasterize_polygon(coords)
  assert_eq(cells.length(), 0)
}

///|
test "raster2 negative origin" {
  let r = Raster2::new(-180.0, 90.0, 1.0, 1.0, 360, 180)
  let (x, y) = r.cell_to_world(180, 90)
  assert_true(@util.dbl_approx_eq(x, 0.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(y, 0.0, 1.0e-10))
  let (col, row) = r.world_to_cell(0.0, 0.0)
  assert_eq(col, 180)
  assert_eq(row, 90)
}

///|
test "raster2 non_square_pixels" {
  let r = Raster2::new(0.0, 100.0, 5.0, 20.0, 20, 5)
  let (x, y) = r.cell_center_to_world(10, 2)
  assert_true(@util.dbl_approx_eq(x, 52.5, 1.0e-10))
  assert_true(@util.dbl_approx_eq(y, 50.0, 1.0e-10))
  let (col, row) = r.world_to_cell(52.5, 50.0)
  assert_eq(col, 10)
  assert_eq(row, 2)
}
