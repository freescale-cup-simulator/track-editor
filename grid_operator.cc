#include <grid_operator.h>

GridOperator::GridOperator(QObject *parent)
    : QObject(parent)
    , m_grid_width(8)
    , m_grid_height(8)
    , m_tile_side(100)
    , m_grid(nullptr)
{
    // FIXME: static variable?
	typeStringMap.insert("Tile_Line", tl::Tile::Line);
	typeStringMap.insert("Tile_Start", tl::Tile::Start);
	typeStringMap.insert("Tile_Turn", tl::Tile::Turn);
	typeStringMap.insert("Tile_Saw", tl::Tile::Saw);
	typeStringMap.insert("Tile_Hill", tl::Tile::Hill);
	typeStringMap.insert("Tile_Teeth", tl::Tile::Teeth);
	typeStringMap.insert("Tile_Crossing", tl::Tile::Crossing);
}

int GridOperator::gridWidth()
{
    return m_grid_width;
}

void GridOperator::setGridWidth(int w)
{
    m_grid_width = w;
    gridDimensionChanged();
}

int GridOperator::gridHeight()
{
    return m_grid_height;
}

void GridOperator::setGridHeight(int h)
{
    m_grid_height = h;
    gridDimensionChanged();
}

int GridOperator::tileSide()
{
    return m_tile_side;
}

QQuickItem *GridOperator::grid()
{
    return m_grid;
}

void GridOperator::setGrid(QQuickItem *grid)
{
    m_grid = grid;
    gridChanged();
}

QString GridOperator::currentFileName()
{
    return m_currentFileName;
}

void GridOperator::saveGrid(const QUrl & url)
{
    Q_ASSERT(m_grid);

    tl::TrackModel m (m_grid_width, m_grid_height);
    QVariant p;
    QQuickItem * tile;
    QString path = url.toLocalFile();
    QFileInfo path_info (path);

    // use did not specify .xml extension
    if (path_info.suffix() != "xml")
      path += ".xml";

    m_currentFileName = path;
    currentFileNameChanged();

    for (QQuickItem * dropArea : m_grid->childItems())
    {
        p = dropArea->property("haveTile");
        if (p.isValid() && p.toBool())
        {
            /*
             * a DropArea's first child is a highlight rectangle; the only
             * other child it ever has is a Tile; therefore, childItems().last()
             * should point us to that Tile
             */
            tile = dropArea->childItems().last();
            m.addTile(tl::Tile(stringToType(tile->objectName()),
                               dropArea->x() / m_tile_side,
                               m_grid_width - 1 - dropArea->y() / m_tile_side,
                               static_cast<int>(tile->rotation()) % 360));
        }
    }
    tl::io::saveTrackToFile(m, path.toStdString());
}

void GridOperator::loadGrid(const QUrl & url)
{
    Q_ASSERT(m_grid);

    tl::TrackModel m;
    if (!tl::io::populateTrackFromFile(m, url.toLocalFile().toStdString()))
        return;
    m_grid_height = m.height();
    m_grid_width = m.width();
    gridDimensionChanged();
    for (const tl::Tile & t : m.tiles())
        placeTile(t.x(), m_grid_width - t.y() - 1, t.rotation(),
                  typeToString(t.type()));
    m_currentFileName = url.toLocalFile();
    currentFileNameChanged();
}

tl::Tile::Type GridOperator::stringToType(const QString & string)
{
    return typeStringMap.value(string, tl::Tile::Invalid);
}

QString GridOperator::typeToString(tl::Tile::Type type)
{
    return typeStringMap.key(type);
}
