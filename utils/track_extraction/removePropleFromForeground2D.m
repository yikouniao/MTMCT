function mask = removePropleFromForeground2D(data, id, mask)
% find people closer to the camera (approx by their y position)
thisPos = data(:, 1) == id;
in_polygon_cond = inpolygon([data(:, 5) data(:, 3)],[data(:, 4) data(:, 2)],[data(thisPos, 5) data(thisPos, 5) data(thisPos, 3) data(thisPos, 3)],[data(thisPos, 2) data(thisPos, 4) data(thisPos, 2) data(thisPos, 4)]);
closestThanID = find(data(:, 5) > data(thisPos, 5) & any(in_polygon_cond, 2));

% cut their BB out - it's a little bit conservative...
for i = 1 : numel(closestThanID)
    mask((data(closestThanID(i), 3)):(data(closestThanID(i), 5)), (data(closestThanID(i), 2)):(data(closestThanID(i), 4))) = 0;
end

end