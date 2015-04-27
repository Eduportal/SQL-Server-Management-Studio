DECLARE @g GEOMETRY
SELECT @g = GEOMETRY::STGeomFromText('POLYGON((1 1, 3 3, 3 1, 1 3, 1 1))',0)
SELECT @g -- Spatial results tab doesn't display in SSMS x64
SELECT @g.MakeValid() -- This works
GO